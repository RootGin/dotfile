{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config.my.user) username;

  defaultApps = {
    browser = "zen-twilight.desktop";
    text = "nvim.desktop";
    image = "imv.desktop";
    audio = "mpv.desktop";
    video = "mpv.desktop";
    directory = "dev.noctalia.luciole.desktop";
    pdf = "zathura.desktop";
    terminal = "kitty.desktop";
  };

  mimeMap = {
    text = [
      "text/plain"
      "text/x-python"
      "text/x-shellscript"
    ];
    image = [
      "image/bmp"
      "image/gif"
      "image/jpeg"
      "image/jpg"
      "image/png"
      "image/svg+xml"
      "image/tiff"
      "image/vnd.microsoft.icon"
      "image/webp"
    ];
    audio = [
      "audio/aac"
      "audio/mpeg"
      "audio/ogg"
      "audio/opus"
      "audio/wav"
      "audio/webm"
      "audio/x-matroska"
    ];
    video = [
      "video/mp2t"
      "video/mp4"
      "video/mpeg"
      "video/ogg"
      "video/webm"
      "video/x-flv"
      "video/x-matroska"
      "video/x-msvideo"
      "video/avi"
    ];
    directory = [ "inode/directory" ];
    browser = [
      "text/html"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
    ];
    terminal = [
      "terminal"
      "x-terminal-emulator"
      "application/x-shellscript"
    ];
    pdf = [ "application/pdf" ];
  };
in
{

  config = lib.mkIf config.my.desktop.enable {

    # ── MIME type associations ───────────────────────────────
    xdg.mime = {
      enable = true;
      defaultApplications = lib.concatMapAttrs (c: ms: lib.genAttrs ms (_: [ defaultApps.${c} ])) mimeMap;
    };

    # ── XDG Desktop Portal ───────────────────────────────────
    # Compositor-specific config (niri) takes priority over config.common at runtime.
    xdg.portal =
      let
        common = {
          default = [
            "gnome"
            "gtk"
          ];
          "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
          "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
        };
      in
      {
        enable = true;
        xdgOpenUsePortal = true;
        extraPortals = [
          pkgs.xdg-desktop-portal-gtk
          pkgs.xdg-desktop-portal-gnome
        ];
        config = {
          inherit common;
          niri = lib.mkForce (
            common
            // {
              default = [ "gtk" ];
              "org.freedesktop.impl.portal.Access" = [ "gtk" ];
              "org.freedesktop.impl.portal.Notification" = [ "gtk" ];
              "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
              "org.freedesktop.impl.portal.Screenshot" = [ "gnome" ];
              "org.freedesktop.impl.portal.Settings" = [
                "gtk"
                "gnome"
              ];
            }
          );
        };
      };

    environment.systemPackages = [ pkgs.xdg-utils ];

    home-manager.users.${username} = {
      xdg.userDirs = {
        enable = true;
        createDirectories = true;
        setSessionVariables = false;
      };
    };
  };
}
