{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
  spicePkgs = inputs.spicetify-nix.legacyPackages.${system};
in
{
  imports = [ inputs.spicetify-nix.nixosModules.default ];

  config = lib.mkIf config.my.programs.media.enable {
    stylix.targets.spicetify.enable = false;

    programs.spicetify = {
      enable = true;
      theme = spicePkgs.themes.text;
      colorScheme = "custom";
      customColorScheme = with config.lib.stylix.colors; {
        accent = base0C;
        accent-active = base0D;
        accent-inactive = base00;
        banner = base0D;
        border-active = base0D;
        border-inactive = base01;
        header = base03;
        highlight = base03;
        main = base00;
        notification = base0D;
        notification-error = base08;
        subtext = base04;
        text = base06;
      };

      enabledSnippets = with spicePkgs.snippets; [
        autoHideFriends
        removePopular
        hideMadeForYou
        removeConnectBar
        hideDownloadButton
        hideNowPlayingViewButton
        hideProfileUsername
        ''
          section[data-testid='home-page'] .main-shelf-shelf:not([aria-label='Recently played'], [aria-label='Your playlists']) {
          display: none !important;
          }
        ''
      ];

      enabledExtensions = with spicePkgs.extensions; [
        adblockify
        powerBar
        history
        shuffle
        fullAppDisplay
        playNext
        volumePercentage
        writeify
      ];

      enabledCustomApps = with spicePkgs.apps; [
        newReleases
        lyricsPlus
        betterLibrary
        historyInSidebar
      ];
    };
  };
}
