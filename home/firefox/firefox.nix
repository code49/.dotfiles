{ config, pkgs, ... }:

{
  programs.firefox = {
    enable = true;
    configPath = ".mozilla/firefox";

    profiles = {
      dchan-personal = {
        id = 0;
        name = "dchan-personal";
        isDefault = true;
        settings = {
          "browser.startup.homepage" = "https://davidlechan.dev";
          "browser.tabs.warnOnClose" = true;
        };
      };

      dchan2-cmu = {
        id = 1;
        name = "dchan2-cmu";
        isDefault = false;
        settings = {
          "browser.startup.homepage" = "https://canvas.cmu.edu";
          "browser.tabs.warnOnClose" = true;
        };
      };

      streamSilencer = {
        id = 2;
        name = "streamSilencer";
        isDefault = false;
        settings = {
          "browser.startup.homepage" = "about:blank";
          "browser.tabs.warnOnClose" = true;
          "services.sync.engine.addons" = false;
          "extensions.activeThemeID" = "firefox-alpenglow@mozilla.org";
          "media.eme.enabled" = true;
          "media.gmp-widevinecdm.enabled" = true;
          "media.gmp-widevinecdm.visible" = true;
        };
      };
    };
  };
}
