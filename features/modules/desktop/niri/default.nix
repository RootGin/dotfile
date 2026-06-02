# Niri Compositor — NixOS Module
#
# Niri is a scrollable-tiling Wayland compositor.
# The actual compositor configuration is baked into the binary
# via wrapper-modules (see niri-wrapper.nix).
#
# This module handles system-level integration:
#   - programs.niri (session file, DBus activation)
#   - System packages
#   - Home-manager integration (hyprlock, hypridle)

{ self, inputs, ... }:
{
  flake.nixosModules.modulesDesktopNiri =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      username = config.userOptions.username;
      system = pkgs.stdenv.hostPlatform.system;
      hostName = config.userOptions.hostName;
    in
    {
      imports = [ inputs.home-manager.nixosModules.home-manager ];

      # ── Niri compositor ──────────────────────────────────────
      programs.niri = {
        enable = true;
        package = self.packages.${system}.niri;
      };

      # ── Disable UWSM (was used with Hyprland, not needed by Niri) ──
      programs.uwsm.enable = lib.mkDefault false;

      # ── System packages ──────────────────────────────────────
      environment.systemPackages = with pkgs; [
        # Wayland tools
        wl-clipboard
        grim
        slurp
        swappy
        libnotify
        brightnessctl
        playerctl
        pavucontrol

        # Apps
        kdePackages.dolphin
        gthumb
        yazi
        networkmanagerapplet
        zenity
        kdePackages.kio-extras
      ];

      # ── Home Manager: user-level ──────────────────────────────
      home-manager.users.${username} = {
        # hyprlock — works on any Wayland compositor
        programs.hyprlock.enable = true;

        # hypridle — DBus idle inhibitor, compositor-agnostic
        services.hypridle = lib.mkIf (hostName == "Laptop") {
          enable = true;
          settings = {
            general = {
              after_sleep_cmd = "niri msg action power-on-monitors";
              ignore_dbus_inhibit = false;
              lock_cmd = "hyprlock";
            };
            listener = [
              {
                timeout = 400;
                on-timeout = "hyprlock";
              }
              {
                timeout = 180;
                on-timeout = "niri msg action power-off-monitors";
                on-resume = "niri msg action power-on-monitors";
              }
            ];
          };
        };

        # GTK theming (stylix handles the rest)
        gtk = {
          enable = true;
          theme = {
            package = pkgs.nordic;
            name = "Nordic";
          };
        };
      };

      # ── Wayland env vars ─────────────────────────────────────
      environment.sessionVariables = {
        NIXOS_OZONE_WL = "1";
        XDG_CURRENT_DESKTOP = "niri";
      };
    };
}
