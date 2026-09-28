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
      hostName = config.userOptions.hostName;

      colors = config.lib.stylix.colors;

      wallpaperPath = "/home/${username}/.config/backgrounds/nord.png";
      browser = "zen-twilight";
    in
    {
      imports = [
        inputs.home-manager.nixosModules.home-manager
      ];

      # ── Niri compositor (system integration) ────────────────
      programs.niri.enable = true;

      # ── UWSM: user Wayland session manager ───────────────────
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

      # ── XDG Desktop Portal ───────────────────────────────────
      xdg.portal = {
        enable = true;
        xdgOpenUsePortal = true;
        extraPortals = [
          pkgs.xdg-desktop-portal-gtk
          pkgs.xdg-desktop-portal-gnome
        ];
        config.niri = lib.mkForce {
          default = [ "gtk" ];
          "org.freedesktop.impl.portal.Access" = [ "gtk" ];
          "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
          "org.freedesktop.impl.portal.Notification" = [ "gtk" ];
          "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
          "org.freedesktop.impl.portal.Screenshot" = [ "gnome" ];
          "org.freedesktop.impl.portal.Settings" = [
            "gtk"
            "gnome"
          ];
          "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
        };
      };

      # ── Systemd user units integration ───────────────────────
      systemd.packages = [
        pkgs.niri
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
        clipman
        zbar
        # waybar
        thunar
        thunar-archive-plugin
        xarchiver
        thunar-volman
        tumbler
        gthumb
        yazi
        networkmanagerapplet
        zenity
      ];

      # ── Home Manager: Raw KDL Config Generator ──────────────
      home-manager.users.${username} = {
        programs.fuzzel = {
          enable = true;
          settings = {
            main = {
              lines = 15;
              width = 45;
              horizontal-pad = 20;
              vertical-pad = 12;
              inner-pad = 8;
              line-height = 22;
              layer = "overlay";
            };
            border = {
              width = 2;
              radius = 8;
            };
          };
        };

        services.swayidle = {
          enable = true;
          events = {
            after-resume = "${lib.getExe pkgs.niri} msg action power-on-monitors";
          };
        };

        services.hyprpolkitagent.enable = true;

        xdg.configFile."niri/config.kdl".text = ''
          prefer-no-csd

          input {
              focus-follows-mouse
              keyboard {
                  xkb {
                      layout "us"
                      options "caps:escape"
                  }
                  repeat-rate 40
                  repeat-delay 250
              }
              touchpad {
                  natural-scroll
                  tap
              }
              mouse {
                  accel-profile "flat"
              }
          }

          binds {
              // ── System ──────────────────────────────────────────
              Mod+C { close-window; }
              Mod+M { spawn "/home/${username}/.config/eww/Phobos-dev/scripts/powermenu.sh" "show"; }
              Mod+V { toggle-window-floating; }
              Mod+Shift+R { spawn "dunstctl" "history-pop"; }
              Alt+Return { fullscreen-window; }

              // ── Applications ────────────────────────────────────
              Mod+Q { spawn "kitty"; }
              Mod+F { spawn "${browser}"; }
              Mod+E { spawn "thunar"; }
              Mod+R { spawn "fuzzel"; }

              // ── Screenshots ────────────────────────────────────
              // Every bind saves to ~/Pictures/Screenshots AND copies to clipboard.
              Print { spawn "sh" "-c" "mkdir -p ~/Pictures/Screenshots && ${lib.getExe pkgs.grim} - | tee ~/Pictures/Screenshots/$(date '+%Y-%m-%d_%H-%M-%S').png | ${pkgs.wl-clipboard}/bin/wl-copy"; }
              Mod+Shift+Print { spawn "sh" "-c" "mkdir -p ~/Pictures/Screenshots && ${lib.getExe pkgs.grim} -g \"$(${lib.getExe pkgs.slurp} -w 0)\" - | tee ~/Pictures/Screenshots/$(date '+%Y-%m-%d_%H-%M-%S').png | ${pkgs.wl-clipboard}/bin/wl-copy"; }
              Mod+Ctrl+S { spawn "sh" "-c" "mkdir -p ~/Pictures/Screenshots && ${lib.getExe pkgs.grim} - | tee ~/Pictures/Screenshots/$(date '+%Y-%m-%d_%H-%M-%S').png | ${pkgs.wl-clipboard}/bin/wl-copy"; }
              Mod+Ctrl+Shift+S { spawn "sh" "-c" "mkdir -p ~/Pictures/Screenshots && ${lib.getExe pkgs.grim} -g \"$(${lib.getExe pkgs.slurp} -w 0)\" - | tee ~/Pictures/Screenshots/$(date '+%Y-%m-%d_%H-%M-%S').png | ${pkgs.wl-clipboard}/bin/wl-copy"; }
              Mod+Shift+E { spawn "sh" "-c" "${pkgs.wl-clipboard}/bin/wl-paste | ${lib.getExe pkgs.swappy} -f -"; }

              // ── QR code scanner ─────────────────────────────────
              Mod+Shift+Q { spawn "sh" "-c" "result=$(${lib.getExe pkgs.grim} -g \"$(${lib.getExe pkgs.slurp} -w 0)\" - | ${pkgs.zbar}/bin/zbarimg -q --raw - 2>/dev/null) && echo \"$result\" | ${pkgs.wl-clipboard}/bin/wl-copy && ${pkgs.libnotify}/bin/notify-send \"QR Code\" \"$result\" || ${pkgs.libnotify}/bin/notify-send \"QR Scan\" \"No QR code found\""; }

              // ── Focus navigation ────────────────────────────────
              Mod+H { focus-column-left; }
              Mod+J { focus-window-down; }
              Mod+K { focus-window-up; }
              Mod+Left { focus-column-left; }
              Mod+Right { focus-column-right; }
              Mod+Up { focus-window-up; }
              Mod+Down { focus-window-down; }

              // ── Move windows/columns ────────────────────────────
              Mod+Shift+H { move-column-left; }
              Mod+Shift+L { move-column-right; }
              Mod+Shift+K { move-window-up; }
              Mod+Shift+J { move-window-down; }
              Mod+Shift+Left { move-column-left; }
              Mod+Shift+Right { move-column-right; }
              Mod+Shift+Up { move-window-up; }
              Mod+Shift+Down { move-window-down; }

              // ── Resize windows ──────────────────────────────────
              Mod+Alt+Left { set-column-width "-5%"; }
              Mod+Alt+Right { set-column-width "+5%"; }
              Mod+Alt+Up { set-window-height "-5%"; }
              Mod+Alt+Down { set-window-height "+5%"; }

              // ── Workspace switching ─────────────────────────────
              Mod+1 { focus-workspace 1; }
              Mod+2 { focus-workspace 2; }
              Mod+3 { focus-workspace 3; }
              Mod+4 { focus-workspace 4; }
              Mod+5 { focus-workspace 5; }
              Mod+6 { focus-workspace 6; }
              Mod+7 { focus-workspace 7; }
              Mod+8 { focus-workspace 8; }
              Mod+9 { focus-workspace 9; }
              Mod+0 { focus-workspace 10; }

              // ── Move column to workspace ────────────────────────
              Mod+Shift+1 { move-column-to-workspace 1; }
              Mod+Shift+2 { move-column-to-workspace 2; }
              Mod+Shift+3 { move-column-to-workspace 3; }
              Mod+Shift+4 { move-column-to-workspace 4; }
              Mod+Shift+5 { move-column-to-workspace 5; }
              Mod+Shift+6 { move-column-to-workspace 6; }
              Mod+Shift+7 { move-column-to-workspace 7; }
              Mod+Shift+8 { move-column-to-workspace 8; }
              Mod+Shift+9 { move-column-to-workspace 9; }
              Mod+Shift+0 { move-column-to-workspace 10; }

              // ── Move window to workspace (silent) ───────────────
              Mod+Alt+1 { move-window-to-workspace 1 focus=false; }
              Mod+Alt+2 { move-window-to-workspace 2 focus=false; }
              Mod+Alt+3 { move-window-to-workspace 3 focus=false; }
              Mod+Alt+4 { move-window-to-workspace 4 focus=false; }
              Mod+Alt+5 { move-window-to-workspace 5 focus=false; }
              Mod+Alt+6 { move-window-to-workspace 6 focus=false; }
              Mod+Alt+7 { move-window-to-workspace 7 focus=false; }
              Mod+Alt+8 { move-window-to-workspace 8 focus=false; }
              Mod+Alt+9 { move-window-to-workspace 9 focus=false; }
              Mod+Alt+0 { move-window-to-workspace 10 focus=false; }

              // ── Scratchpad ──────────────────────────────────────
              Mod+S { focus-workspace "magic"; }
              Mod+Shift+S { move-column-to-workspace "magic"; }

              // ── Audio ───────────────────────────────────────────
              XF86AudioRaiseVolume { spawn "wpctl" "set-volume" "-l" "1.4" "@DEFAULT_AUDIO_SINK@" "5%+"; }
              XF86AudioLowerVolume { spawn "wpctl" "set-volume" "-l" "1.4" "@DEFAULT_AUDIO_SINK@" "5%-"; }
              XF86AudioMute { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }
              XF86AudioMicMute { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"; }

              // ── Brightness ──────────────────────────────────────
              XF86MonBrightnessUp { spawn "brightnessctl" "set" "10%+"; }
              XF86MonBrightnessDown { spawn "brightnessctl" "set" "10%-"; }

              // ── Media keys ──────────────────────────────────────
              XF86AudioPlay { spawn "playerctl" "play-pause"; }
              XF86AudioNext { spawn "playerctl" "next"; }
              XF86AudioPrev { spawn "playerctl" "previous"; }

              // ── Mouse wheel ─────────────────────────────────────
              Mod+WheelScrollDown { focus-column-right; }
              Mod+WheelScrollUp { focus-column-left; }
              Mod+Ctrl+WheelScrollDown { focus-workspace-down; }
              Mod+Ctrl+WheelScrollUp { focus-workspace-up; }

              // ── Overview ────────────────────────────────────────
              Mod+Tab { toggle-overview; }

              // ── Misc ────────────────────────────────────────────
              Mod+Shift+V { spawn "sh" "-c" "${pkgs.alsa-utils}/bin/amixer sset Capture toggle"; }
          }

          layout {
              // top/right/bottom/left gap around and between windows, logical px
              gaps 16
              focus-ring {
                  width 2
                  active-color "#${colors.base09}"
                  inactive-color "#${colors.base03}"
              }
              border {
                  width 0
              }
          }

          blur {
              passes 3
              offset 3.0
          }

          window-rule {
              match app-id="pavucontrol"
              open-floating true
          }

          layer-rule {
              match namespace="^phobos-powermenu$"

              background-effect {
                  blur true
                  xray false
              }
          }

          spawn-at-startup "uwsm" "finalize"
          spawn-at-startup "${lib.getExe (pkgs.writeShellScriptBin "niri-wallpaper" "${lib.getExe pkgs.swaybg} -i ${wallpaperPath} -m fill")}"
          spawn-at-startup "${pkgs.dunst}/bin/dunst"
          spawn-at-startup "${pkgs.clipman}/bin/clipman" "--daemon"
          spawn-at-startup "${pkgs.networkmanagerapplet}/bin/nm-applet"
          spawn-at-startup "${lib.getExe (pkgs.writeShellScriptBin "niri-restart-portals" "while ! busctl --user status org.gnome.Mutter.ScreenCast >/dev/null 2>&1; do sleep 0.2; done; systemctl --user restart xdg-desktop-portal.service")}"

          cursor {
              xcursor-theme "GoogleDot-White"
              xcursor-size 25
          }

          xwayland-satellite {
              path "${lib.getExe pkgs.xwayland-satellite}"
          }

          environment {
              NIXOS_OZONE_WL "1"
              XDG_CURRENT_DESKTOP "X-NIXOS-SYSTEMD-AWARE:niri"
              XDG_SESSION_DESKTOP "niri"
              GTK_USE_PORTAL "1"
              MOZ_ENABLE_WAYLAND "1"
              QT_QPA_PLATFORM "wayland"
              QT_QPA_PLATFORMTHEME "qt5ct"
              QT_STYLE_OVERRIDE "kvantum"
              SDL_VIDEODRIVER "wayland,x11"
              CLUTTER_BACKEND "wayland"
              MOZ_DISABLE_RDD_SANDBOX "1"
          }
        '';
      };

      # ── System-level environment variables ─────────────────
      environment.sessionVariables = {
        NIXOS_OZONE_WL = "1";
        XDG_CURRENT_DESKTOP = "X-NIXOS-SYSTEMD-AWARE:niri";
      };
    };
}
