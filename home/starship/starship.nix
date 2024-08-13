{ config, pkgs, lib, theme, ... }: {
  # configuring starship (the cool terminal wiget stuff)
  programs.starship = with lib;
    let
      # this is the initial bit background color 
      color1 = "#" + theme.base0B; # "#a3aed2"; # "#a3aed2"

      # this is the secondary text color
      color2 = "#" + theme.dark_background_primary; # "#20bafb"; # "#090c0c"

      # these define a gradient in an accent color (blue here)
      color3 = "#" + theme.base0Dalt; # "#008bc2";
      color4 = "#" + theme.base0Dalt2; # "#026893";
      color5 = "#" + theme.base0Dalt3; # "#024766";
      color6 = "#" + theme.base0Dalt4; # "#01283c";
    in {
      enable = true;

      settings = {
        format = lib.concatStrings [
          "[░▒▓█](${color1})"
          # "[ 🚂 ](bg:#a3aed2 fg:#090c0c)"
          "[󰿧](bg:${color1} fg:${color2})"
          "[█](${color1})"
          "[](bg:${color3} fg:${color1})"
          "$directory"
          "[](fg:${color3} bg:${color4})"
          "$git_branch"
          "$git_status"
          "[](fg:${color4} bg:${color5})"
          "$nodejs"
          "$rust"
          "$julia"
          "$golang"
          "$php"
          "$python"
          "[](fg:${color5} bg:${color6})"
          "$time"
          "[ ](fg:${color6})"
          ''

            $character''
        ];

        directory = {
          style = "fg:#e3e5e5 bg:${color3}";
          format = "[ $path ]($style)";
          truncation_length = 3;
          truncation_symbol = "…/";

          substitutions = {
            "Documents" = " ";
            "Downloads" = " ";
            "Music" = " ";
            "Pictures" = " ";
          };
        };

        git_branch = {
          symbol = "";
          style = "bg:${color4}";
          format = "[[ $symbol $branch ](fg:${color3} bg:${color4})]($style)";
        };

        git_status = {
          style = "bg:${color4}";
          format =
            "[[($all_status$ahead_behind )](fg:${color3} bg:${color4})]($style)";
        };

        nodejs = {
          symbol = " ";
          style = "bg:${color5}";
          format =
            "[[ $symbol ($version) ](fg:${color3} bg:${color5})]($style)";
        };

        rust = {
          symbol = "";
          style = "bg:#212736";
          format =
            "[[ $symbol ($version) ](bold fg:#b05c2c bg:${color5})]($style)";
        };

        julia = {
          symbol = " ";
          style = "bg:#212736";
          format =
            "[[ $symbol ($version) ](bold fg:purple bg:${color5})]($style)";
        };

        python = {
          symbol = " ";
          style = "bg:#212736";
          format =
            "[[ $symbol ($version) ](bold fg:yellow bg:${color5})]($style)";
        };

        golang = {
          symbol = "󰟓 ";
          style = "bg:#212736";
          format =
            "[[ $symbol ($version) ](fg:${color3} bg:${color5})]($style)";
        };

        php = {
          symbol = " ";
          style = "bg:#212736";
          format =
            "[[ $symbol ($version) ](fg:${color3} bg:${color5})]($style)";
        };

        time = {
          disabled = true;
          time_format = "%R"; # Hour:Minute Format
          style = "bg:#1d2230";
          format = "[[  $time ](fg:#a0a9cb bg:#1d2230)]($style)";
        };
      };
    };

}
