{ config, pkgs, theme, ... }: {
  imports = [ ./hyprlock.nix ./hypridle.nix ];

  wayland.windowManager.hyprland = {
    enable = true;

    package = pkgs.hyprland;
    xwayland.enable = true;

    settings = {
      "monitor" = [ ",preferred,auto,auto" "DP-6,3440x1440@175,0x0,1" ];

      "exec-once" =
        [ "bash ~/.dotfiles/home/hyprland/scripts/start.sh" "hypridle &" ];

      "$terminal" = "kitty";
      "$menu" = "wofi";

      "input" = {
        kb_layout = "us";
        kb_variant = "";
        kb_model = "";
        kb_options = "";
        kb_rules = "";

        follow_mouse = 1;

        touchpad = { natural_scroll = "no"; };

        sensitivity = 0;
      };

      "xwayland" = { force_zero_scaling = true; };

      env = [
        # force reasonable cursor sizes 
        "GDK_SCALE, 2"
        "XCURSOR_SIZE,32"
      ];

      "general" = {
        gaps_in = 5;
        gaps_out = "5,10,10,10";
        border_size = 2;
        "col.active_border" =
          "rgba(${theme.base0B}ee) rgba(${theme.base09}ee) 45deg";
        "col.inactive_border" = "rgba(${theme.dark_background_primary}aa)";

        layout = "dwindle";

        allow_tearing = false;
      };

      "misc" = { disable_hyprland_logo = "yes"; };

      decoration = {
        rounding = 10;

        blur = {
          enabled = true;
          size = 5;
          passes = 1;
          new_optimizations = true;
        };

        drop_shadow = "yes";
        shadow_range = 4;
        shadow_render_power = 3;
        "col.shadow" = "rgba(1a1a1aee)";
      };

      animations = {
        enabled = true;

        bezier = [
          "myBezier, 0.65, 0, 0.35, 1"
          "borderChangeBezier, 0.34, 1.56, 0.64, 1"
          "workspaceChangeBezier, 0.33, 1, 0.68, 1"
        ];

        animation = [
          "windows, 1, 7, default, slide"
          # "windowsOut, 1, 7, myBezier, slide"
          # "windowsMove, 1, 5, myBezier, slide"
          "border, 1, 20, borderChangeBezier"
          "borderangle, 1, 800, default, loop"
          "fade, 1, 7, default"
          "workspaces, 1, 6, workspaceChangeBezier, fade"
        ];
      };

      dwindle = {
        pseudotile = "yes";
        preserve_split = "yes";
      };

      master = { new_is_master = true; };

      gestures = { workspace_swipe = "off"; };

      misc = { force_default_wallpaper = 0; };

      device = {
        name = "epic-mouse-v1";
        sensitivity = "-0.5";
      };

      windowrulev2 = [
        "suppressevent maximize, class:.*" # apparently this is nice

        "opacity 1.0 0.6,class:^(kitty)$"
        "opacity 0.7 0.7,class:^(code-oss)$"

        "noanim,class:^(wofi)$"

        "opacity 0.7 0.5,class:^(obsidian)$ "
        "tile,class:^(obsidian)$ # force obsidian to tile "

        "opacity 0.7 0.7,class:^(discord)$"
        "opacity 0.5 0.3,class:^(Spotify)$"

        "opacity 0.8 0.8,class:^(firefox)$,title:(Gradescope)(.*)$"
        "opacity 0.7 0.7,class:^(firefox)$,title:(Google Calendar)(.*)$"
        "opacity 0.7 0.7,class:^(firefox)$,title:^((?!GitHub))(Dashboard — )(.*)$"
        "opacity 0.8 0.8,class:^(firefox)$,title:(Wikipedia)(.*)$"
        "opacity 0.7 0.7,class:^(firefox)$,title:(RapidIdentity)(.*)$"
        "opacity 0.7 0.7,class:^(firefox)$,title:(.*)(Online LaTeX Editor Overleaf)(.*)$"
        "opacity 0.7 0.7,class:^(firefox)$,title:(.*)(Harvey Mudd College Mail)(.*)$"
        "opacity 0.7 0.7,class:^(firefox)$,title:(Inbox )(.*)(theorodester@gmail.com)(.*)$"

        "opacity 0.7 0.7,class:^(rstudio)$"
      ];

      "$mod" = "SUPER";

      # turning off laptop screen on lid close
      # bindl = [
      #   '',switch:off:Lid Switch,exec,hyprctl keyword monitor "eDP-1,preferred,auto,auto"''
      #   '',switch:on:Lid Switch,exec,hyprctl keyword monitor "eDP-1,disable"''
      # ];

      bind = [
        "$mod, SPACE, exec, wofi"
        # ''$mod, S, exec, grim -l 2 -g "$(slurp)" - | swappy -f''
        ''$mod, S, exec, grim -l 2 -g "$(slurp -d)" - | wl-copy''
        "$mod, W, killactive,"
        "$mod, M, exit"
        "$mod, V, togglefloating"

        "$mod, Q, exec, $terminal"
        "$mod, F, exec, firefox"

        # suspend/hibernate
        "$mod CTRL SHIFT, H, exec, systemctl hibernate"
        "$mod CTRL SHIFT, S, exec, systemctl suspend"

        # moving focus
        "$mod, H, movefocus, l"
        "$mod, L, movefocus, r"
        "$mod, K, movefocus, u"
        "$mod, J, movefocus, d"

        # resizing active window 
        "$mod SHIFT, L, resizeactive, 20 0"
        "$mod SHIFT, H, resizeactive, -20 0"
        "$mod SHIFT, K, resizeactive, 0, -20"
        "$mod SHIFT, J, resizeactive, 0, 20"

        # moving active window
        "$mod CTRL, H, movewindow, l"
        "$mod CTRL, L, movewindow, r"
        "$mod CTRL, K, movewindow, u"
        "$mod CTRL, J, movewindow, d"

        # moving workspaces
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"

        # moving windows to workspaces
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"

        # media keybinds
        ", xf86audioraisevolume, exec, pamixer -i 5"
        ", xf86audiolowervolume, exec, pamixer -d 5"
        ", xf86audioMute, exec, pamixer -t"

        # keyboard brightness control 
        ", xf86KbdBrightnessDown, exec, brightnessctl -d dell::kbd_backlight set 33%-"
        ", xf86KbdBrightnessUp, exec, brightnessctl -d dell::kbd_backlight set 33%+"

        # screen backlight control
        ", xf86MonBrightnessDown, exec, brightnessctl set 10%-"
        ", xf86MonBrightnessUp, exec, brightnessctl set 10%+"
      ];
    };
  };
}
