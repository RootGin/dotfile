{ self, inputs, ... }:
{
  flake.nixosModules.modulesDesktopWaybar =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      username = config.userOptions.username;
      c = builtins.mapAttrs (_: v: "#${v}") config.lib.stylix.colors;

      waybarConfig = {
        layer = "top";
        position = "top";
        margin-top = 6;
        margin-bottom = 0;
        width = 1358;
        height = 28;

        modules-left = [
          "clock"
          "custom/power"
          "network"
          "bluetooth"
          "custom/microphone"
          "custom/vpn"
        ];

        modules-center = [
          "custom/workspace-1"
          "custom/workspace-2"
          "custom/asus-profile"
          "custom/workspace-3"
          "custom/workspace-4"
        ];

        modules-right = [
          "custom/battery"
          "custom/volume"
          "custom/brightness"
        ];

        clock = {
          tooltip-format = "{calendar}";
          format-alt = "  {:%a, %d %b %Y}";
          format = "[   {:%I:%M %p} ]";
        };

        network = {
          interface = "wlo1";
          format-wifi = "{icon}";
          format-icons = [ "[ 󰤯 ]" "[ 󰤟 ]" "[ 󰤢 ]" "[ 󰤥 ]" "[ 󰤨 ]" ];
          format-ethernet = "󰀂";
          format-alt = "[ 󱛇 ]";
          format-disconnected = "󰖪";
          tooltip-format-wifi = "{icon} {essid}\n⇣{bandwidthDownBytes}  ⇡{bandwidthUpBytes}";
          tooltip-format-ethernet = "󰀂  {ifname}\n⇣{bandwidthDownBytes}  ⇡{bandwidthUpBytes}";
          tooltip-format-disconnected = "Disconnected";
          on-click = "nm-connection-editor";
          interval = 5;
          nospacing = 1;
        };

        "keyboard-state" = {
          numlock = true;
          capslock = true;
          format = " {layout}";
        };

        bluetooth = {
          format = "{icon}";
          format-icons = {
            enabled = "[ 󰂯 ]";
            disabled = "[ 󰂲 ]";
          };
          on-click = "/etc/xdg/waybar/scripts/bluetooth-toggle.sh";
          tooltip-format = "Bluetooth is {status}";
          interval = 5;
        };

        "custom/asus-profile" = {
          exec = "/etc/xdg/waybar/scripts/asus-profile.sh";
          interval = 3;
          format = "{}";
          tooltip = true;
          tooltip-format = "Toggle ASUS profile";
          on-click = "/etc/xdg/waybar/scripts/cycle-profile.sh";
          signal = 8;
        };

        "custom/battery" = {
          exec = "/etc/xdg/waybar/scripts/battery.sh";
          return-type = "json";
          interval = 10;
          on-click = "xfce4-power-manager-settings";
        };

        battery = {
          format = "{icon}  {capacity}%";
          format-icons = {
            charging = [ "󰢜" "󰂆" "󰂇" "󰂈" "󰢝" "󰂉" "󰢞" "󰂊" "󰂋" "󰂅" ];
            default = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
          };
          format-full = "Charged ";
          interval = 5;
          states = {
            warning = 20;
            critical = 10;
          };
          tooltip = true;
        };

        "custom/microphone" = {
          exec = "/etc/xdg/waybar/scripts/mic.sh";
          interval = 1.1;
          tooltip = true;
          tooltip-format = "Mic Toggle";
          on-click = "wpctl set-mute @DEFAULT_SOURCE@ toggle";
        };

        "custom/brightness" = {
          exec = "/etc/xdg/waybar/scripts/brightness.sh";
          return-type = "json";
          interval = 2;
          on-click = "/etc/xdg/waybar/scripts/brightness-toggle.sh";
          on-scroll-up = "brightnessctl set +5%";
          on-scroll-down = "brightnessctl set 5%-";
        };

        backlight = {
          format = "󰛨  {percent}%";
          format-icons = [ "󰃞" "󰃟" "󰃠" "󰃝" "󰃜" "󰃛" ];
          class = "flicker-bar";
          on-click = "/etc/xdg/waybar/scripts/brightness-slider.sh";
        };

        "custom/workspace-1" = {
          exec = "/etc/xdg/waybar/scripts/workspaces/workspace-1.sh";
          interval = 1.2;
          on-click = "niri msg action focus-workspace 1";
          tooltip = "Switch to workspace 1";
        };
        "custom/workspace-2" = {
          exec = "/etc/xdg/waybar/scripts/workspaces/workspace-2.sh";
          interval = 1.3;
          on-click = "niri msg action focus-workspace 2";
          tooltip = "Switch to workspace 2";
        };
        "custom/workspace-3" = {
          exec = "/etc/xdg/waybar/scripts/workspaces/workspace-3.sh";
          interval = 1.4;
          on-click = "niri msg action focus-workspace 3";
          tooltip = "Switch to workspace 3";
        };
        "custom/workspace-4" = {
          exec = "/etc/xdg/waybar/scripts/workspaces/workspace-4.sh";
          interval = 1.5;
          on-click = "niri msg action focus-workspace 4";
          tooltip = "Switch to workspace 4";
        };

        "custom/volume" = {
          exec = "/etc/xdg/waybar/scripts/volume.sh";
          return-type = "json";
          interval = 1.6;
          on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          on-scroll-up = "wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+";
          on-scroll-down = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
        };

        "custom/vpn" = {
          exec = "/etc/xdg/waybar/scripts/protonvpn-status.sh";
          interval = 5;
          on-click = "/etc/xdg/waybar/scripts/protonvpn-toggle.sh";
          format = "{}";
          markup = "pango";
          tooltip = true;
          tooltip-format = "VPN Status / Toggle";
        };

        "custom/power" = {
          format = "[ 󰤆 ]";
          tooltip = true;
          tooltip-format = "Power Menu";
          on-click = "/etc/xdg/waybar/scripts/powermenu.sh";
        };

        "custom/squares" = {
          format = " ";
          tooltip = false;
        };
      };

      waybarStyle = ''
        /* ──────────────────────────────────────────────────────────────────────────
           °˖* ૮(  • ᴗ ｡)っ🍸  pewdiepie/archdaemon/dionysh  shhheersh
           Waybar CSS styling
           vers. 1.2  (scaled for 1368x768)
           ────────────────────────────────────────────────────────────────────────── */

        /* === Base Waybar Styling ================================================= */

        waybar * {
          border: 3px;
          border-radius: 3px;
          min-height: 0;
          font-family: "JetBrainsMono Nerd Font";
          font-size: 9px;
        }

        #waybar {
          background-color: ${c.base01};
          border-radius: 2px;
          opacity: 0.95;
        }

        window#waybar {
          background: ${c.base00};
          transition-property: background-color;
          transition-duration: 0.5s;
          color: ${c.base05};
          border: 2px solid ${c.base0D};
          border-left: 2px solid ${c.base0C};
          border-right: 2px solid ${c.base0C};
        }

        /* === Workspaces ========================================================== */

        #workspaces {
          background-color: transparent;
          padding-left: 24px;
        }

        #workspaces button {
          all: initial;
          min-width: 0;
          box-shadow: inherit;
          padding: 2px 4px;
          margin: 2px 1px;
          border-radius: 3px;
          background-color: ${c.base00};
          color: ${c.base0C};
        }

        #workspaces button.active {
          color: ${c.base09};
          background-color: ${c.base0C};
        }

        #workspaces button:hover {
          color: ${c.base00};
          background-color: ${c.base0C};
        }

        /* === Default Module Container Styling ==================================== */

        #custom-microphone,
        #bluetooth,
        #custom-bluetooth,
        #custom-brightness,
        #custom-volume,
        #custom-battery,
        #custom-power,
        #custom-asus-profile,
        #network,
        #battery,
        #pulseaudio,
        #backlight,
        #custom-vpn,
        #clock,
        #tray {
          padding: 2px 8px;
          margin: 2px 4px;
          background-color: ${c.base01};
          border: 1px solid ${c.base0D};
          border-radius: 2px;
          min-width: 0;
        }

        /* Right-side bar modules — fixed width so they never squish center */
        #custom-battery,
        #custom-volume,
        #custom-brightness {
          min-width: 105px;
        }

        #custom-battery label,
        #custom-volume label,
        #custom-brightness label {
          min-width: 0px;
        }

        /* Bluetooth — ensure icon always visible */
        #bluetooth {
          color: ${c.base0C};
        }

        #bluetooth.disabled {
          color: ${c.base09};
        }

        /* === Power Menu — cyan accent =========================================== */

        #custom-power {
          border: 1px solid ${c.base0C};
          color: ${c.base0C};
        }

        /* === Network — cyan accent ============================================== */

        #network {
          border: 1px solid ${c.base0C};
          color: ${c.base0C};
        }

        /* === Audio ============================================================== */

        #pulseaudio.muted {
          background-color: ${c.base08};
          color: ${c.base00};
        }

        /* === Bluetooth =========================================================== */

        #bluetooth.disabled {
          color: ${c.base09};
        }

        #custom-bluetooth {
          color: ${c.base0C};
          transition: color 0.2s ease-in-out;
        }

        /* === Network ============================================================= */

        #network.disconnected {
          background-color: ${c.base08};
          color: ${c.base00};
        }

        /* === Clock =============================================================== */

        #clock {
          font-weight: bold;
          font-size: 9px;
          color: ${c.base09};
        }

        /* === Asus Profile ======================================================== */

        #custom-asus-profile {
          font-weight: bold;
          font-size: 9px;
          color: ${c.base0A};
        }

        /* === VPN ================================================================= */

        #custom-vpn {
          font-weight: bold;
          font-size: 9px;
        }

        /* === Battery ============================================================= */

        #custom-battery {
          border-radius: 2px;
          font-weight: normal;
        }

        #custom-battery .battery-critical {
          background-color: ${c.base08};
          color: ${c.base05};
          padding: 1px 4px;
          border-radius: 4px;
          font-weight: bold;
        }

        #custom-battery .battery-warning {
          background-color: ${c.base09};
          color: ${c.base00};
          padding: 1px 4px;
          border-radius: 4px;
        }

        #custom-battery .battery-normal {
          color: ${c.base05};
        }

        /* === Brightness ========================================================== */

        #backlight {
          background-color: ${c.base01};
        }

        /* === Tray ================================================================ */

        #tray {
          padding: 2px 6px;
          background-color: ${c.base00};
        }

        /* === Custom Workspace Labels ============================================= */

        #custom-work-left,
        #custom-work-right {
          padding: 4px 5px;
          margin: 4px 2px;
        }

        #custom-workspace-1,
        #custom-workspace-2,
        #custom-workspace-3,
        #custom-workspace-4 {
          color: ${c.base0C};
        }

        #custom-workspace-1:hover,
        #custom-workspace-2:hover,
        #custom-workspace-3:hover,
        #custom-workspace-4:hover {
          color: ${c.base0C};
          transition: all 0.2s ease-in-out;
        }

        /* === Hover Effects ======================================================= */

        #custom-microphone:hover,
        #custom-volume:hover,
        #pulseaudio:hover,
        #network:hover,
        #custom-vpn:hover,
        #bluetooth:hover,
        #custom-bluetooth:hover,
        #custom-power:hover,
        #custom-asus-profile:hover,
        #custom-battery:hover,
        #battery:hover,
        #backlight:hover,
        #custom-brightness:hover,
        #clock:hover,
        #tray:hover {
          background-color: ${c.base02};
          border: 1px solid ${c.base0C};
          color: ${c.base0C};
          transition: all 0.2s ease-in-out;
        }

        /* === Tooltips ============================================================ */

        tooltip {
          color: ${c.base0C};
          background-color: ${c.base01};
          border: 1px solid ${c.base0C};
          font-weight: bold;
        }

        tooltip label {
          color: ${c.base0C};
        }
      '';
    in
    {
      # ── System packages ────────────────────────────────────
      environment.systemPackages = with pkgs; [
        waybar
        jq
        proton-vpn-cli
        power-profiles-daemon
        rofi
      ];

      # ── Waybar config, style, and scripts ──────────────────
      # Waybar falls back to /etc/xdg/waybar when ~/.config/waybar
      # doesn't exist, so this works system-wide without home-manager.
      environment.etc = {
        "xdg/waybar/config".text = builtins.toJSON waybarConfig;
        "xdg/waybar/style.css".text = waybarStyle;

        "xdg/waybar/scripts/asus-profile.sh" = {
          mode = "0555";
          text = ''
            #!/usr/bin/env bash
            # ── asus-profile.sh ───────────────────────────────────────
            # Description: Display current power profile with color
            # Usage: Called by Waybar `custom/asus-profile`
            # Dependencies: power-profiles-daemon (powerprofilesctl)
            # ──────────────────────────────────────────────────────────

            profile=$(powerprofilesctl get)

            case "$profile" in
              performance)
                text="RAZGON"
                fg="${c.base08}"
                ;;
              balanced)
                text="STABILIZATION"
                fg="${c.base09}"
                ;;
              power-saver)
                text="REACTOR SLEEP"
                fg="${c.base0C}"
                ;;
              *)
                text="ASUS ??"
                fg="${c.base05}"
                ;;
            esac

            echo "<span foreground='$fg'>$text</span>"
          '';
        };

        "xdg/waybar/scripts/battery.sh" = {
          mode = "0555";
          text = ''
            #!/usr/bin/env bash
            # ── battery.sh ─────────────────────────────────────────────
            # Compact output for 1368x768 bar (5-block ASCII bar, fixed width)

            capacity=$(cat /sys/class/power_supply/BAT0/capacity)
            status=$(cat /sys/class/power_supply/BAT0/status)

            time_to_empty=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | awk -F: '/time to empty/ {print $2}' | xargs)
            time_to_full=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | awk -F: '/time to full/ {print $2}' | xargs)

            charging_icons=(󰢜 󰂆 󰂇 󰂈 󰢝 󰂉 󰢞 󰂊 󰂋 󰂅)
            default_icons=(󰁺 󰁻 󰁼 󰁽 󰁾 󰁿 󰂀 󰂁 󰂂 󰁹)

            index=$((capacity / 10))
            [ $index -ge 10 ] && index=9

            if [[ "$status" == "Charging" ]]; then
                icon=''${charging_icons[$index]}
            elif [[ "$status" == "Full" ]]; then
                icon="󰂅"
            else
                icon=''${default_icons[$index]}
            fi

            # 5-block bar — ceil(capacity/20), clamped 0-5
            filled=$(( (capacity + 20) / 20 ))
            [ $filled -gt 5 ] && filled=5
            [ $filled -lt 0 ] && filled=0
            empty=$((5 - filled))
            bar=""
            pad=""
            for ((i=0; i<filled; i++)); do bar+="█"; done
            for ((i=0; i<empty;  i++)); do pad+="░"; done
            ascii_bar="[$bar$pad]"

            if [ "$capacity" -lt 20 ]; then
                fg="${c.base08}"
            elif [ "$capacity" -lt 55 ]; then
                fg="${c.base09}"
            else
                fg="${c.base0C}"
            fi

            # Fixed-width percentage: always 3 chars (padded with space)
            pct=$(printf "%3d%%" "$capacity")

            if [[ "$status" == "Charging" ]]; then
                tooltip="Battery: $capacity% (Charging)\nTime to full: ''${time_to_full:-N/A}"
            else
                tooltip="Battery: $capacity%\nTime remaining: ''${time_to_empty:-N/A}"
            fi

            echo "{\"text\":\"<span foreground='$fg'>$icon $ascii_bar $pct</span>\",\"tooltip\":\"$tooltip\"}"
          '';
        };

        "xdg/waybar/scripts/bluetooth-toggle.sh" = {
          mode = "0555";
          text = ''
            #!/usr/bin/env bash
            # ── bluetooth-toggle.sh ──────────────────────────────────────────────────────
            # Toggle Bluetooth on/off using rfkill.
            # Usage: Waybar `bluetooth` module :on-click
            # Output: (changes state only)
            # ─────────────────────────────────────────────────────────────────────────────

            if rfkill list bluetooth | grep -q "Soft blocked: yes"; then
                rfkill unblock bluetooth
            else
                rfkill block bluetooth
            fi
          '';
        };

        "xdg/waybar/scripts/brightness.sh" = {
          mode = "0555";
          text = ''
            #!/usr/bin/env bash
            # ── brightness.sh ─────────────────────────────────────────
            # Compact output for 1368x768 bar (5-block ASCII bar, fixed width)

            brightness=$(brightnessctl get)
            max_brightness=$(brightnessctl max)
            percent=$((brightness * 100 / max_brightness))

            # 5-block bar — ceil(percent/20), clamped 0-5
            filled=$(( (percent + 19) / 20 ))
            [ $filled -gt 5 ] && filled=5
            [ $filled -lt 0 ] && filled=0
            empty=$((5 - filled))
            bar=""
            pad=""
            for ((i=0; i<filled; i++)); do bar+="█"; done
            for ((i=0; i<empty;  i++)); do pad+="░"; done
            ascii_bar="[$bar$pad]"

            icon="󰛨"

            if [ "$percent" -lt 20 ]; then
                fg="${c.base08}"
            elif [ "$percent" -lt 55 ]; then
                fg="${c.base09}"
            else
                fg="${c.base0C}"
            fi

            device=$(brightnessctl --machine-readable | awk -F, 'NR==1 {print $1}')
            tooltip="Brightness: $percent%\nDevice: $device"

            # Fixed-width percentage
            pct=$(printf "%3d%%" "$percent")

            echo "{\"text\":\"<span foreground='$fg'>$icon $ascii_bar $pct</span>\",\"tooltip\":\"$tooltip\"}"
          '';
        };

        "xdg/waybar/scripts/brightness-toggle.sh" = {
          mode = "0555";
          text = ''
            #!/usr/bin/env bash
            # ── brightness-toggle.sh ─────────────────────────────
            # Description: Cycle screen brightness between 30%, 60%, and 100%
            # Usage: Waybar `custom/brightness` on-click
            # Dependencies: brightnessctl
            # ─────────────────────────────────────────────────────

            current=$(brightnessctl get)
            max=$(brightnessctl max)
            percent=$((current * 100 / max))

            if [ "$percent" -lt 45 ]; then
              brightnessctl set 60%
            elif [ "$percent" -lt 85 ]; then
              brightnessctl set 100%
            else
              brightnessctl set 30%
            fi
          '';
        };

        "xdg/waybar/scripts/cycle-profile.sh" = {
          mode = "0555";
          text = ''
            #!/usr/bin/env bash
            # ── cycle-profile.sh ───────────────────────────────────────
            # Description: Cycle power-profiles-daemon profile on click
            # Usage: Called by Waybar `custom/asus-profile` on-click
            # Dependencies: power-profiles-daemon (powerprofilesctl)
            # ────────────────────────────────────────────────────────────

            current=$(powerprofilesctl get)

            case "$current" in
              performance)
                next="power-saver"
                ;;
              power-saver)
                next="balanced"
                ;;
              balanced)
                next="performance"
                ;;
              *)
                next="balanced"
                ;;
            esac

            powerprofilesctl set "$next"

            # Tell Waybar to refresh the module immediately instead of waiting for interval
            pkill -RTMIN+8 waybar
          '';
        };

        "xdg/waybar/scripts/mic.sh" = {
          mode = "0555";
          text = ''
            #!/usr/bin/env bash
            # ── mic.sh ─────────────────────────────────────────────────
            # Description: Shows microphone mute/unmute status with icon
            # Usage: Called by Waybar `custom/microphone` module every 1s
            # Dependencies: wpctl (PipeWire)
            # ───────────────────────────────────────────────────────────

            status=$(wpctl get-volume @DEFAULT_SOURCE@)

            if echo "$status" | grep -q 'MUTED'; then
              # Muted → mic-off icon
              echo "<span foreground='${c.base09}'>[ 󰍭 ]</span>"
            else
              # Active → mic-on icon
              echo "<span foreground='${c.base0C}'>[ 󰍬 ]</span>"
            fi
          '';
        };

        # Renamed from nordvpn-status.sh → protonvpn-status.sh
        "xdg/waybar/scripts/protonvpn-status.sh" = {
          mode = "0555";
          text = ''
            #!/usr/bin/env bash
            # ── protonvpn-status.sh ────────────────────────────────────
            # Description: Checks ProtonVPN connection status
            # Usage: Called by Waybar `custom/vpn` every 5s
            # Dependencies: protonvpn (proton-vpn-cli)

            PROTONVPN=$(ls /nix/store/*proton-vpn-cli*/bin/protonvpn 2>/dev/null | head -1)
            CONNECTING_LOCK="/tmp/protonvpn-connecting"
            DISCONNECTING_LOCK="/tmp/protonvpn-disconnecting"

            if [[ -z "$PROTONVPN" ]]; then
              echo "<span foreground='${c.base08}'>[ФАНТОМ]: NO CLI</span>"
              exit 0
            fi

            if [[ -f "$CONNECTING_LOCK" ]]; then
              echo "<span foreground='${c.base0A}'>[ФАНТОМ]: CONNECTING...</span>"
              exit 0
            fi

            if [[ -f "$DISCONNECTING_LOCK" ]]; then
              echo "<span foreground='${c.base0A}'>[ФАНТОМ]: DISCONNECTING...</span>"
              exit 0
            fi

            status=$("$PROTONVPN" status 2>/dev/null)

            if echo "$status" | grep -qi "^Status: Connected"; then
              server=$(echo "$status" | awk '/^Server:/ {print $2}')
              [[ -z "$server" ]] && server="UNKNOWN"
              echo "<span foreground='${c.base09}'>[ФАНТОМ]: $server</span>"
            else
              echo "<span foreground='${c.base08}'>[ФАНТОМ]: KAPUTT</span>"
            fi
          '';
        };

        # Renamed from nordvpn-toggle.sh → protonvpn-toggle.sh
        "xdg/waybar/scripts/protonvpn-toggle.sh" = {
          mode = "0555";
          text = ''
            #!/usr/bin/env bash
            # ── protonvpn-toggle.sh ────────────────────────────────────
            # Description: Toggle ProtonVPN on/off, writes lockfile while connecting/disconnecting
            # Usage: Called by Waybar `custom/vpn` on click
            # Dependencies: protonvpn (proton-vpn-cli)

            PROTONVPN=$(ls /nix/store/*proton-vpn-cli*/bin/protonvpn 2>/dev/null | head -1)
            CONNECTING_LOCK="/tmp/protonvpn-connecting"
            DISCONNECTING_LOCK="/tmp/protonvpn-disconnecting"

            [[ -z "$PROTONVPN" ]] && exit 1

            # Ignore clicks while already transitioning
            [[ -f "$CONNECTING_LOCK" || -f "$DISCONNECTING_LOCK" ]] && exit 0

            status=$("$PROTONVPN" status 2>/dev/null)

            if echo "$status" | grep -qi "^Status: Connected"; then
              touch "$DISCONNECTING_LOCK"
              "$PROTONVPN" disconnect &>/dev/null
              rm -f "$DISCONNECTING_LOCK"
            else
              touch "$CONNECTING_LOCK"
              "$PROTONVPN" connect &>/dev/null
              rm -f "$CONNECTING_LOCK"
            fi
          '';
        };

        "xdg/waybar/scripts/powermenu.sh" = {
          mode = "0555";
          text = ''
            #!/usr/bin/env bash
            # ─────────────────────────────────────────────────────────────────────────────
            #  Rofi Power Menu — niri
            # ─────────────────────────────────────────────────────────────────────────────

            rofi_command="rofi -dmenu -p Power"
            options="Shutdown\nReboot\nLogout\nSuspend\nLock"

            chosen="$(echo -e "$options" | $rofi_command)"
            case $chosen in
                Shutdown) systemctl poweroff ;;
                Reboot)   systemctl reboot ;;
                Logout)   niri msg action quit ;;
                Suspend)  systemctl suspend ;;
                Lock)     ~/.config/hyprlock/lock.sh ;;
            esac
          '';
        };

        "xdg/waybar/scripts/volume.sh" = {
          mode = "0555";
          text = ''
            #!/usr/bin/env bash
            # ── volume.sh ─────────────────────────────────────────────
            # Description: Shows current audio volume with ASCII bar + tooltip
            # Usage: Waybar `custom/volume` every 1s
            # Dependencies: wpctl, awk, seq, printf
            # ───────────────────────────────────────────────────────────

            # Get raw volume and convert to int using awk
            vol_raw=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{ print $2 }')
            vol_int=$(awk -v vol="$vol_raw" 'BEGIN { print int(vol * 100) }')

            # Check mute status
            is_muted=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED && echo true || echo false)

            # Get default sink description (human-readable)
            sink=$(wpctl status | awk '/Sinks:/,/Sources:/' | grep '\*' | cut -d'.' -f2- | sed 's/^\s*//; s/\[.*//')

            # Icon logic
            if [ "$is_muted" = true ]; then
              icon=""
              vol_int=0
            elif [ "$vol_int" -lt 50 ]; then
              icon=""
            else
              icon=""
            fi

            # Cap the volume value at 100 for the ASCII bar calculation so it never exceeds 5 blocks
            vol_for_bar=$vol_int
            if [ "$vol_for_bar" -gt 100 ]; then
              vol_for_bar=100
            fi

            # ASCII bar calculation (based on capped 100% max)
            filled=$((vol_for_bar / 20))
            empty=$((5 - filled))

            # Ensure sequence doesn't break if filled is 0
            if [ "$filled" -gt 0 ]; then
              bar=$(printf '█%.0s' $(seq 1 $filled))
            else
              bar=""
            fi

            if [ "$empty" -gt 0 ]; then
              pad=$(printf '░%.0s' $(seq 1 $empty))
            else
              pad=""
            fi

            ascii_bar="[$bar$pad]"

            # Color logic - Tiered colors based on volume percentage
            if [ "$is_muted" = true ]; then
              fg="${c.base03}" # Dim gray for muted state
            elif [ "$vol_int" -gt 100 ]; then
              fg="${c.base08}" # Red for volume above 100%
            elif [ "$vol_int" -ge 50 ]; then
              fg="${c.base0C}" # Cyan for 50% to 100%
            else
              fg="${c.base09}" # Orange for above 0% to 49%
            fi

            # Tooltip text
            if [ "$is_muted" = true ]; then
              tooltip="Audio: Muted\nOutput: $sink"
            else
              tooltip="Audio: $vol_int%\nOutput: $sink"
            fi

            # Final clean JSON output string for Waybar
            text_output="<span foreground='$fg'>$icon $ascii_bar ''${vol_int}%</span>"

            echo "{\"text\":\"$text_output\",\"tooltip\":\"$tooltip\"}"
          '';
        };

        "xdg/waybar/scripts/workspaces/workspace-1.sh" = {
          mode = "0555";
          text = ''
            #!/usr/bin/env bash
            # workspace-1.sh — highlight workspace 1 if active (niri)

            active=$(niri msg workspaces 2>/dev/null | awk '/^\s*\*/ {print $2}')

            if [ "$active" = "1" ]; then
              echo "[<span foreground='${c.base09}'>●</span>]"
            else
              echo "[А]"
            fi
          '';
        };

        "xdg/waybar/scripts/workspaces/workspace-2.sh" = {
          mode = "0555";
          text = ''
            #!/usr/bin/env bash
            # workspace-2.sh — highlight workspace 2 if active (niri)

            active=$(niri msg workspaces 2>/dev/null | awk '/^\s*\*/ {print $2}')

            if [ "$active" = "2" ]; then
              echo "[<span foreground='${c.base09}'>●</span>]"
            else
              echo "[Б]"
            fi
          '';
        };

        "xdg/waybar/scripts/workspaces/workspace-3.sh" = {
          mode = "0555";
          text = ''
            #!/usr/bin/env bash
            # workspace-3.sh — highlight workspace 3 if active (niri)

            active=$(niri msg workspaces 2>/dev/null | awk '/^\s*\*/ {print $2}')

            if [ "$active" = "3" ]; then
              echo "[<span foreground='${c.base09}'>●</span>]"
            else
              echo "[В]"
            fi
          '';
        };

        "xdg/waybar/scripts/workspaces/workspace-4.sh" = {
          mode = "0555";
          text = ''
            #!/usr/bin/env bash
            # workspace-4.sh — highlight workspace 4 if active (niri)

            active=$(niri msg workspaces 2>/dev/null | awk '/^\s*\*/ {print $2}')

            if [ "$active" = "4" ]; then
              echo "[<span foreground='${c.base09}'>●</span>]"
            else
              echo "[Г]"
            fi
          '';
        };
      };
    };
}
