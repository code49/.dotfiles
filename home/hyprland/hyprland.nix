{ inputs, config, pkgs, theme, ... }: {
  # imports = [ ./hyprlock.nix ./hypridle.nix ];

  wayland.windowManager.hyprland = {
    enable = true;

    xwayland.enable = true;

    settings = {
      "monitor" = [
        "eDP-1,2560x1440@60.00Hz,0x0,1.25"
        "DP-7,2560x1440@165.08Hz,auto-right,1" # home dell display
        "HDMI-A-1,1920x1080@100.00Hz,auto-right,0.75" # cmu school library display (?)
        ",preferred,auto-right,auto" # when connecting some unknown display, go right
      ];

      "exec-once" = [ "bash ~/.dotfiles/home/hyprland/scripts/start.sh",
                      "[workspace 1 silent] nohup firefox -p dchan-personal 'notion.so/davidlechan/d03cd6231ead496e808bdf0fe03f8566''calendar.google.com' 'mail.google.com'",
                      "[workspace 1 silent] nohup firefox -p dchan-personal 'davidlechan.dev' 'open.spotify.com'",
                      "[workspace 2 silent] nohup firefox -p dchan-personal 'discord.com/channels/@me'"
                    ];

      "$terminal" = "kitty";
      "$menu" = "wofi";

      "input" = {
        kb_layout = "us";
        kb_variant = "";
        kb_model = "";
        kb_options = "";
        kb_rules = "";

        follow_mouse = 1;

        touchpad = { natural_scroll = "yes"; };

        sensitivity = 0;

        numlock_by_default = true;
      };

      "cursor" = { hide_on_key_press = true; };

      "xwayland" = { force_zero_scaling = true; };

      env = [ "AQ_DRM_DEVICES,/dev/dri/card2:/dev/dri/card1" ];

      "general" = {
        gaps_in = 4;
        gaps_out = "4,8,8,8";
        border_size = 2;
        "col.active_border" =
          "rgba(${theme.base0B}ee) rgba(${theme.base09}ee) 45deg";
        "col.inactive_border" = "rgba(${theme.dark_background_primary}aa)";

        layout = "master";

        allow_tearing = false;
      };

      "misc" = { disable_hyprland_logo = "yes"; };

      decoration = {
        rounding = 5;

        blur = {
          enabled = true;
          size = 5;
          passes = 2;
          new_optimizations = true;
        };

        drop_shadow = "no";
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

      master = {
        allow_small_split = true;
        mfact = 0.6;
        new_status = "inherit";
        new_on_top = true;
        orientation = "right";
      };

      gestures = { workspace_swipe = "off"; };

      misc = { force_default_wallpaper = 0; };

      device = {
        name = "epic-mouse-v1";
        sensitivity = "-0.5";
      };

      windowrulev2 = [
        "suppressevent maximize, class:.*" # apparently this is nice

        "minsize 100 100,class:^(Dve.exe)$"

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
      bindl = [
        ''
          ,switch:off:Lid Switch,exec,hyprctl keyword monitor "eDP-1,preferred,auto,auto"''
        '',switch:on:Lid Switch,exec,hyprctl keyword monitor "eDP-1,disable"''
      ];

      bind = [

        # desktop/windows management
        "$mod, SPACE, exec, wofi"
        # ''$mod, S, exec, grim -l 2 -g "$(slurp)" - | swappy -f''
        ''$mod, S, exec, grim -l 2 -g "$(slurp -d)" - | wl-copy''
        "$mod, W, killactive,"
        "$mod, F, togglefloating"
        "$mod, Q, exec, $terminal"
        "$mod, F1, layoutmsg, swapnext"
        "$mod, F2, layoutmsg, swapwithmaster master"
        "$mod, F3, layoutmsg, orientationcycle left right center"
        "$mod, F4, layoutmsg, addmaster"
        "$mod, F5, layoutmsg, removemaster"

        # suspend/hibernate
        "$mod CTRL SHIFT ALT, H, exec, systemctl hibernate"
        "$mod CTRL SHIFT, S, exec, systemctl suspend"

        # moving focus
        "$mod, J, movefocus, l"
        "$mod, L, movefocus, r"
        "$mod, I, movefocus, u"
        "$mod, K, movefocus, d"

        # resizing active window 
        "$mod SHIFT, L, resizeactive, 20 0"
        "$mod SHIFT, J, resizeactive, -20 0"
        # "$mod SHIFT, I, resizeactive, 0, -20" # this doesn't do anything in 'master' layout
        # "$mod SHIFT, K, resizeactive, 0, 20" # this doesn't do anything in 'master' layout

        # moving active window
        "$mod CONTROL, J, movewindow, l"
        "$mod CONTROL, L, movewindow, r"
        "$mod CONTROL, I, movewindow, u"
        "$mod CONTROL, K, movewindow, d"

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

        # screen backlight control
        ", xf86MonBrightnessDown, exec, brightnessctl set 5%-"
        ", xf86MonBrightnessUp, exec, brightnessctl set 5%+"
      ];
    };
  };
}
