{ config, pkgs, theme, ... }: {
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        hide_cursor = true;
        grace = 0;
      };

      background = {
        # path = "~/wallpapers/shark_coral_background_1_upscale.jpg";
        monitor = ""; # apply to all monitors
        path = "screenshot"; # should be desktop background
        blur_passes = 3;
        blur_size = 8;

        noise = 1.17e-2;
        contrast = 1.3;
        brightness = 0.8;
        vibrancy = 0.21;
        vibrancy_darkness = 0.0;
      };

      input-field = [{
        monitor = "";
        size = "250, 50";
        outline_thickness = 3;
        dots_size = 0.26;
        dots_spacing = 0.64;
        dots_center = true;
        outer_color = "rgba(${theme.base0B_rgb}, 0.5)";
        inner_color = "rgba(${theme.dark_background_primary_rgb}, 0.7)";
        font_color = "rgb(${theme.base0B_rgb})";
        fade_on_empty = true;
        placeholder_text = "";
        hide_input = false;

        position = "0, 50";
        halign = "center";
        valign = "bottom";
      }];

      label = [
        # time
        {
          monitor = "";
          text =
            ''cmd[update:1000] echo "<b><big> $(date +'%H:%M:%S') </big></b>"'';
          color = "rgb(${theme.base0B_rgb})";
          font_size = 64;
          font_family = "JetBrains Mono Nerd Font 10";
          shadow_passes = 3;
          shadow_size = 4;
          position = "0, 16";
          halign = "center";
          valign = "center";
        }

        # date 
        {
          monitor = "";
          text =
            ''cmd[update:18000000] echo "<b> "$(date +'%A, %-d %B %Y')" </b>"'';
          color = "rgb(${theme.base09_rgb})";
          font_size = 24;
          font_family = "JetBrains Mono Nerd Font 10";
          position = "0, -16";
          halign = "center";
          valign = "center";
        }

      ];
    };
  };
}
