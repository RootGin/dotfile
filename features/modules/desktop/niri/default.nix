# Niri Compositor — NixOS Module
#
# Uses niri-flake (sodiboo/niri-flake) for both system integration and
# typed programs.niri.settings (which auto-generates ~/.config/niri/config.kdl).
#
# Architecture:
#   NixOS level (programs.niri.enable) → system integration, session files
#   Home-manager level (programs.niri.settings) → compositor config (typed -> KDL)
#
# Keybindings and visual config ported from the previous Hyprland setup.
# Color scheme: Nord (base16).

{ self, inputs, ... }:
let
  niri-flake = inputs.niri;
in
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
      hostName = config.userOptions.hostName;

      # Nord base16 colors (no hash prefix)
      nord = {
        base00 = "2E3440";
        base01 = "3B4252";
        base02 = "434C5E";
        base03 = "4C566A";
        base04 = "D8DEE9";
        base05 = "E5E9F0";
        base06 = "ECEFF4";
        base07 = "8FBCBB";
        base08 = "88C0D0";
        base09 = "81A1C1"; # accent — focus ring
        base0A = "5E81AC";
        base0B = "BF616A";
        base0C = "D08770";
        base0D = "EBCB8B";
        base0E = "A3BE8C";
        base0F = "B48EAD";
      };

      wallpaperPath = "/home/${username}/.config/backgrounds/nord.png";
      browser = "zen-beta";
    in
    {
      imports = [
        inputs.home-manager.nixosModules.home-manager
        # niri-flake's NixOS module:
        #   - Provides programs.niri.enable / package
        #   - Sets up display manager session, portals, polkit, etc.
        #   - Auto-adds homeModules.config to home-manager.sharedModules
        niri-flake.nixosModules.niri
      ];

      # ── Niri compositor (system integration) ────────────────
      programs.niri.enable = true;

      # ── Disable UWSM (was used with Hyprland, not needed by Niri) ──
      programs.uwsm.enable = lib.mkDefault false;

      # ── System packages ──────────────────────────────────────
      environment.systemPackages = with pkgs; [
        wl-clipboard
        grim
        slurp
        swappy
        libnotify
        brightnessctl
        playerctl
        pavucontrol
        kdePackages.dolphin
        gthumb
        yazi
        networkmanagerapplet
        zenity
        kdePackages.kio-extras
      ];

      # ── Home Manager: user-level ──────────────────────────────
      # programs.niri.settings lives here because niri-flake defines it
      # via homeModules.config (auto-added to sharedModules by nixosModules.niri).
      home-manager.users.${username} = {
        # ── Niri compositor configuration (typed -> KDL) ──────
        programs.niri.settings = {
          prefer-no-csd = true;

          input = {
            focus-follows-mouse = {
              enable = true;
            };

            keyboard = {
              xkb = {
                layout = "us,ru,ua";
                options = "grp:alt_shift_toggle,caps:escape";
              };
              repeat-rate = 40;
              repeat-delay = 250;
            };

            touchpad = {
              natural-scroll = true;
              tap = true;
            };

            mouse = {
              accel-profile = "flat";
            };
          };

          binds = {
            # Terminal
            "Mod+Return".action.spawn = "kitty";

            # Close window
            "Mod+Q".action.close-window = [ ];

            # Browser
            "Mod+F".action.spawn = browser;

            # File manager
            "Mod+E".action.spawn = "dolphin";

            # App launcher (replaces hyprland's Super+R)
            "Mod+R".action.spawn = "vicinae toggle";

            # Toggle floating
            "Mod+V".action.toggle-window-floating = [ ];

            # Fullscreen
            "Mod+G".action.fullscreen-window = [ ];

            # Center column
            "Mod+C".action.center-column = [ ];

            # Screenshot: region to clipboard
            "Mod+Shift+S".action.spawn = [
              "sh"
              "-c"
              "${lib.getExe pkgs.grim} -g \"$(${lib.getExe pkgs.slurp} -w 0)\" - | ${pkgs.wl-clipboard}/bin/wl-copy"
            ];

            # Screenshot: full display to clipboard
            "Mod+Ctrl+S".action.spawn = [
              "sh"
              "-c"
              "${lib.getExe pkgs.grim} -l 0 - | ${pkgs.wl-clipboard}/bin/wl-copy"
            ];

            # Screenshot: paste to swappy editor
            "Mod+Shift+E".action.spawn = [
              "sh"
              "-c"
              "${pkgs.wl-clipboard}/bin/wl-paste | ${lib.getExe pkgs.swappy} -f -"
            ];

            # Lock screen
            "Mod+L".action.spawn = "hyprlock";

            # Quit niri
            "Mod+M".action.quit = [ ];

            # Focus navigation (vim-style)
            # Note: Mod+L not used for focus-right — conflicts with lock-screen binding above.
            # Use arrow keys or Mod+Right instead.
            "Mod+H".action.focus-column-left = [ ];
            "Mod+K".action.focus-window-up = [ ];
            "Mod+J".action.focus-window-down = [ ];

            # Arrow key focus
            "Mod+Left".action.focus-column-left = [ ];
            "Mod+Right".action.focus-column-right = [ ];
            "Mod+Up".action.focus-window-up = [ ];
            "Mod+Down".action.focus-window-down = [ ];

            # Move windows
            "Mod+Shift+H".action.move-column-left = [ ];
            "Mod+Shift+L".action.move-column-right = [ ];
            "Mod+Shift+K".action.move-window-up = [ ];
            "Mod+Shift+J".action.move-window-down = [ ];

            # Resize windows
            "Mod+Ctrl+H".action.set-column-width = "-5%";
            "Mod+Ctrl+L".action.set-column-width = "+5%";
            "Mod+Ctrl+J".action.set-window-height = "-5%";
            "Mod+Ctrl+K".action.set-window-height = "+5%";

            # Workspace switching
            "Mod+1".action.focus-workspace = 1;
            "Mod+2".action.focus-workspace = 2;
            "Mod+3".action.focus-workspace = 3;
            "Mod+4".action.focus-workspace = 4;
            "Mod+5".action.focus-workspace = 5;
            "Mod+6".action.focus-workspace = 6;
            "Mod+7".action.focus-workspace = 7;
            "Mod+8".action.focus-workspace = 8;
            "Mod+9".action.focus-workspace = 9;
            "Mod+0".action.focus-workspace = 10;

            # Move window to workspace
            "Mod+Shift+1".action.move-column-to-workspace = 1;
            "Mod+Shift+2".action.move-column-to-workspace = 2;
            "Mod+Shift+3".action.move-column-to-workspace = 3;
            "Mod+Shift+4".action.move-column-to-workspace = 4;
            "Mod+Shift+5".action.move-column-to-workspace = 5;
            "Mod+Shift+6".action.move-column-to-workspace = 6;
            "Mod+Shift+7".action.move-column-to-workspace = 7;
            "Mod+Shift+8".action.move-column-to-workspace = 8;
            "Mod+Shift+9".action.move-column-to-workspace = 9;
            "Mod+Shift+0".action.move-column-to-workspace = 10;

            # Audio: volume
            "XF86AudioRaiseVolume".action.spawn = [
              "wpctl"
              "set-volume"
              "-l"
              "1.4"
              "@DEFAULT_AUDIO_SINK@"
              "5%+"
            ];
            "XF86AudioLowerVolume".action.spawn = [
              "wpctl"
              "set-volume"
              "-l"
              "1.4"
              "@DEFAULT_AUDIO_SINK@"
              "5%-"
            ];
            "XF86AudioMute".action.spawn = [
              "wpctl"
              "set-mute"
              "@DEFAULT_AUDIO_SINK@"
              "toggle"
            ];
            "XF86AudioMicMute".action.spawn = [
              "wpctl"
              "set-mute"
              "@DEFAULT_AUDIO_SOURCE@"
              "toggle"
            ];

            # Brightness
            "XF86MonBrightnessUp".action.spawn = [
              "brightnessctl"
              "set"
              "10%+"
            ];
            "XF86MonBrightnessDown".action.spawn = [
              "brightnessctl"
              "set"
              "10%-"
            ];

            # Media keys
            "XF86AudioPlay".action.spawn = [
              "playerctl"
              "play-pause"
            ];
            "XF86AudioNext".action.spawn = [
              "playerctl"
              "next"
            ];
            "XF86AudioPrev".action.spawn = [
              "playerctl"
              "previous"
            ];

            # Scroll through workspaces
            "Mod+WheelScrollDown".action.focus-column-right = [ ];
            "Mod+WheelScrollUp".action.focus-column-left = [ ];
            "Mod+Ctrl+WheelScrollDown".action.focus-workspace-down = [ ];
            "Mod+Ctrl+WheelScrollUp".action.focus-workspace-up = [ ];

            # Toggle microphone
            "Mod+Shift+V".action.spawn = [
              "sh"
              "-c"
              "${pkgs.alsa-utils}/bin/amixer sset Capture toggle"
            ];
          };

          layout = {
            gaps = 5;

            focus-ring = {
              width = 2;
              active = {
                color = "#${nord.base09}";
              };
              inactive = {
                color = "#${nord.base03}";
              };
            };

            border = {
              width = 0;
            };
          };

          # Window rules
          window-rules = [
            # Always float pavucontrol
            {
              matches = [ { app-id = "pavucontrol"; } ];
              open-floating = true;
            }
          ];

          # Startup applications
          spawn-at-startup = [
            # Wallpaper
            {
              command = [
                (lib.getExe (
                  pkgs.writeShellScriptBin "niri-wallpaper" ''
                    ${lib.getExe pkgs.swaybg} -i ${wallpaperPath} -m fill
                  ''
                ))
              ];
            }
            # Notification daemon
            { command = [ "${pkgs.dunst}/bin/dunst" ]; }
            # Network manager applet
            { command = [ "${pkgs.networkmanagerapplet}/bin/nm-applet" ]; }
            # Polkit agent
            {
              command = [
                "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
              ];
            }
          ];

          # Cursor theme
          cursor = {
            theme = "Bibata-Modern-Ice";
            size = 25;
          };

          # XWayland via xwayland-satellite
          xwayland-satellite = {
            path = lib.getExe pkgs.xwayland-satellite;
          };

          # Compositor-level environment variables
          environment = {
            NIXOS_OZONE_WL = "1";
            XDG_CURRENT_DESKTOP = "niri";
            XDG_SESSION_DESKTOP = "niri";
            GTK_USE_PORTAL = "1";
            GDK_BACKEND = "wayland,x11";
            MOZ_ENABLE_WAYLAND = "1";
            QT_QPA_PLATFORM = "wayland";
            QT_QPA_PLATFORMTHEME = "qt5ct";
            QT_STYLE_OVERRIDE = "kvantum";
            SDL_VIDEODRIVER = "wayland";
            CLUTTER_BACKEND = "wayland";
            MOZ_DISABLE_RDD_SANDBOX = "1";
          };
        };

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
      };

      # ── Wayland env vars (system-level) ─────────────────────
      environment.sessionVariables = {
        NIXOS_OZONE_WL = "1";
        XDG_CURRENT_DESKTOP = "niri";
      };
    };
}
