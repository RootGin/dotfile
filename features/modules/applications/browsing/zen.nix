{ self, inputs, ... }:
{
  flake.nixosModules.applicationsBrowsingZen =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      username = config.userOptions.username;
      system = pkgs.stdenv.hostPlatform.system;
      colors = config.lib.stylix.colors;
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

            policies = import ./zen/policies.nix { };

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
              path = "default";

              userChrome = ''
                :root {
                    --zen-primary-color: #${colors.base0D} !important;
                    --zen-colors-primary: #${colors.base02} !important;
                    --zen-colors-secondary: #${colors.base02} !important;
                    --zen-colors-tertiary: #${colors.base00} !important;
                    --zen-colors-border: #${colors.base0D} !important;
                }

                ${builtins.readFile "${inputs.zen-findbar}/chrome.css"}
              '';

              userContent = ''
                @-moz-document url-prefix("about:home"), url-prefix("about:newtab") {
                  body {
                    background-color: #${colors.base00} !important;
                  }
                }
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
                general = {
                  color = "blue";
                  id = 1;
                  icon = "fruit";
                };
                shopping = {
                  color = "pink";
                  id = 2;
                  icon = "cart";
                };
                dev = {
                  color = "green";
                  id = 3;
                  icon = "chill";
                };
                social = {
                  color = "red";
                  id = 4;
                  icon = "pet";
                };
                mail = {
                  color = "orange";
                  id = 5;
                  icon = "fingerprint";
                };
                nix = {
                  color = "blue";
                  id = 6;
                  icon = "circle";
                };
                privacy = {
                  color = "green";
                  id = 7;
                  icon = "briefcase";
                };
                reading = {
                  color = "turquoise";
                  id = 8;
                  icon = "tree";
                };
                account = {
                  color = "toolbar";
                  id = 9;
                  icon = "fingerprint";
                };
                money = {
                  color = "yellow";
                  id = 10;
                  icon = "dollar";
                };
                misc = {
                  color = "yellow";
                  id = 69;
                  icon = "circle";
                };
                space = {
                  color = "purple";
                  id = 77;
                  icon = "vacation";
                };
              };

              search = import ./zen/search.nix { inherit pkgs; };

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
                "privacy.sanitize.sanitizeOnShutdown" = true;
                "privacy.clearOnShutdown.cache" = true;
                "privacy.clearOnShutdown.cookies" = false;
                "privacy.clearOnShutdown.downloads" = true;
                "privacy.clearOnShutdown.history" = false;
                "privacy.clearOnShutdown.formdata" = true;
                "privacy.clearOnShutdown.sessions" = false;
                "privacy.clearOnShutdown.offlineApps" = true;
                "privacy.clearOnShutdown.siteSettings" = false;
                "privacy.sanitize.timeSpan" = 0;
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
                "browser.gesture.swipe.left" = "Browser:BackOrBackDuplicate";
                "browser.gesture.swipe.right" = "Browser:ForwardOrForwardDuplicate";
                "zen.view.sidebar-swipe-hover-enabled" = true;
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
