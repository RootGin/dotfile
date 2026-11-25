{
  config,
  lib,
  pkgs,
  ...
}:
let
  username = config.my.user.username;

  colors = config.lib.stylix.colors;

  wallpaperPath = "/home/${username}/.config/backgrounds/nord.png";
  browser = "zen-twilight";

  screenshotCmd =
    region:
    let
      grimSource = if region then ''-g \"$(${lib.getExe pkgs.slurp} -w 0)\" -'' else "-";
    in
    ''spawn "sh" "-c" "mkdir -p ~/Pictures/Screenshots && ${lib.getExe pkgs.grim} ${grimSource} | tee ~/Pictures/Screenshots/$(date '+%Y-%m-%d_%H-%M-%S').png | ${pkgs.wl-clipboard}/bin/wl-copy";'';

  workspaceBinds =
    let
      keys = lib.listToAttrs (
        map (n: {
          name = if n == 10 then "0" else toString n;
          value = toString n;
        }) (lib.range 1 10)
      );
      mkGroup =
        prefix: action: suffix:
        lib.concatStringsSep "\n                " (
          lib.mapAttrsToList (k: ws: "${prefix}+${k} { ${action} ${ws}${suffix}; }") keys
        );
    in
    {
      focus = mkGroup "Mod" "focus-workspace" "";
      moveColumn = mkGroup "Mod+Shift" "move-column-to-workspace" "";
      moveWindow = mkGroup "Mod+Alt" "move-window-to-workspace" " focus=false";
    };
in
{

  config = lib.mkIf config.my.desktop.enable {

    # ── Niri compositor (system integration) ────────────────
    programs.niri.enable = true;

    # ── Clipboard manager (Stash) ───────────────────────────
    services.stash-clipboard = {
      enable = true;
      package = pkgs.stash-clipboard.overrideAttrs (old: {
        buildInputs = (old.buildInputs or [ ]) ++ [ pkgs.sqlite ];
      });
      serviceArguments = [ "--persist" ];
    };

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

    # ── System packages ──────────────────────────────────────
    environment.systemPackages = with pkgs; [
      wl-clipboard
      xwayland-satellite
      grim
      slurp
      swappy
      libnotify
      brightnessctl
      gammastep
      playerctl
      pavucontrol
      zbar
      python3
      xarchiver
      tumbler
      imv
      yazi
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

      xdg.configFile."niri/config.kdl".source =
        let
          rawConfig = pkgs.writeText "niri-config.kdl" ''
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
                Mod+X { spawn "/home/${username}/.config/eww/draftpaper-eww/bin/draftpaper-eww" "lock"; }
                Mod+B { spawn "/home/${username}/.config/eww/draftpaper-eww/bin/draftpaper-eww" "title-block"; }
                Mod+V { toggle-window-floating; }
                Mod+Escape { spawn "${lib.getExe pkgs.python3}" "/home/${username}/.config/eww/draftpaper-eww/scripts/parked.py" "toggle"; }
                Mod+Right  { spawn "${lib.getExe pkgs.python3}" "/home/${username}/.config/eww/draftpaper-eww/scripts/parked.py" "next"; }
                Mod+Left   { spawn "${lib.getExe pkgs.python3}" "/home/${username}/.config/eww/draftpaper-eww/scripts/parked.py" "prev"; }
                Mod+Shift+R { spawn "end-rs" "history" "toggle"; }
                Alt+Return { fullscreen-window; }

                // ── Applications ────────────────────────────────────
                Mod+Q { spawn "kitty"; }
                Mod+F { spawn "${browser}"; }
                Mod+E { spawn "luciole"; }
                Mod+R { spawn "fuzzel"; }

                // ── Clipboard ───────────────────────────────────────
                Mod+Ctrl+V { spawn "sh" "-c" "sel=$(${lib.getExe config.services.stash-clipboard.package} list | ${lib.getExe pkgs.fuzzel} --dmenu --prompt=\"Clipboard: \") && [ -n \"$sel\" ] && printf '%s\\n' \"$sel\" | ${lib.getExe config.services.stash-clipboard.package} decode | ${pkgs.wl-clipboard}/bin/wl-copy"; }

                // ── Screenshots ────────────────────────────────────
                // Every bind saves to ~/Pictures/Screenshots AND copies to clipboard.
                Print { ${screenshotCmd false} }
                Mod+Shift+Print { ${screenshotCmd true} }
                Mod+Ctrl+S { ${screenshotCmd false} }
                Mod+Ctrl+Shift+S { ${screenshotCmd true} }
                Mod+Shift+E { spawn "sh" "-c" "${pkgs.wl-clipboard}/bin/wl-paste | ${lib.getExe pkgs.swappy} -f -"; }

                // ── QR code scanner ─────────────────────────────────
                Mod+Shift+Q { spawn "sh" "-c" "result=$(${lib.getExe pkgs.grim} -g \"$(${lib.getExe pkgs.slurp} -w 0)\" - | ${pkgs.zbar}/bin/zbarimg -q --raw - 2>/dev/null) && echo \"$result\" | ${pkgs.wl-clipboard}/bin/wl-copy && ${pkgs.libnotify}/bin/notify-send \"QR Code\" \"$result\" || ${pkgs.libnotify}/bin/notify-send \"QR Scan\" \"No QR code found\""; }

                // ── Focus navigation ────────────────────────────────
                Mod+H { focus-column-left; }
                Mod+L { focus-column-right; }
                Mod+J { focus-window-down; }
                Mod+K { focus-window-up; }

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
                Mod+Space { maximize-column; }

                // ── Workspace switching ─────────────────────────────
                ${workspaceBinds.focus}

                // ── Move column to workspace ────────────────────────
                ${workspaceBinds.moveColumn}

                // ── Move window to workspace (silent) ───────────────
                ${workspaceBinds.moveWindow}

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
            spawn-at-startup "${lib.getExe (
              pkgs.writeShellScriptBin "niri-restart-portals" ''
                i=0
                while ! busctl --user status org.gnome.Mutter.ScreenCast >/dev/null 2>&1; do
                  i=$((i + 1))
                  [ "$i" -ge 50 ] && exit 0
                  sleep 0.2
                done
                systemctl --user try-restart xdg-desktop-portal.service
              ''
            )}"

            xwayland-satellite {
                path "${lib.getExe pkgs.xwayland-satellite}"
            }

            environment {
                XDG_SESSION_DESKTOP "niri"
                GTK_USE_PORTAL "1"
                MOZ_ENABLE_WAYLAND "1"
                QT_QPA_PLATFORM "wayland"
                SDL_VIDEODRIVER "wayland,x11"
                CLUTTER_BACKEND "wayland"
                MOZ_DISABLE_RDD_SANDBOX "1"
            }
          '';
        in
        pkgs.runCommand "validated-niri-config.kdl"
          {
            nativeBuildInputs = [ pkgs.niri ];
          }
          ''
            niri validate -c ${rawConfig}
            cp ${rawConfig} $out
          '';
    };
  };
}
