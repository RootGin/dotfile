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
      inherit (config.userOptions) username;

      # Browser detection — match by package name (librewolf‑branded Firefox vs vanilla).
      firefoxPkg = config.programs.browsing.firefox.package;
      librewolf =
        firefoxPkg != null && lib.hasPrefix "librewolf" (firefoxPkg.pname or firefoxPkg.name or "");
      chromium = config.programs.browsing.chromium.enable;

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

      # ── MIME type associations ───────────────────────────────
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
          # If librewolf is the firefox package AND chromium isn't enabled,
          # register it as the default browser. Otherwise the default
          # (zen.desktop) applies.
          // lib.optionalAttrs (librewolf && !chromium) {
            "text/html" = [ "librewolf.desktop" ];
            "x-scheme-handler/http" = [ "librewolf.desktop" ];
            "x-scheme-handler/https" = [ "librewolf.desktop" ];
          };
      };

      # ── Portal fallback (common) — compositor‑specific config  ──
      # (e.g. hyprland) takes priority over config.common at runtime.
      xdg.portal.config.common = {
        default = [
          "hyprland"
          "gtk"
        ];
        "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
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
        # Force-disable GTK4 theming. stylix (gtk target) defines a non-null
        # gtk.gtk4.theme; mkForce preserves the intent (no GTK4 theme) and
        # keeps stylix theming GTK3 only.
        gtk.gtk4.theme = lib.mkForce null;
      };
    };
}
