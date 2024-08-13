{ config, pkgs, theme, ... }: {
  services.mako = {
    enable = true;

    sort = "-time";

    # Style
    font = "JetBrainsMono Nerd Font 12";
    width = 300;
    height = 100;
    margin = "10";
    padding = "15";
    borderSize = 2;
    borderRadius = 20;
    icons = true;
    maxIconSize = 48;
    markup = true;
    actions = true;
    defaultTimeout = 5000;
    ignoreTimeout = false;
    maxVisible = 5;
    layer = "overlay";
    anchor = "top-center";

    # coloring 
    textColor = "#" + theme.base07;
    borderColor = "#" + theme.base0B;
    progressColor = "over #" + theme.base09;
    backgroundColor = "#" + theme.dark_background_primary + "80";

    extraConfig = ''
      max-history=100
      on-button-left=dismiss
      on-button-middle=none
      on-button-right=dismiss-all
      on-touch=dismiss

      [urgency=low]
      border-color=#${theme.base0D}
      default-timeout=2000

      [urgency=normal]
      border-color=#${theme.base0B}
      default-timeout=5000

      [urgency=high]
      border-color=#${theme.base0Balt}
      default-timeout=10000
    '';

  };
}
