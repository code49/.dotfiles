{ config, pkgs, theme, ... }: {
  programs.helix = {
    enable = true;

    settings = {
      theme = "custom_theme";

      editor = {
        line-number = "relative";
        mouse = false;
        idle-timeout = 20; # ms before autocomplete

        cursor-shape = {
          insert = "bar";
          normal = "bar";
        };

        statusline = {
          left = [ "spinner" "mode" "file-name" "file-modification-indicator" ];
          center = [ "position" "spacer" "spacer" "position-percentage" ];
          right = [ "diagnostics" ];
        };

        lsp = { display-inlay-hints = true; };

        soft-wrap = {
          enable = true;
          max-wrap = 25;
        };

        indent-guides = {
          render = true;
          character = "┆";
          skip-levels = 1;
        };
      };
    };

    languages.language = [
      {
        name = "nix";
        auto-format = true;
        formatter.command = "${pkgs.nixfmt-classic}/bin/nixfmt";
      }
      {
        name = "python";
        auto-format = true;
      }
    ];

    themes = {
      custom_theme = let
        transparent = "none";
        gray = "#" + theme.base04;
        dark-gray = "#" + theme.base02;
        white = "#" + theme.base06;
        black = "#" + theme.base00;
        red = "#" + theme.base0F;
        light-red = "#" + theme.base08;
        green = "#" + theme.base0C;
        yellow = "#" + theme.base0A;
        pink = "#" + theme.base09;
        blue = "#" + theme.base0B;
        purple = "#" + theme.base0E;
        dark-blue = "#" + theme.base0D;

      in {
        "ui.menu" = transparent;
        "ui.menu.selected" = { modifiers = [ "reversed" ]; };

        "ui.linenr" = {
          fg = gray;
          bg = transparent;
        };
        "ui.linenr.selected" = {
          fg = blue;
          bg = transparent;
          modifiers = [ "bold" ];
        };

        "ui.selection" = {
          fg = black;
          bg = dark-blue;
        };
        "ui.selection.primary" = { modifiers = [ "reversed" ]; };

        "ui.statusline" = {
          fg = purple;
          bg = transparent;
        };
        "ui.statusline.inactive" = {
          fg = dark-gray;
          bg = white;
        };

        "ui.help" = {
          fg = dark-gray;
          bg = white;
        };

        "ui.cursor.modifiers" = [ "reversed" ];
        "ui.cursor.match" = {
          fg = yellow;
          modifiers = [ "underlined" ];
        };

        "ui.gutter" = { bg = black; };

        "comment" = { fg = gray; };

        "variable.parameter" = light-red;
        "variable.other" = blue;
        "variable.builtin" = dark-blue;
        "variable.other.member" = light-red;

        "constant.numeric" = yellow;
        "constant" = yellow;
        "constant.character.escape" = green;

        "attributes" = yellow;
        "type" = purple;
        "string" = red;

        "function" = pink;
        "constructor" = dark-blue;
        "special" = dark-blue;
        "namespace" = dark-blue;

        "keyword" = blue;
        "label" = "#" + theme.base0Balt;

        "diff.plus" = green;
        "diff.delta" = yellow;
        "diff.minus" = red;

        "diagnostic" = { modifiers = [ "underlined" ]; };

        "info" = dark-blue;
        "hint" = dark-gray;
        "debug" = dark-gray;
        "warning" = yellow;
        "error" = light-red;

      };

      # create transparent starlight theme
      starlight_transparent = {
        "inherits" = "starlight";
        "ui.background" = { };
      };

      # create transparent gruvbox theme
      gruvbox_transparent = {
        "inherits" = "gruvbox";
        "ui.background" = { };
      };
    };
  };
}
