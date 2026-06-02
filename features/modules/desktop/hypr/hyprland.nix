# Hyprland Window Manager Configuration
#
# This module configures Hyprland, a dynamic tiling Wayland compositor.
# Hyprland provides smooth animations, dynamic tiling, and extensive customization.
#
# Key Features:
#   - Dynamic tiling with dwindle layout
#   - Arrow key navigation
#   - Multi-monitor support (configured in monitors.nix)
#   - XWayland support for legacy X11 applications
#   - Integration with systemd and XDG portals
#
# Keybindings Overview:
#   Super + Q       = Terminal
#   Super + F       = Browser
#   Super + E       = File Manager
#   Super + R       = App Menu
#   Super + C       = Close Window
#   Super + L       = Lock Screen
#   Super + M       = Power Menu
#   Super + J       = Toggle Split
#   Super + V       = Toggle Floating
#   Super + P       = Pseudo Tiling
#   Super + S       = Scratchpad
#   Super + arrows  = Navigate Windows
#   Super + Shift + arrows = Move Windows
#   Super + Alt + arrows   = Resize Windows
#   Super + 1-9     = Switch Workspaces
#   Super + Shift + 1-9    = Move Window to Workspace
#   Super + Alt + 1-9      = Move Window to Workspace Silent
#   Alt + Return    = Fullscreen
#
# See: https://wiki.hyprland.org/ for detailed documentation

