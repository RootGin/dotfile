{ ... }:
{
  DisableAppUpdate = true;
  DisableFirefoxAccounts = true;
  DisableFirefoxStudies = true;
  DisablePocket = true;
  DisableProfileImport = true;
  DisableSetDesktopBackground = true;
  DisableTelemetry = true;
  DisplayBookmarksToolbar = "never";
  DNSOverHTTPS = {
    Enabled = true;
    Locked = true;
  };
  DontCheckDefaultBrowser = false;
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
      "uBlock0@raymondhill.net" = {
        install_url = urlPrefix "ublock-origin";
        inherit installation_mode;
      };
      "tridactyl.vim@cmcaine.co.uk" = {
        install_url = urlPrefix "tridactyl-vim";
        inherit installation_mode;
      };
      "{c2c003ee-bd69-42a2-b0e9-6f34222cb046}" = {
        install_url = urlPrefix "auto-tab-discard";
        inherit installation_mode;
      };
      "78272b6fa58f4a1abaac99321d503a20@proton.me" = {
        install_url = urlPrefix "proton-pass";
        inherit installation_mode;
      };
      "treestyletab@piro.sakura.ne.jp" = {
        install_url = urlPrefix "tree-style-tab";
        inherit installation_mode;
      };
      "bing@search.mozilla.org".installation_mode = "blocked";
      "sponsorBlock@ajay.app" = {
        install_url = urlPrefix "sponsorblock";
        inherit installation_mode;
      };
      "{6c3fc5c5-5962-4b0a-8b22-a7e57f17e636}" = {
        install_url = urlPrefix "clearurls";
        inherit installation_mode;
      };
      "{aecec67f-0d10-4fa7-b8c7-609eb76e085f}" = {
        install_url = urlPrefix "violentmonkey";
        inherit installation_mode;
      };
    };
}
