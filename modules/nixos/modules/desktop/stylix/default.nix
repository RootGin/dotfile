{ self, inputs, ... }:
{
  flake.nixosModules.modulesDesktopStylix =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      inherit (config.userOptions) colorScheme;
    in
    {
      imports = [
        inputs.stylix.nixosModules.stylix
      ];

      fonts = {
        packages = [
          # Universal coverage (Noto Sans/Serif, Latin/Greek/Cyrillic + many scripts).
          pkgs.noto-fonts
          # Be Vietnam Pro - used for documentation work. `override { fonts = ... }`
          # installs only this family; note the whole google/fonts source is still
          # downloaded once (~1 GB) as a build input, then GC can reclaim it.
          (pkgs.google-fonts.override { fonts = [ "Be Vietnam Pro" ]; })
          # JetBrains Mono - developer typeface.
          pkgs.jetbrains-mono
          # Fairfax HD - halfwidth scalable monospace with wide Unicode coverage.
          pkgs.fairfax-hd
        ];
      };

      stylix = {
        enable = true;
        base16Scheme = "${pkgs.base16-schemes}/share/themes/${colorScheme}.yaml";

        cursor = {
          package = pkgs.google-cursor;
          name = "GoogleDot-White";
          size = 25;
        };

        fonts = {
          emoji = {
            package = pkgs.noto-fonts-color-emoji;
            name = "Noto Color Emoji";
          };
          monospace = {
            package = pkgs.nerd-fonts.geist-mono;
            name = "Geist Mono";
          };
          sansSerif = {
            package = pkgs.geist-font;
            name = "Geist";
          };
          serif = config.stylix.fonts.sansSerif;
          sizes = {
            applications = 12;
            desktop = 10;
            popups = 10;
            terminal = 10;
          };
        };

        polarity = "dark";

        icons = {
          enable = true;
          package = pkgs.kora-icon-theme;
          dark = "kora";
        };

        opacity.applications = 0.8;

        targets = {
          limine.image.enable = false;
        };
      };

      # Stylix's rofi target still sets programs.rofi.font (renamed to
      # programs.rofi.settings.font in home-manager), which emits an eval
      # warning. Rofi isn't used (fuzzel/vicinae instead), so disable
      # stylix's rofi target to silence it. Note: rofi is a home-manager-only
      # target, so the toggle must live in home-manager namespace, not in
      # the NixOS-level stylix.targets above.
      home-manager.sharedModules = [
        { stylix.targets.rofi.enable = false; }
      ];
    };
}
