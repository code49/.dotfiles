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
    };
  };
}
