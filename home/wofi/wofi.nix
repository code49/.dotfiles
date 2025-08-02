{ config, pkgs, theme, ... }: {
  programs.wofi = {
    enable = true;

    settings = {
      hide_scroll = true;
      show = "drun";
      width = "30%";
      height = "20%";
      line_wrap = "word";
      term = "kitty";
      allow_markup = true;
      always_parse_args = false;
      show_all = true;
      print_command = true;
      layer = "overlay";
      allow_images = true;
      sort_order = "alphabetical";
      gtk_dark = true;
      prompt = "";
      image_size = 20;
      display_generic = false;
      location = "center";
      key_expand = "Tab";
      insensitive = false;
    };

    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font";
        color: #${theme.base06};
        background: transparent; 
        font-size: 12px;
      }

      #window {
        background: rgba(${theme.dark_background_primary_rgb}, 0.4);
        margin: auto;
        padding: 10px;
        border-radius: 20px; 
        border: 3px solid #${theme.base0B};
      }

      #input {
        padding: 10px;
        margin-bottom: 10px;
        border-radius: 15px; 
      }

      #img {
        margin-right: 6px;
      }

      #entry { 
        padding: 10px; 
        border-radius: 15px; 
      }

      #outer-box {
        padding: 10px;
      }

      #entry:selected {
        background-color: #${theme.base09};
      }

      #text {
        margin: 2px;
      }
    '';
  };
}
