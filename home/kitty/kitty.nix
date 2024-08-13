{ config, pkgs, theme, ... }: {
  programs.kitty = {
    enable = true;

    settings = {
      # include = "~/.dotfiles/home/kitty/custom_theme.conf";
      font_family = "jetbrains mono nerd font";
      font_size = 12;
      bold_font = "auto";
      italic_font = "auto";
      bold_italic_font = "auto";
      mouse_hide_wait = "2.0";
      cursor_shape = "block";
      url_style = "dotted";

      confirm_os_window_close = 0;
      background_opacity = "0.6";

      # theme 
      background = "#" + theme.base00;
      foreground = "#" + theme.base05;

      cursor = "#" + theme.base0Dalt;
      selection_foreground = "#" + theme.base0Dalt;
      selection_background = "#" + theme.base01;

      color0 = "#" + theme.base00;
      color8 = "#" + theme.base04;

      color1 = "#" + theme.base08;
      color9 = "#" + theme.base08alt;

      color2 = "#" + theme.base0E;
      color10 = "#" + theme.base0Ealt;

      color3 = "#" + theme.base0A;
      color11 = "#" + theme.base0Aalt;

      color4 = "#" + theme.base0B;
      color12 = "#" + theme.base0Balt;

      color5 = "#" + theme.base0D;
      color13 = "#" + theme.base0Dalt;

      color6 = "#" + theme.base09;
      color14 = "#" + theme.base09alt;

      color7 = "#" + theme.base0F;
      color15 = "#" + theme.base0Falt;
    };
  };
}
