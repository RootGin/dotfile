{ self, inputs, ... }:
{
  flake.nixosModules.applicationsMediaSpicetify =
    { config, lib, pkgs, ... }:
    let
      system = pkgs.stdenv.hostPlatform.system; 
      spicePkgs = inputs.spicetify-nix.legacyPackages.${system};
    in
    {
      imports = [ inputs.spicetify-nix.nixosModules.default ];

      config = lib.mkIf config.programs.media.enable {
        stylix.targets.spicetify.enable = false;

        programs.spicetify = {
          enable = true;
          theme = spicePkgs.themes.text;
          colorScheme = config.userOptions.spicetifyColorScheme;

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
    };
}
