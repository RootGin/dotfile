{ pkgs, ... }:
{
  force = true;
  default = "ddg";
  privateDefault = "ddg";
  order = [
    "qwant"
    "Brave Search"
    "ddg"
    "StartPage"
    "Github"
    "reddit"
    "My NixOS"
    "Noogle"
    "ArchLinux Wiki"
    "NixOS Wiki"
    "Nix Packages"
    "Nix Options"
    "Home Manager"
    "Nixvim Options"
    "Crates.io"
  ];
  engines =
    let
      disabled.metaData.hidden = true;
    in
    {
      "google" = { inherit (disabled) metaData; };
      "bing" = { inherit (disabled) metaData; };
      "amazondotcom-us" = { inherit (disabled) metaData; };
      "wikipedia" = { inherit (disabled) metaData; };
      "ddg" = {
        metaData.alias = "@dg";
      };

      "qwant" = {
        urls = [ { template = "https://www.qwant.com/?q={searchTerms}"; } ];
        icon = "https://www.qwant.com/favicon.ico";
        definedAliases = [
          "@qw"
          "@qwant"
        ];
      };
      "Brave Search" = {
        urls = [ { template = "https://search.brave.com/search?q={searchTerms}"; } ];
        icon = "https://brave.com/static-assets/images/brave-logo-sans-text.svg";
        updateInterval = 24 * 60 * 60 * 1000;
        definedAliases = [
          "@br"
          "@b"
          "@brave"
        ];
      };
      "StartPage" = {
        urls = [ { template = "https://www.startpage.com/sp/search?query={searchTerms}"; } ];
        icon = "https://www.startpage.com/sp/cdn/favicons/favicon-gradient.ico";
        updateInterval = 24 * 60 * 60 * 1000;
        definedAliases = [
          "@sp"
          "@s"
          "@start"
        ];
      };
      "reddit" = {
        urls = [ { template = "https://www.reddit.com/search/?q={searchTerms}"; } ];
        icon = "https://www.redditstatic.com/shreddit/assets/favicon/favicon.ico";
        updateInterval = 24 * 60 * 60 * 1000;
        definedAliases = [
          "@r"
          "@reddit"
        ];
      };
      "My NixOS" = {
        urls = [ { template = "https://mynixos.com/search?q={searchTerms}"; } ];
        icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake-white.svg";
        definedAliases = [
          "@mn"
          "@nx"
          "@mynixos"
        ];
      };
      "Home Manager" = {
        urls = [
          { template = "https://home-manager-options.extranix.com/?query={searchTerms}&release=master"; }
        ];
        icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
        definedAliases = [
          "@hm"
          "@home"
          "@homeman"
        ];
      };
      "Nixvim Options" = {
        urls = [ { template = "https://nix-community.github.io/nixvim/search/?query={searchTerms}"; } ];
        icon = "https://nix-community.github.io/nixvim/search/favicon.ico";
        updateInterval = 24 * 60 * 60 * 1000;
        definedAliases = [
          "@nxv"
          "@nv"
          "@nvo"
        ];
      };
      "Github" = {
        urls = [ { template = "https://github.com/search?q={searchTerms}"; } ];
        icon = "https://github.githubassets.com/favicons/favicon.svg";
        definedAliases = [
          "@gh"
          "@github"
        ];
      };
      "Noogle" = {
        urls = [ { template = "https://noogle.dev/q?term={searchTerms}"; } ];
        icon = "https://noogle.dev/favicon.ico";
        definedAliases = [
          "@ng"
          "@noogle"
        ];
      };
      "ArchLinux Wiki" = {
        urls = [ { template = "https://wiki.archlinux.org/index.php?search={searchTerms}"; } ];
        icon = "https://wiki.archlinux.org/favicon.ico";
        definedAliases = [
          "@aw"
          "@arch"
        ];
      };
      "NixOS Wiki" = {
        urls = [ { template = "https://wiki.nixos.org/w/index.php?search={searchTerms}"; } ];
        icon = "https://wiki.nixos.org/favicon.png";
        definedAliases = [
          "@nw"
          "@nixos"
        ];
      };
      "Nix Packages" = {
        urls = [ { template = "https://search.nixos.org/packages?query={searchTerms}"; } ];
        icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
        definedAliases = [
          "@np"
          "@nixpkgs"
        ];
      };
      "Nix Options" = {
        urls = [ { template = "https://search.nixos.org/options?query={searchTerms}"; } ];
        icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
        definedAliases = [
          "@no"
          "@nixopt"
        ];
      };
      "Crates.io" = {
        urls = [ { template = "https://crates.io/search?q={searchTerms}"; } ];
        icon = "https://crates.io/favicon.ico";
        definedAliases = [
          "@cr"
          "@crates"
        ];
      };
    };
}
