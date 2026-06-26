# Niri Compositor — NixOS Module
#
# Uses niri-flake (sodiboo/niri-flake) for both system integration and
# typed programs.niri.settings (which auto-generates ~/.config/niri/config.kdl).
#
# Architecture:
#   NixOS level (programs.niri.enable) → system integration, session files
#   Home-manager level (programs.niri.settings) → compositor config (typed -> KDL)
#
# Keybindings ported from the Hyprland setup. Native Niri actions used where available
# (screenshot, screenshot-screen, move-window, resize-window) instead of external tools.
# Screen locker: swaylock (replaces hyprlock for wlroots compatibility).

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

      colors = config.lib.stylix.colors;

      wallpaperPath = "/home/${username}/.config/backgrounds/nord.png";
      browser = "zen-twilight";
    in
    {
      imports = [
        inputs.home-manager.nixosModules.home-manager
        niri-flake.nixosModules.niri
      ];

      # ── Niri compositor (system integration) ────────────────
      programs.niri.enable = true;

      # ── UWSM: user Wayland session manager for smooth app launching ──
      programs.uwsm = {
        enable = true;
        waylandCompositors = {
          niri = {
            prettyName = "Niri";
            comment = "Niri compositor managed by UWSM";
            binPath = "/run/current-system/sw/bin/niri-session";
          };
        };
      };

      # ── XDG Desktop Portal: niri compositor routes ──────────
      # ScreenCast/Screenshot use hyprland backend (wlr-screencopy protocol)
      # instead of gnome (which needs mutter/GNOME Shell).
      xdg.portal.extraPortals = [
        pkgs.xdg-desktop-portal-gnome
        pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal-hyprland
      ];
      xdg.portal.config.niri = {
        default = [ "gtk" ];
        "org.freedesktop.impl.portal.Access" = [ "gtk" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
        "org.freedesktop.impl.portal.Notification" = [ "gtk" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "hyprland" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "hyprland" ];
        "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
      };

      # ── Import niri.service + portal backend systemd user units
      systemd.packages = [
        config.programs.niri.package
        pkgs.xdg-desktop-portal-gtk
      ];

      # ── System packages ──────────────────────────────────────
      environment.systemPackages = with pkgs; [
        wl-clipboard
        xwayland-satellite
        grim
        slurp
        swappy
        libnotify
        brightnessctl
        playerctl
        pavucontrol
        swaylock
        fuzzel
        clipman
        zbar
        waybar
        xfce.thunar
        thunar-archive-plugin
        xarchiver
        xfce.thunar-volman
        xfce.tumbler
        gthumb
        yazi
        networkmanagerapplet
        zenity
      ];

      # ── Home Manager: user-level ──────────────────────────────
      home-manager.users.${username} = {
        programs.niri.settings = {
          prefer-no-csd = true;

          input = {
            focus-follows-mouse = {
              enable = true;
            };

            keyboard = {
              xkb = {
                layout = "us";
                options = "caps:escape";
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
            # ── System ──────────────────────────────────────────
            "Mod+C".action.close-window = [ ];
            "Mod+M".action.quit = [ ];
            "Mod+V".action.toggle-window-floating = [ ];
            "Mod+L".action.spawn = "swaylock";
            "Mod+Shift+R".action.spawn = "dunstctl history-pop";
            "Alt+Return".action.fullscreen-window = [ ];

            # ── Applications ────────────────────────────────────
            "Mod+Q".action.spawn = "kitty";
            "Mod+F".action.spawn = browser;
            "Mod+E".action.spawn = "thunar";
            "Mod+R".action.spawn = "fuzzel";

            # ── Screenshot (native Niri — saves to ~/Pictures/Screenshots/) ──
            "Print".action.screenshot = [ ];
            # Screenshot: interactive region to clipboard (grim+slurp)
            "Mod+Shift+Print".action.spawn = [
              "sh"
              "-c"
              "${lib.getExe pkgs.grim} -g \"$(${lib.getExe pkgs.slurp} -w 0)\" - | ${pkgs.wl-clipboard}/bin/wl-copy"
            ];

            # Screenshot: focused screen to clipboard (grim)
            "Mod+Ctrl+S".action.spawn = [
              "sh"
              "-c"
              "${lib.getExe pkgs.grim} -l 0 - | ${pkgs.wl-clipboard}/bin/wl-copy"
            ];

            # Screenshot: full display to clipboard (grim)
            "Mod+Ctrl+Shift+S".action.spawn = [
              "sh"
              "-c"
              "${lib.getExe pkgs.grim} -l 0 - | ${pkgs.wl-clipboard}/bin/wl-copy"
            ];

            # Screenshot: paste from clipboard to swappy editor
            "Mod+Shift+E".action.spawn = [
              "sh"
              "-c"
              "${pkgs.wl-clipboard}/bin/wl-paste | ${lib.getExe pkgs.swappy} -f -"
            ];

            # ── QR code scanner ──────────────────────────────────
            # Select area → decode QR → copy text → notify result
            "Mod+Shift+Q".action.spawn = [
              "sh"
              "-c"
              "result=$(${lib.getExe pkgs.grim} -g \"$(${lib.getExe pkgs.slurp} -w 0)\" - | ${pkgs.zbar}/bin/zbarimg -q --raw - 2>/dev/null) && echo \"$result\" | ${pkgs.wl-clipboard}/bin/wl-copy && ${pkgs.libnotify}/bin/notify-send \"QR Code\" \"$result\" || ${pkgs.libnotify}/bin/notify-send \"QR Scan\" \"No QR code found\""
            ];

            # ── Focus navigation (vim-style) ────────────────────
            "Mod+H".action.focus-column-left = [ ];
            "Mod+J".action.focus-window-down = [ ];
            "Mod+K".action.focus-window-up = [ ];
            # ── Arrow key focus ─────────────────────────────────
            "Mod+Left".action.focus-column-left = [ ];
            "Mod+Right".action.focus-column-right = [ ];
            "Mod+Up".action.focus-window-up = [ ];
            "Mod+Down".action.focus-window-down = [ ];

            # ── Move windows/columns ────────────────────────────
            "Mod+Shift+H".action.move-column-left = [ ];
            "Mod+Shift+L".action.move-column-right = [ ];
            "Mod+Shift+K".action.move-window-up = [ ];
            "Mod+Shift+J".action.move-window-down = [ ];
            "Mod+Shift+Left".action.move-column-left = [ ];
            "Mod+Shift+Right".action.move-column-right = [ ];
            "Mod+Shift+Up".action.move-window-up = [ ];
            "Mod+Shift+Down".action.move-window-down = [ ];

            # ── Resize windows (Mod+Alt+arrows, matching Hyprland) ──
            "Mod+Alt+Left".action.set-column-width = "-5%";
            "Mod+Alt+Right".action.set-column-width = "+5%";
            "Mod+Alt+Up".action.set-window-height = "-5%";
            "Mod+Alt+Down".action.set-window-height = "+5%";

            # ── Workspace switching ─────────────────────────────
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

            # ── Move column to workspace ────────────────────────
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

            # ── Move window to workspace (silent, keep focus) ───
            "Mod+Alt+1".action.move-window-to-workspace = [
              { focus = false; }
              1
            ];
            "Mod+Alt+2".action.move-window-to-workspace = [
              { focus = false; }
              2
            ];
            "Mod+Alt+3".action.move-window-to-workspace = [
              { focus = false; }
              3
            ];
            "Mod+Alt+4".action.move-window-to-workspace = [
              { focus = false; }
              4
            ];
            "Mod+Alt+5".action.move-window-to-workspace = [
              { focus = false; }
              5
            ];
            "Mod+Alt+6".action.move-window-to-workspace = [
              { focus = false; }
              6
            ];
            "Mod+Alt+7".action.move-window-to-workspace = [
              { focus = false; }
              7
            ];
            "Mod+Alt+8".action.move-window-to-workspace = [
              { focus = false; }
              8
            ];
            "Mod+Alt+9".action.move-window-to-workspace = [
              { focus = false; }
              9
            ];
            "Mod+Alt+0".action.move-window-to-workspace = [
              { focus = false; }
              10
            ];

            # ── Scratchpad (named workspace "magic") ────────────
            "Mod+S".action.focus-workspace = "magic";
            "Mod+Shift+S".action.move-column-to-workspace = "magic";

            # ── Audio ───────────────────────────────────────────
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

            # ── Brightness ──────────────────────────────────────
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

            # ── Media keys ──────────────────────────────────────
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

            # ── Scroll through apps on same workspace (mouse wheel) ──
            "Mod+WheelScrollDown".action.focus-column-right = [ ];
            "Mod+WheelScrollUp".action.focus-column-left = [ ];
            # Mod+Ctrl+Wheel → full workspace switching
            "Mod+Ctrl+WheelScrollDown".action.focus-workspace-down = [ ];
            "Mod+Ctrl+WheelScrollUp".action.focus-workspace-up = [ ];

            # Overview: show all workspaces and windows (like Mission Control)
            "Mod+Tab".action.toggle-overview = [ ];

            # ── Misc ────────────────────────────────────────────
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
                color = "#${colors.base09}";
              };
              inactive = {
                color = "#${colors.base03}";
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
            # Notify UWSM that the Wayland display is ready.
            # Without this, wayland-session-waitenv.service times out (10s)
            # and UWSM considers the session failed.
            {
              command = [
                "uwsm"
                "finalize"
              ];
            }
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
            # Clipboard manager — prevents wl-copy from locking the clipboard
            {
              command = [
                "${pkgs.clipman}/bin/clipman"
                "--daemon"
              ];
            }
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
            XDG_CURRENT_DESKTOP = "X-NIXOS-SYSTEMD-AWARE:niri";
            XDG_SESSION_DESKTOP = "niri";
            GTK_USE_PORTAL = "1";
            GDK_BACKEND = "wayland,x11";
            MOZ_ENABLE_WAYLAND = "1";
            QT_QPA_PLATFORM = "wayland";
            QT_QPA_PLATFORMTHEME = "qt5ct";
            QT_STYLE_OVERRIDE = "kvantum";
            SDL_VIDEODRIVER = "wayland,x11";
            CLUTTER_BACKEND = "wayland";
            MOZ_DISABLE_RDD_SANDBOX = "1";
          };
        };

      };

      # ── Wayland env vars (system-level) ─────────────────────
      environment.sessionVariables = {
        NIXOS_OZONE_WL = "1";
        XDG_CURRENT_DESKTOP = "X-NIXOS-SYSTEMD-AWARE:niri";
      };
    };
}
