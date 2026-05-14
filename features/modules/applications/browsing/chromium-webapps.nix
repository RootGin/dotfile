{ self, ... }:
{
  flake.nixosModules.applicationsBrowsingChromiumWebapps =
    { config, pkgs, lib, ... }:
    let
      mkChromiumApp = {
        appName,
        url,
        desktopName ? appName,
        profile ? appName,
        class ? "crx_${appName}",
        categories ? [ "Network" "WebBrowser" ],
        icon ? "chromium"
      }:
        let
          wrapper = pkgs.writeShellScriptBin "${appName}-web" ''
            exec ${pkgs.chromium}/bin/chromium \
              --app=${url} \
              --user-data-dir="$HOME/.config/chromium-${profile}" \
              --class=${class} \
              --no-first-run --no-default-browser-check \
              --ozone-platform=wayland \
              "$@"
          '';
          desktop = pkgs.makeDesktopItem {
            name = appName;
            exec = "${wrapper}/bin/${appName}-web %U";
            icon = icon;
            desktopName = desktopName;
            startupWMClass = class;
            categories = categories;
            terminal = false;
          };
        in
        desktop;

      cfg = config.my.chromiumWebApps;
    in
    {
      options.my.chromiumWebApps = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule ({ name, ... }: {
          options = {
            enable = lib.mkEnableOption "Enable this webapp";
            url = lib.mkOption {
              type = lib.types.str;
            };
            desktopName = lib.mkOption {
              type = lib.types.str;
              default = name;
            };
            profile = lib.mkOption {
              type = lib.types.str;
              default = name;
            };
            class = lib.mkOption {
              type = lib.types.str;
              default = "crx_${name}";
            };
            categories = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ "Network" "WebBrowser" ];
            };
            icon = lib.mkOption {
              type = lib.types.either lib.types.str lib.types.path;
              default = "chromium";
              description = "Icon name from system theme or path to an image file";
            };
          };
        }));
        default = { };
      };

      config = {
        environment.systemPackages = lib.mapAttrsToList
          (name: app: mkChromiumApp (lib.removeAttrs app [ "enable" ] // { appName = name; }))
          (lib.filterAttrs (_: v: v.enable or true) cfg);

        my.chromiumWebApps = {
          zalo = {
            enable = true;
            url = "https://chat.zalo.me/";
            desktopName = "Zalo";
            profile = "ZaloProfile";
            class = "chrome-chat.zalo.me__-ZaloProfile";
            categories = [ "Network" "Chat" "InstantMessaging" ];
            icon = ./icons/zalo.svg;
          };

          telegram = {
            enable = true;
            url = "https://web.telegram.org";
            desktopName = "Telegram";
            profile = "TelegramProfile";
            class = "chrome-web.telegram.org__-TelegramProfile";
            categories = [ "Network" "Chat" "InstantMessaging" ];
          };

          protonmail = {
            enable = true;
            url = "https://mail.proton.me";
            desktopName = "Protonmail";
            profile = "ProtonmailProfile";
            class = "chrome-mail.proton.me__-ProtonmailProfile";
            categories = [ "Network" "Email" ];
            icon = ./icons/proton-mail-seeklogo.svg;
          };

          meet = {
            enable = true;
            url = "https://meet.google.com";
            desktopName = "Google Meet";
            profile = "GoogleMeetProfile";
            class = "chrome-meet.google.com__-GoogleMeetProfile";
            categories = [ "Network" "Chat" "InstantMessaging" ];
            icon = ./icons/Google_Meet_icon.svg;
          };
        };
      };
    };
}
