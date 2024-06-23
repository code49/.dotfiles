{ config, pkgs, theme, ... }: {
  programs.swaylock = {
    enable = true;
    settings = {
      image =
        "~/.dotfiles/wallpapers/shark_coral_background_1_upscale_blurred.jpg";

      font = "JetBrainsMono Nerd Font";
      font-size = 40;

      text-color = theme.base0B + "C0";
      text-clear-color = theme.base09 + "C0";
      text-caps-lock-color = theme.base09 + "C0";
      text-ver-color = theme.base0B + "C0";
      text-wrong-color = theme.base09 + "C0";

      indicator-idle-visible = false;
      indicator-radius = 100;
      indicator-thickness = 20;
      inside-color = theme.dark_background_primary + "80";
      inside-clear-color = theme.dark_background_primary + "80";
      inside-caps-lock-color = theme.dark_background_primary + "80";
      inside-ver-color = theme.dark_background_primary + "80";
      inside-wrong-color = theme.dark_background_primary + "80";

      key-hl-color = theme.base0B + "C0";
      bs-hl-color = theme.base09 + "C0";

      layout-bg-color = theme.dark_background_primary + "80";
      layout-border-color = theme.dark_background_primary + "80";
      layout-text-color = theme.dark_background_primary + "80";

      line-color = theme.dark_background_primary + "00";
      line-clear-color = theme.dark_background_primary + "00";
      line-caps-lock-color = theme.dark_background_primary + "00";
      line-ver-color = theme.dark_background_primary + "00";
      line-wrong-color = theme.dark_background_primary + "00";

      ring-color = theme.dark_background_primary + "80";
      ring-clear-color = theme.dark_background_primary + "80";
      ring-caps-lock-color = theme.dark_background_primary + "80";
      ring-ver-color = theme.dark_background_primary + "80";
      ring-wrong-color = theme.dark_background_primary + "80";

      separator-color = theme.dark_background_primary + "00";

    };
  };
}