{ self, inputs, ... }:
{
  flake.nixosModules.modulesDesktopHyprHyprland =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      username = config.userOptions.username;
    in
    {
      imports = [
        inputs.home-manager.nixosModules.home-manager
      ];

      home-manager.users.${username} = _: {
        wayland.windowManager.hyprland = {
          enable = true;
          xwayland.enable = true;
          portalPackage = pkgs.xdg-desktop-portal-hyprland;
          # UWSM handles systemd integration — disabling Hyprland's own to avoid conflict
          systemd = {
            enable = false;
            enableXdgAutostart = false;
            variables = [ ];
          };
          settings = {
            "ecosystem:no_update_news" = true;

            input = {
              kb_layout = "us";
              follow_mouse = "1";
              sensitivity = "0";
              touchpad = {
                natural_scroll = "no";
              };
              numlock_by_default = true;
            };

            general = {
              gaps_in = "0";
              gaps_out = "0";
              border_size = "0";
              resize_on_border = false;
              allow_tearing = false;
              layout = "dwindle";
            };

            misc = {
              disable_hyprland_logo = true;
            };

            decoration = {
              rounding = "10";
              rounding_power = "2";
              active_opacity = 1.0;
              inactive_opacity = 1.0;
              blur = {
                enabled = true;
                size = "3";
                passes = "1";
                vibrancy = "0.1696";
              };
              shadow = {
                enabled = true;
                range = "4";
                render_power = "3";
              };
            };

            animations = {
              enabled = true;
              bezier = [
                "easeOutQuint,   0.23, 1,    0.32, 1"
                "easeInOutCubic, 0.65, 0.05, 0.36, 1"
                "linear,         0,    0,    1,    1"
                "almostLinear,   0.5,  0.5,  0.75, 1"
                "quick,          0.15, 0,    0.1,  1"
              ];
              animation = [
                "windows,       1, 4.79, easeOutQuint"
                "windowsIn,     1, 4.1,  easeOutQuint, popin 87%"
                "windowsOut,    1, 1.49, linear,       popin 87%"
                "border,        1, 5.39, easeOutQuint"
                "fade,          1, 3.03, quick"
                "fadeIn,        1, 1.73, almostLinear"
                "fadeOut,       1, 1.46, almostLinear"
                "layers,        1, 3.81, easeOutQuint"
                "layersIn,      1, 4,    easeOutQuint, fade"
                "layersOut,     1, 1.5,  linear,       fade"
                "workspaces,    1, 1.94, almostLinear, fade"
                "workspacesIn,  1, 1.21, almostLinear, fade"
                "workspacesOut, 1, 1.94, almostLinear, fade"
              ];
            };

            dwindle = {
              pseudotile = true;
              preserve_split = true;
              split_width_multiplier = 1.35;
            };

            master = {
              new_status = "master";
            };

            "$mainMod" = "Super";

            bind = [
              # System
              "$mainMod, C, killactive"
              "$mainMod, M, exit"
              "$mainMod, V, togglefloating"
              "$mainMod, L, exec, hyprlock"
              "$mainMod, P, pseudo"
              "$mainMod, J, togglesplit"
              "$mainMod SHIFT, R, exec, dunstctl history-pop"
              "Alt, Return, fullscreen"

              # Applications
              "$mainMod, Q, exec, kitty"
              "$mainMod, F, exec, ${config.userOptions.browser}"
              "$mainMod, E, exec, uwsm app -- dolphin"
              "$mainMod, R, exec, vicinae toggle"

              # Screenshot
              "$mainMod SHIFT, Print, exec, hyprshot -m region -s ~/Pictures/Screenshots"

              # Focus
              "$mainMod, left,  movefocus, l"
              "$mainMod, right, movefocus, r"
              "$mainMod, up,    movefocus, u"
              "$mainMod, down,  movefocus, d"

              # Move window
              "$mainMod SHIFT, left,  movewindow, l"
              "$mainMod SHIFT, right, movewindow, r"
              "$mainMod SHIFT, up,    movewindow, u"
              "$mainMod SHIFT, down,  movewindow, d"

              # Resize window
              "$mainMod ALT, left,  resizeactive, -40 0"
              "$mainMod ALT, right, resizeactive,  40 0"
              "$mainMod ALT, up,    resizeactive,  0 -40"
              "$mainMod ALT, down,  resizeactive,  0  40"

              # Workspaces
              "$mainMod, 1, workspace, 1"
              "$mainMod, 2, workspace, 2"
              "$mainMod, 3, workspace, 3"
              "$mainMod, 4, workspace, 4"
              "$mainMod, 5, workspace, 5"
              "$mainMod, 6, workspace, 6"
              "$mainMod, 7, workspace, 7"
              "$mainMod, 8, workspace, 8"
              "$mainMod, 9, workspace, 9"
              "$mainMod, 0, workspace, 10"

              # Move to workspace
              "$mainMod SHIFT, 1, movetoworkspace, 1"
              "$mainMod SHIFT, 2, movetoworkspace, 2"
              "$mainMod SHIFT, 3, movetoworkspace, 3"
              "$mainMod SHIFT, 4, movetoworkspace, 4"
              "$mainMod SHIFT, 5, movetoworkspace, 5"
              "$mainMod SHIFT, 6, movetoworkspace, 6"
              "$mainMod SHIFT, 7, movetoworkspace, 7"
              "$mainMod SHIFT, 8, movetoworkspace, 8"
              "$mainMod SHIFT, 9, movetoworkspace, 9"
              "$mainMod SHIFT, 0, movetoworkspace, 10"

              # Move to workspace silent
              "$mainMod ALT, 1, movetoworkspacesilent, 1"
              "$mainMod ALT, 2, movetoworkspacesilent, 2"
              "$mainMod ALT, 3, movetoworkspacesilent, 3"
              "$mainMod ALT, 4, movetoworkspacesilent, 4"
              "$mainMod ALT, 5, movetoworkspacesilent, 5"
              "$mainMod ALT, 6, movetoworkspacesilent, 6"
              "$mainMod ALT, 7, movetoworkspacesilent, 7"
              "$mainMod ALT, 8, movetoworkspacesilent, 8"
              "$mainMod ALT, 9, movetoworkspacesilent, 9"
              "$mainMod ALT, 0, movetoworkspacesilent, 10"

              # Scratchpad
              "$mainMod, S, togglespecialworkspace, magic"
              "$mainMod SHIFT, S, movetoworkspace, special:magic"

              # Scroll workspaces
              "$mainMod, mouse_down, workspace, e+1"
              "$mainMod, mouse_up,   workspace, e-1"
            ];

            bindel = [
              # Volume
              ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"
              ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
              ", XF86AudioMute,        exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
              ", XF86AudioMicMute,     exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"

              # Brightness
              ", XF86MonBrightnessUp,   exec, brightnessctl set 10%+"
              ", XF86MonBrightnessDown, exec, brightnessctl set 10%-"
            ];

            bindl = [
              # Media controls
              ", XF86AudioPlay, exec, playerctl play-pause"
              ", XF86AudioNext, exec, playerctl next"
              ", XF86AudioPrev, exec, playerctl previous"
            ];

            bindm = [
              "$mainMod, mouse:272, movewindow"
              "$mainMod, mouse:273, resizewindow"
            ];

            # UWSM already manages dbus activation environment and systemd imports.
            # Wayland env vars are set via NixOS environment.sessionVariables.
            exec-once = [
              "teamspeak3"
              "vicinae server"
            ];
          };
        };
      };
    };
}
