{ self, inputs, ... }:
{
  flake.nixosModules.applicationsBrowsingZen =
    { config, lib, pkgs, ... }:
    let
      username = config.userOptions.username;
      system = pkgs.stdenv.hostPlatform.system;
    in
    {
      imports = [ inputs.home-manager.nixosModules.home-manager ];

      options.programs.browsing.zen = {
        enable = lib.mkEnableOption "Zen browser";
      };

      config = lib.mkIf config.programs.browsing.zen.enable {
        home-manager.users.${username} = {
          imports = [ inputs.zen-browser.homeModules.default ];

          stylix.targets.zen-browser.enable = false;

          programs.zen-browser = {
            enable = true;

            nativeMessagingHosts = [ pkgs.tridactyl-native ];

            policies = {
              DisableAppUpdate = true;
              DisableFirefoxAccounts = true;
              DisableFirefoxStudies = true;
              DisablePocket = true;
              DisableProfileImport = true;
              DisableSetDesktopBackground = true;
              DisableTelemetry = true;
              DisplayBookmarksToolbar = "never";
              DNSOverHTTPS = { Enabled = true; Locked = true; };
              DontCheckDefaultBrowser = true;
              ExtensionUpdate = true;
              OfferToSaveLogins = false;
              PasswordManagerEnabled = false;
              EnableTrackingProtection = {
                Value = true;
                Locked = true;
                Cryptomining = true;
                Fingerprinting = true;
                EmailTracking = true;
              };
              HardwareAcceleration = true;
              OverrideFirstRunPage = "";
              PopupBlocking.Default = true;
              Preferences = {
                "browser.backspace_action" = 0;
                "privacy.trackingprotection.enabled" = true;
                "media.peerconnection.ice.default_address_only" = true;
                "network.captive-portal-service.enabled" = false;
                "network.dns.echconfig.enabled" = true;
                "network.dns.http3_echconfig.enabled" = true;
                "geo.enabled" = false;
                "webgl.disabled" = true;
              };
              ExtensionSettings =
                let
                  installation_mode = "force_installed";
                  urlPrefix = x: "http://addons.mozilla.org/firefox/downloads/latest/${x}/latest.xpi";
                in
                {
                  "uBlock0@raymondhill.net"        = { install_url = urlPrefix "ublock-origin";    inherit installation_mode; };
                  "tridactyl.vim@cmcaine.co.uk"    = { install_url = urlPrefix "tridactyl-vim";    inherit installation_mode; };
                  "{c2c003ee-bd69-42a2-b0e9-6f34222cb046}" = { install_url = urlPrefix "auto-tab-discard"; inherit installation_mode; };
                  "78272b6fa58f4a1abaac99321d503a20@proton.me" = { install_url = urlPrefix "proton-pass";       inherit installation_mode; };
                  "treestyletab@piro.sakura.ne.jp" = { install_url = urlPrefix "tree-style-tab";    inherit installation_mode; };
                  "bing@search.mozilla.org".installation_mode = "blocked";
                };
            };

            profiles.extra = {
              isDefault = false;
              id = 1;
              extensions.packages = with inputs.firefox-addons.packages.${system}; [
                multi-account-containers
                user-agent-string-switcher
                ublock-origin
                auto-tab-discard
              ];
            };

            profiles.default = {
              isDefault = true;
              id = 0;

              userChrome = ''
                :root {
                    --zen-primary-color: #88C0D0 !important;
                }

                @media not (prefers-color-scheme: dark) {
                    :root {
                        --zen-colors-primary: #D8DEE9 !important;
                        --zen-colors-secondary: #D8DEE9 !important;
                        --zen-colors-tertiary: #ECEFF4 !important;
                        --zen-colors-border: #E5E9F0 !important;
                    }
                }

                @media (prefers-color-scheme: dark) {
                    :root {
                        --zen-colors-primary: #434C5E !important;
                        --zen-colors-secondary: #434C5E !important;
                        --zen-colors-tertiary: #2E3440 !important;
                        --zen-colors-border: #3B4252 !important;
                    }
                }

                ${builtins.readFile "${inputs.zen-findbar}/chrome.css"}
              '';

              extensions.packages = with inputs.firefox-addons.packages.${system}; [
                keepassxc-browser
                multi-account-containers
                buster-captcha-solver
                github-file-icons
                widegithub
                hover-zoom-plus
                reddit-enhancement-suite
                ublock-origin
                tridactyl
                auto-tab-discard
              ];

              containersForce = true;
              containers = {
                general  = { color = "blue";      id = 1;  icon = "fruit";       };
                shopping = { color = "pink";      id = 2;  icon = "cart";        };
                dev      = { color = "green";     id = 3;  icon = "chill";       };
                social   = { color = "red";       id = 4;  icon = "pet";         };
                mail     = { color = "orange";    id = 5;  icon = "fingerprint"; };
                nix      = { color = "blue";      id = 6;  icon = "circle";      };
                privacy  = { color = "green";     id = 7;  icon = "briefcase";   };
                reading  = { color = "turquoise"; id = 8;  icon = "tree";        };
                account  = { color = "toolbar";   id = 9;  icon = "fingerprint"; };
                money    = { color = "yellow";    id = 10; icon = "dollar";      };
                misc     = { color = "yellow";    id = 69; icon = "circle";      };
                space    = { color = "purple";    id = 77; icon = "vacation";    };
              };

              search = {
                force = true;
                default = "ddg";
                privateDefault = "ddg";
                order = [
                  "qwant" "Brave Search" "ddg" "StartPage" "Github"
                  "reddit" "My NixOS" "Noogle" "ArchLinux Wiki" "NixOS Wiki"
                  "Nix Packages" "Nix Options" "Home Manager" "Nixvim Options" "Crates.io"
                ];
                engines =
                  let
                    disabled.metaData.hidden = true;
                  in
                  {
                    "google"          = { inherit (disabled) metaData; };
                    "bing"            = { inherit (disabled) metaData; };
                    "amazondotcom-us" = { inherit (disabled) metaData; };
                    "wikipedia"       = { inherit (disabled) metaData; };
                    "ddg"             = { metaData.alias = "@dg"; };

                    "qwant" = {
                      urls = [ { template = "https://www.qwant.com/?q={searchTerms}"; } ];
                      icon = "https://www.qwant.com/favicon.ico";
                      definedAliases = [ "@qw" "@qwant" ];
                    };
                    "Brave Search" = {
                      urls = [ { template = "https://search.brave.com/search?q={searchTerms}"; } ];
                      icon = "https://brave.com/static-assets/images/brave-logo-sans-text.svg";
                      updateInterval = 24 * 60 * 60 * 1000;
                      definedAliases = [ "@br" "@b" "@brave" ];
                    };
                    "StartPage" = {
                      urls = [ { template = "https://www.startpage.com/sp/search?query={searchTerms}"; } ];
                      icon = "https://www.startpage.com/sp/cdn/favicons/favicon-gradient.ico";
                      updateInterval = 24 * 60 * 60 * 1000;
                      definedAliases = [ "@sp" "@s" "@start" ];
                    };
                    "reddit" = {
                      urls = [ { template = "https://www.reddit.com/search/?q={searchTerms}"; } ];
                      icon = "https://www.redditstatic.com/shreddit/assets/favicon/favicon.ico";
                      updateInterval = 24 * 60 * 60 * 1000;
                      definedAliases = [ "@r" "@reddit" ];
                    };
                    "My NixOS" = {
                      urls = [ { template = "https://mynixos.com/search?q={searchTerms}"; } ];
                      icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake-white.svg";
                      definedAliases = [ "@mn" "@nx" "@mynixos" ];
                    };
                    "Home Manager" = {
                      urls = [ { template = "https://home-manager-options.extranix.com/?query={searchTerms}&release=master"; } ];
                      icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                      definedAliases = [ "@hm" "@home" "@homeman" ];
                    };
                    "Nixvim Options" = {
                      urls = [ { template = "https://nix-community.github.io/nixvim/search/?query={searchTerms}"; } ];
                      icon = "https://nix-community.github.io/nixvim/search/favicon.ico";
                      updateInterval = 24 * 60 * 60 * 1000;
                      definedAliases = [ "@nxv" "@nv" "@nvo" ];
                    };
                  };
              };

              settings = {
                "general.config.sandbox_enabled" = false;
                "browser.disableResetPrompt" = true;
                "browser.bookmarks.showMobileBookmarks" = false;
                "browser.download.panel.shown" = false;
                "browser.download.useDownloadDir" = false;
                "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
                "browser.search.suggest.enabled" = false;
                "browser.tabs.warnOnClose" = true;
                "browser.startup.homepage" = "https://startup-page-nord.vercel.app/";
                "browser.startup.page" = 3;
                "browser.translations.panelShown" = true;
                "browser.urlbar.quicksuggest.scenario" = "history";
                "browser.urlbar.suggest.bookmark" = false;
                "browser.urlbar.suggest.history" = false;
                "browser.urlbar.suggest.topsites" = false;
                "browser.urlbar.trimHttps" = true;
                "browser.urlbar.trimURLs" = true;
                "browser.urlbar.formatting.enabled" = true;
                "browser.autofocus" = true;
                "extensions.autoDisableScope" = false;
                "gfx.webrender.all" = true;
                "layers.acceleration.force-enabled" = true;
                "privacy.clearOnShutdown.cache" = true;
                "privacy.clearOnShutdown.cookies" = false;
                "privacy.clearOnShutdown.downloads" = true;
                "privacy.clearOnShutdown.history" = false;
                "privacy.clearOnShutdown.sessions" = false;
                "privacy.donottrackheader.enabled" = true;
                "svg.context-properties.content.enabled" = true;
                "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
                "general.smoothScroll" = true;
                "general.smoothScroll.lines.durationMaxMS" = 125;
                "general.smoothScroll.lines.durationMinMS" = 125;
                "general.smoothScroll.mouseWheel.durationMaxMS" = 200;
                "general.smoothScroll.mouseWheel.durationMinMS" = 100;
                "general.smoothScroll.msdPhysics.enabled" = true;
                "general.smoothScroll.other.durationMaxMS" = 125;
                "general.smoothScroll.other.durationMinMS" = 125;
                "general.smoothScroll.pages.durationMaxMS" = 125;
                "general.smoothScroll.pages.durationMinMS" = 125;
                "mousewheel.min_line_scroll_amount" = 30;
                "mousewheel.system_scroll_override_on_root_content.enabled" = true;
                "mousewheel.system_scroll_override_on_root_content.horizontal.factor" = 175;
                "mousewheel.system_scroll_override_on_root_content.vertical.factor" = 175;
                "toolkit.scrollbox.horizontalScrollDistance" = 6;
                "toolkit.scrollbox.verticalScrollDistance" = 2;
                "userContent.page.proton_color.system_accent" = true;
                "widget.non-native-theme.use-theme-accent" = true;
                "cookiebanners.service.mode" = 2;
                "cookiebanners.service.mode.privateBrowsing" = 2;
                "nglayout.initialpaint.delay" = 0;
                "nglayout.initialpaint.delay_in_oopif" = 0;
                "content.notify.interval" = 100000;
                "browser.startup.preXulSkeletonUI" = false;
                "gfx.webrender.precache-shaders" = true;
                "layers.gpu-process.enabled" = true;
                "gfx.canvas.accelerated" = true;
                "gfx.canvas.accelerated.cache-items" = 32768;
                "gfx.canvas.accelerated.cache-size" = 4096;
                "dom.ipc.processCount" = 1;
                "fission.autostart" = false;
                "browser.cache.disk.capacity" = 0;
                "browser.cache.disk.enable" = false;
                "layers.mlgpu.enabled" = true;
                "media.ffmpeg.vaapi.enabled" = true;
                "dom.ipc.processCount.webIsolated" = 1;
                "browser.backspace_action" = 0;
                "privacy.trackingprotection.enabled" = true;
                "media.peerconnection.ice.default_address_only" = true;
                "network.captive-portal-service.enabled" = false;
                "network.dns.echconfig.enabled" = true;
                "network.dns.http3_echconfig.enabled" = true;
                "geo.enabled" = false;
                "webgl.disabled" = true;
                "dom.ipc.forkserver.enable" = true;
                "zen.urlbar.behavior" = "float";
                "zen.urlbar.replace-newtab" = false;
                "zen.widget.linux.transparency" = true;
                "zen.view.grey-out-inactive-windows" = false;
                "zen.view.show-bottom-border" = true;
                "zen.view.show-newtab-button-border-top" = true;
                "zen.view.show-newtab-button-top" = false;
                "zen.view.sidebar-expanded" = true;
                "zen.view.use-single-toolbar" = false;
                "identity.fxaccounts.enabled" = false;
                "signon.rememberSignons" = false;
                "services.sync.prefs.sync.signon.rememberSignons" = false;
                "signon.rememberSignons.visibilityToggle" = false;
              };
            };
          };
        };
      };
    };
}
