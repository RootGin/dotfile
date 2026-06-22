{ self, inputs, ... }:
{
  flake.nixosModules.modulesDesktopXdg =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      username = config.userOptions.username;
      librewolf = config.programs.browsing.firefox.package == pkgs.librewolf;

      defaultApps = {
        browser = "zen.desktop";
        text = "nvim.desktop";
        image = "gthumb.desktop";
        audio = "vlc.desktop";
        video = "vlc.desktop";
        directory = "thunar.desktop";
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
      imports = [ inputs.home-manager.nixosModules.home-manager ];

      xdg.mime = {
        enable = true;
        defaultApplications =
          lib.listToAttrs (
            lib.flatten (
              lib.mapAttrsToList (
                category: mimes: map (mime: lib.attrsets.nameValuePair mime [ defaultApps."${category}" ]) mimes
              ) mimeMap
            )
          )
          // lib.optionalAttrs librewolf {
            "text/html" = [ "librewolf.desktop" ];
            "x-scheme-handler/http" = [ "librewolf.desktop" ];
            "x-scheme-handler/https" = [ "librewolf.desktop" ];
          };
      };

      environment.systemPackages = with pkgs; [
        xdg-user-dirs
        xdg-utils
      ];

      home-manager.users.${username} = _: {
        xdg = {
          userDirs = {
            enable = true;
            createDirectories = true;
            setSessionVariables = false;
          };
        };
        gtk.gtk4.theme = null;
      };
    };
}
