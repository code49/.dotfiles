{ inputs, config, pkgs, theme, nixosSystemMonitors, ... }: {
  # imports = [ ./hyprlock.nix ./hypridle.nix ];

  wayland.windowManager.hyprland = {
    enable = true;

    # package =
    #   inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    xwayland.enable = true;

    # extraConfig = ''
    #   device {
    #     name=logitech-g502-x-plus-millennium-falcon
    #     sensitivity=-0.5
    #   }
    # '';

    settings = {
      monitor = [ ",preferred,auto,auto" ] ++ (map (m:
        "${m.name},${
          if m.enabled then
            "${toString m.width}x${toString m.height}@${
              toString m.refreshRate
            },${m.position},${m.scale}"
          else
            "disable"
        }") (nixosSystemMonitors));

      "exec-once" = [
        "bash ~/.dotfiles/home/hyprland/scripts/start.sh"
        "python3 ~/.dotfiles/home/hyprland/scripts/startup_apps.py"
        "fcitx5 -d --disable notificationitem"
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

        sensitivity = 0.0;
        # force_no_accel = 1;
        # accel_profile = "flat";

      };

      xwayland = { force_zero_scaling = true; };

      env = [
        # force reasonable cursor sizes 
        "XCURSOR_SIZE,12"
        "XCURSOR_THEME,GoogleDot-Violet"
        "HYPRCURSOR_THEME,hypr_GoogleDot-Violet"
        "HYPRCURSOR_SIZE,18"
      ];

      "general" = {
        gaps_in = 4;
        gaps_out = "4,8,8,8";
        border_size = 2;
        "col.active_border" =
          "rgba(${theme.base0B}ee) rgba(${theme.base09}ee) 45deg";
        "col.inactive_border" = "rgba(${theme.dark_background_primary}aa)";

        layout = "scrolling";

        allow_tearing = false;
        no_focus_fallback = true;
      };

      "misc" = { disable_hyprland_logo = "yes"; };

      decoration = {
        rounding = 5;

        blur = {
          enabled = true;
          size = 5;
          passes = 2;
        };

        # drop_shadow = "no";
        # shadow_range = 4;
        # shadow_render_power = 3;
        # "col.shadow" = "rgba(1a1a1aee)";
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

      scrolling = {
        fullscreen_on_one_column = true;
        column_width = 1.0;
        explicit_column_widths = "0.5, 1.0";
        direction = "right";
        focus_fit_method = 1;
        follow_focus = true;
      };

      misc = { force_default_wallpaper = 0; };

      # device = [
      #   {
      #     name = "epic-mouse-v1";
      #     sensitivity = "-0.5";
      #   }

      #   {
      #     name = "logitech-g502-x-plus-millennium-falcon";
      #     sensitivity = "-0.5";
      #   }
      # ];

      windowrule = [
        "match:class .*, suppress_event maximize" # apparently this is nice

        "match:class ^(Dve.exe)$, min_size 100 100"

        "match:class ^(kitty)$, opacity 1.0 0.6"
        # Keep VSCode opaque while debugging post-suspend blur.
        "match:class ^(code-oss)$, opacity 1.0 1.0"

        "match:class ^(wofi)$, no_anim on"

        "match:class ^(obsidian)$, opacity 0.7 0.5"
        "match:class ^(obsidian)$, tile on # force obsidian to tile "

        "match:class ^(discord)$, opacity 0.7 0.7"
        "match:class ^(Spotify)$, opacity 0.7 0.7"

        "match:class ^(firefox)$, match:title (Gradescope)(.*)$, opacity 0.8 0.8"
        "match:class ^(firefox)$, match:title (.*)(Instagram)(.*), opacity 0.7 0.7"
        "match:class ^(firefox)$, match:title (Google Calendar)(.*)$, opacity 0.7 0.7"
        "match:class ^(firefox)$, match:title ^((?!GitHub))(Dashboard — )(.*)$, opacity 0.7 0.7"
        # "opacity 0.8 0.8,class:^(firefox)$,title:(Wikipedia)(.*)$"
        # "opacity 0.7 0.7,class:^(firefox)$,title:(.*)(Online LaTeX Editor Overleaf)(.*)$"
        "match:class ^(firefox)$, match:title (.*)(Tasks and Schedule)(.*), opacity 0.7 0.7"
        # "opacity 0.7 0.7,class:^(firefox)$,title:(.*)(Carnegie Mellon University Mail)(.*)$"
        # "opacity 0.7 0.7,class:^(firefox)$,title:(Inbox )(.*)(davidlechan@gmail.com)(.*)$"
        "match:class ^(rstudio)$, opacity 0.7 0.7"
      ];

      "$mod" = "SUPER";

      # turning off laptop screen on lid close
      bindl = [
        ''
          ,switch:off:Lid Switch,exec,hyprctl reload''
        '',switch:on:Lid Switch,exec,hyprctl keyword monitor "eDP-1,disable"''
      ];

      # super-keybinds
      bind = [

        # desktop/windows management
        "$mod, SPACE, exec, wofi"
        # ''$mod, S, exec, grim -l 2 -g "$(slurp)" - | swappy -f''
        ''$mod, S, exec, grim -l 2 -g "$(slurp -d)" - | wl-copy''
        "$mod, W, killactive,"
        "$mod, F, togglefloating"
        "$mod, Q, exec, $terminal"
        # NOTE: In Hyprland v0.55+, swapcol wrapping can be disabled natively by setting 
        # `scrolling.wrap_swapcol = false;` in configuration. For v0.54.x, we use a custom script instead.
        "$mod, F1, exec, ~/.dotfiles/home/hyprland/scripts/swapcol_nowrap.py l"
        "$mod, F2, exec, ~/.dotfiles/home/hyprland/scripts/swapcol_nowrap.py r"
        "$mod, F3, layoutmsg, expel"
        "$mod SHIFT, F3, layoutmsg, consume"
        # "$mod, F5, layoutmsg, removemaster"

        # suspend/hibernate
        "$mod CTRL SHIFT ALT, H, exec, systemctl hibernate"
        "$mod CTRL SHIFT, S, exec, systemctl suspend"

        # moving focus
        "$mod, H, movefocus, l"
        "$mod, L, movefocus, r"
        "$mod, K, movefocus, u"
        "$mod, J, movefocus, d"

        # scrolling layout navigation
        "$mod SHIFT, N, layoutmsg, move -col"
        "$mod SHIFT, M, layoutmsg, move +col"

        # resizing active window 
        "$mod SHIFT, L, layoutmsg, colresize +0.05"
        "$mod SHIFT, H, layoutmsg, colresize -0.05"
        "$mod SHIFT, K, resizeactive, 0 -20"
        "$mod SHIFT, J, resizeactive, 0 20"

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

        # moving entire workspace's windows to another workspace (preserving order)
        "$mod CTRL SHIFT, 1, exec, python3 ~/.dotfiles/home/hyprland/scripts/move_workspace_windows.py 1"
        "$mod CTRL SHIFT, 2, exec, python3 ~/.dotfiles/home/hyprland/scripts/move_workspace_windows.py 2"
        "$mod CTRL SHIFT, 3, exec, python3 ~/.dotfiles/home/hyprland/scripts/move_workspace_windows.py 3"
        "$mod CTRL SHIFT, 4, exec, python3 ~/.dotfiles/home/hyprland/scripts/move_workspace_windows.py 4"
        "$mod CTRL SHIFT, 5, exec, python3 ~/.dotfiles/home/hyprland/scripts/move_workspace_windows.py 5"
        "$mod CTRL SHIFT, 6, exec, python3 ~/.dotfiles/home/hyprland/scripts/move_workspace_windows.py 6"
        "$mod CTRL SHIFT, 7, exec, python3 ~/.dotfiles/home/hyprland/scripts/move_workspace_windows.py 7"
        "$mod CTRL SHIFT, 8, exec, python3 ~/.dotfiles/home/hyprland/scripts/move_workspace_windows.py 8"
        "$mod CTRL SHIFT, 9, exec, python3 ~/.dotfiles/home/hyprland/scripts/move_workspace_windows.py 9"
        "$mod CTRL SHIFT, 0, exec, python3 ~/.dotfiles/home/hyprland/scripts/move_workspace_windows.py 10"

        # media keybinds
        ", xf86audioraisevolume, exec, pamixer -i 5"
        ", xf86audiolowervolume, exec, pamixer -d 5"
        ", xf86audioMute, exec, pamixer -t"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"

        # keyboard brightness control 
        ", xf86KbdBrightnessDown, exec, brightnessctl -d dell::kbd_backlight set 33%-"
        ", xf86KbdBrightnessUp, exec, brightnessctl -d dell::kbd_backlight set 33%+"

        # screen backlight control
        ", xf86MonBrightnessDown, exec, brightnessctl set 5%-"
        ", xf86MonBrightnessUp, exec, brightnessctl set 5%+"
      ];

      binds = {
        window_direction_monitor_fallback = false;
      };

    };
  };
}
