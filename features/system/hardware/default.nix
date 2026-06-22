{
  self,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  flake.nixosModules.coreHardware =
    { config, ... }:
    let
      cfg = config.services.battery-manager;

      batteryManagerBackend = pkgs.writeShellScript "battery-manager-backend" ''
        set -e

        if ! [[ "$1" =~ ^[0-9]+$ ]] || [ "$1" -lt 0 ] || [ "$1" -gt 100 ]; then
          ${pkgs.util-linux}/bin/logger -t battery-manager "Invalid battery level: $1"
          exit 1
        fi

        BATTERY_LEVEL="$1"
        FOUND=false

        for path in ${lib.escapeShellArgs cfg.battery-paths}; do
          if [ -w "$path" ]; then
            echo "$BATTERY_LEVEL" > "$path"
            ${pkgs.util-linux}/bin/logger -t battery-manager "Set battery threshold to $BATTERY_LEVEL% on $path"
            FOUND=true
            break
          fi
        done

        if [ "$FOUND" = false ]; then
          ${pkgs.util-linux}/bin/logger -t battery-manager "No writable battery threshold path found."
          exit 3
        fi
      '';

      batteryManagerFrontend = pkgs.writeShellApplication {
        name = "set-battery-threshold";
        runtimeInputs = [ pkgs.libnotify ];
        text = ''
          SUPPRESS_NOTIFICATIONS=false
          BATTERY_LEVEL=""

          print_error() { echo -e "$1" >&2; }

          send_notification() {
            local urgency="$1"
            local title="$2"
            local message="$3"
            if [ "$SUPPRESS_NOTIFICATIONS" = false ]; then
              "${pkgs.libnotify}/bin/notify-send" -u "$urgency" "$title" "$message"
            fi
          }

          if [ $# -eq 0 ]; then
            print_error "Usage: $0 [OPTIONS] <number>"
            exit 1
          fi

          while [[ $# -gt 0 ]]; do
            case "$1" in
              -q|--quiet)
                SUPPRESS_NOTIFICATIONS=true
                shift ;;
              *)
                BATTERY_LEVEL="$1"
                shift ;;
            esac
          done

          if ! [[ "$BATTERY_LEVEL" =~ ^[0-9]+$ ]] || [ "$BATTERY_LEVEL" -lt 0 ] || [ "$BATTERY_LEVEL" -gt 100 ]; then
            print_error "Battery level must be 0-100"
            exit 1
          fi

          echo "Setting battery threshold to $BATTERY_LEVEL%..."
          pkexec /run/wrappers/bin/battery-manager-backend "$BATTERY_LEVEL"
          BACKEND_EXIT=$?

          if [ $BACKEND_EXIT -eq 0 ]; then
            echo "Successfully set battery charging threshold to $BATTERY_LEVEL%."
            send_notification "normal" "Battery Threshold Updated" "Threshold set to $BATTERY_LEVEL%"
          else
            print_error "Error: Failed to set battery charging threshold."
            send_notification "critical" "Battery Threshold Failed" "Failed to set battery charging threshold to $BATTERY_LEVEL%"
            exit $BACKEND_EXIT
          fi
        '';
      };
    in
    {
      imports = [
        self.nixosModules.coreHardwareBluetooth
        self.nixosModules.coreHardwareGraphics
        self.nixosModules.coreHardwareNetwork
        self.nixosModules.coreHardwarePipewire
        self.nixosModules.coreHardwarePrinting
        self.nixosModules.coreHardwareWebcam
      ];

      options.services.battery-manager = {
        enable = lib.mkEnableOption "battery charge threshold manager";

        group = lib.mkOption {
          type = lib.types.str;
          default = "wheel";
          description = "Group allowed to set the battery threshold via polkit.";
        };

        battery-paths = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [
            "/sys/class/power_supply/BAT0/charge_control_end_threshold"
            "/sys/class/power_supply/BAT1/charge_control_end_threshold"
            "/sys/class/power_supply/BAT0/charge_stop_threshold"
            "/sys/class/power_supply/BAT1/charge_stop_threshold"
          ];
          description = "List of battery sysfs paths to attempt setting the threshold.";
        };
      };

      config = lib.mkMerge [
        (lib.mkIf cfg.enable {
          environment.systemPackages = [ batteryManagerFrontend ];

          security.wrappers."battery-manager-backend" = {
            owner = "root";
            group = "root";
            setuid = true;
            source = "${batteryManagerBackend}";
          };

          security.polkit.extraConfig = ''
            polkit.addRule(function(action, subject) {
              if (action.id == "org.freedesktop.policykit.exec" &&
                  action.lookup("program") == "/run/wrappers/bin/battery-manager-backend" &&
                  subject.isInGroup("${cfg.group}")) {
                return polkit.Result.YES;
              }
            });
          '';

          systemd.services.reload-polkit-battery = {
            description = "Reload polkit rules for battery manager";
            after = [ "polkit.service" ];
            wants = [ "polkit.service" ];
            serviceConfig.Type = "oneshot";
            serviceConfig.ExecStart = "${pkgs.systemd}/bin/systemctl reload polkit.service";
            wantedBy = [ "multi-user.target" ];
          };
        })

        {
          # Windows dual-boot: use local time for hardware clock
          time.hardwareClockInLocalTime = true;

          services.thermald.enable = true;

          # Power management
          powerManagement = {
            enable = true;
            cpuFreqGovernor = "schedutil";
          };

          zramSwap = {
            enable = true;
            priority = 100;
            memoryPercent = 30;
            algorithm = "zstd";
          };

          hardware.block.scheduler = {
            "nvme[0-9]*" = "kyber";
          };
        }
      ];
    };
}
