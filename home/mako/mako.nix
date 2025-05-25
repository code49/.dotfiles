{ config, pkgs, theme, ... }: {
  services.mako = {
    enable = true;

    settings = {
      sort = "-time";

      # Style
      font = "JetBrainsMono Nerd Font 12";
      width = 300;
      height = 100;
      margin = "10";
      padding = "15";
      border-size = 2;
      border-radius = 20;
      icons = true;
      max-icon-size = 48;
      markup = true;
      actions = true;
      default-timeout = 5000;
      ignore-timeout = false;
      max-visible = 5;
      layer = "overlay";
      anchor = "top-center";

      # coloring 
      text-color = "#" + theme.base07;
      border-color = "#" + theme.base0B;
      progress-color = "over #" + theme.base09;
      background-color = "#" + theme.dark_background_primary + "80";

      max-history = 100;
    };
    # onButtonLeft = "dismiss";
    # onButtonMiddle = "none";
    # onButtonRight = "dismiss-all";
    # onTouch = "dismiss";

    # [urgency=low];
    # border-color=#${theme.base0D};
    # default-timeout=2000;

    # [urgency=normal];
    # border-color=#${theme.base0B};
    # default-timeout=5000;

    # [urgency=high];
    # border-color=#${theme.base0Balt};
    # default-timeout=10000;
  };
}
