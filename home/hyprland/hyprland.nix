{ inputs, config, pkgs, theme, nixosSystemMonitors, lib, ... }: {
  # imports = [ ./hyprlock.nix ./hypridle.nix ];

  wayland.windowManager.hyprland = {
    enable = true;

    xwayland.enable = true;
    configType = "lua";

    extraConfig = ''
      pcall(dofile, os.getenv("HOME") .. "/.config/hypr/monitors.lua")
    '';

    settings = {
      # Lua local variables
      terminal = { _var = "kitty"; };
      menu = { _var = "wofi"; };
      mod = { _var = "SUPER"; };

      # Environment variables
      env = [
        # force reasonable cursor sizes
        { _args = [ "XCURSOR_SIZE" "12" ]; }
        { _args = [ "XCURSOR_THEME" "GoogleDot-Violet" ]; }
        { _args = [ "HYPRCURSOR_THEME" "hypr_GoogleDot-Violet" ]; }
        { _args = [ "HYPRCURSOR_SIZE" "18" ]; }

        # Input method for Wayland/Xwayland
        { _args = [ "XMODIFIERS" "@im=fcitx" ]; }
        { _args = [ "SDL_IM_MODULE" "fcitx" ]; }
        { _args = [ "GLFW_IM_MODULE" "fcitx" ]; }
      ];

      # Monitors
      monitor = [
        {
          output = "";
          mode = "preferred";
          position = "auto";
          scale = "auto";
        }
      ] ++ (map (m:
        if (m.enabled or true) then {
          output = m.name;
          mode = "${toString m.width}x${toString m.height}@${toString m.refreshRate}";
          position = m.position;
          scale = m.scale;
        } else {
          output = m.name;
          disabled = true;
        }
      ) nixosSystemMonitors);

      # Autostart
      on = [
        {
          _args = [
            "hyprland.start"
            (lib.generators.mkLuaInline ''
              function()
                hl.exec_cmd("bash ~/.dotfiles/home/hyprland/scripts/start.sh")
                hl.exec_cmd("python3 ~/.dotfiles/home/hyprland/scripts/monitor_fallback.py --daemon")
                hl.exec_cmd("fcitx5 -d --disable notificationitem")
              end
            '')
          ];
        }
      ];

      # Core compositor configuration
      config = {
        input = {
          kb_layout = "us";
          kb_variant = "";
          kb_model = "";
          kb_options = "";
          kb_rules = "";

          follow_mouse = 1;

          touchpad = {
            natural_scroll = true;
          };

          sensitivity = 0.0;
        };

        xwayland = {
          force_zero_scaling = true;
        };

        cursor = {
          no_hardware_cursors = true;
        };

        general = {
          gaps_in = 4;
          gaps_out = {
            top = 4;
            right = 8;
            bottom = 8;
            left = 8;
          };
          border_size = 2;
          col = {
            active_border = {
              colors = [
                "rgba(${theme.base0B}ee)"
                "rgba(${theme.base09}ee)"
              ];
              angle = 45;
            };
            inactive_border = "rgba(${theme.dark_background_primary}aa)";
          };

          layout = "scrolling";

          allow_tearing = false;
          no_focus_fallback = true;
        };

        misc = {
          disable_hyprland_logo = true;
          force_default_wallpaper = 0;
        };

        decoration = {
          rounding = 5;

          blur = {
            enabled = true;
            size = 5;
            passes = 2;
          };
        };

        animations = {
          enabled = true;
        };

        dwindle = {
          preserve_split = true;
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
          wrap_swapcol = false;
        };

        binds = {
          window_direction_monitor_fallback = false;
        };
      };

      # Animation curves
      curve = [
        {
          _args = [
            "myBezier"
            { type = "bezier"; points = [ [ 0.65 0.0 ] [ 0.35 1.0 ] ]; }
          ];
        }
        {
          _args = [
            "borderChangeBezier"
            { type = "bezier"; points = [ [ 0.34 1.56 ] [ 0.64 1.0 ] ]; }
          ];
        }
        {
          _args = [
            "workspaceChangeBezier"
            { type = "bezier"; points = [ [ 0.33 1.0 ] [ 0.68 1.0 ] ]; }
          ];
        }
      ];

      # Animations
      animation = [
        { leaf = "windows"; enabled = true; speed = 7; bezier = "default"; style = "slide"; }
        { leaf = "border"; enabled = true; speed = 20; bezier = "borderChangeBezier"; }
        { leaf = "borderangle"; enabled = true; speed = 80; bezier = "default"; style = "loop"; }
        { leaf = "fade"; enabled = true; speed = 7; bezier = "default"; }
        { leaf = "workspaces"; enabled = true; speed = 6; bezier = "workspaceChangeBezier"; style = "fade"; }
      ];

      # Window rules
      window_rule = [
        {
          name = "suppress-maximize-events";
          match = { class = ".*"; };
          suppress_event = "maximize";
        }
        {
          match = { class = "^(Dve.exe)$"; };
          min_size = "100 100";
        }
        {
          match = { class = "^(kitty)$"; };
          opacity = "1.0 0.6";
        }
        {
          match = { class = "^(code-oss)$"; };
          opacity = "1.0 1.0";
        }
        {
          match = { class = "^(wofi)$"; };
          no_anim = true;
        }
        {
          match = { class = "^(obsidian)$"; };
          opacity = "0.7 0.5";
          tile = true;
        }
        {
          match = { class = "^(discord)$"; };
          opacity = "0.7 0.7";
        }
        {
          match = { class = "^(Spotify)$"; };
          opacity = "0.7 0.7";
        }
        {
          match = {
            class = "^(firefox)$";
            title = "(Gradescope)(.*)$";
          };
          opacity = "0.8 0.8";
        }
        {
          match = {
            class = "^(firefox)$";
            title = "(.*)(Instagram)(.*)";
          };
          opacity = "0.7 0.7";
        }
        {
          match = {
            class = "^(firefox)$";
            title = "(Google Calendar)(.*)$";
          };
          opacity = "0.7 0.7";
        }
        {
          match = {
            class = "^(firefox)$";
            title = "^(Dashboard — )(.*)$";
          };
          opacity = "0.7 0.7";
        }
        {
          match = {
            class = "^(firefox)$";
            title = "(.*)(Tasks and Schedule)(.*)";
          };
          opacity = "0.7 0.7";
        }
        {
          match = { class = "^(rstudio)$"; };
          opacity = "0.7 0.7";
        }
      ];

      # Keybindings
      bind = [
        # Laptop lid switch
        {
          _args = [
            "switch:off:Lid Switch"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("python3 ~/.dotfiles/home/hyprland/scripts/monitor_profile_manager.py auto")'')
            { locked = true; }
          ];
        }
        {
          _args = [
            "switch:on:Lid Switch"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("hyprctl eval 'hl.monitor({ output = \"eDP-1\", disabled = true })'")'')
            { locked = true; }
          ];
        }

        # desktop/windows management
        { _args = [ (lib.generators.mkLuaInline ''mod .. " + SPACE"'') (lib.generators.mkLuaInline ''hl.dsp.exec_cmd(menu)'') ]; }
        { _args = [ (lib.generators.mkLuaInline ''mod .. " + SHIFT + M"'') (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("nwg-displays")'') ]; }
        { _args = [ (lib.generators.mkLuaInline ''mod .. " + S"'') (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("grim -l 2 -g \"$(slurp -d)\" - | wl-copy")'') ]; }
        { _args = [ (lib.generators.mkLuaInline ''mod .. " + W"'') (lib.generators.mkLuaInline ''hl.dsp.window.close()'') ]; }
        { _args = [ (lib.generators.mkLuaInline ''mod .. " + F"'') (lib.generators.mkLuaInline ''hl.dsp.window.float({ action = "toggle" })'') ]; }
        { _args = [ (lib.generators.mkLuaInline ''mod .. " + Q"'') (lib.generators.mkLuaInline ''hl.dsp.exec_cmd(terminal)'') ]; }

        # scrolling layout - native swapcol without wrapping
        { _args = [ (lib.generators.mkLuaInline ''mod .. " + F1"'') (lib.generators.mkLuaInline ''hl.dsp.layout("swapcol l")'') ]; }
        { _args = [ (lib.generators.mkLuaInline ''mod .. " + F2"'') (lib.generators.mkLuaInline ''hl.dsp.layout("swapcol r")'') ]; }
        { _args = [ (lib.generators.mkLuaInline ''mod .. " + F3"'') (lib.generators.mkLuaInline ''hl.dsp.layout("expel")'') ]; }
        { _args = [ (lib.generators.mkLuaInline ''mod .. " + SHIFT + F3"'') (lib.generators.mkLuaInline ''hl.dsp.layout("consume")'') ]; }

        # lock/suspend/hibernate
        { _args = [ (lib.generators.mkLuaInline ''mod .. " + CTRL + SHIFT + ALT + H"'') (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("systemctl hibernate")'') ]; }
        { _args = [ (lib.generators.mkLuaInline ''mod .. " + CTRL + SHIFT + S"'') (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("systemctl suspend")'') ]; }
        { _args = [ (lib.generators.mkLuaInline ''mod .. " + CTRL + SHIFT + L"'') (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("swaylock -f")'') ]; }

        # moving focus
        { _args = [ (lib.generators.mkLuaInline ''mod .. " + H"'') (lib.generators.mkLuaInline ''hl.dsp.focus({ direction = "left" })'') ]; }
        { _args = [ (lib.generators.mkLuaInline ''mod .. " + L"'') (lib.generators.mkLuaInline ''hl.dsp.focus({ direction = "right" })'') ]; }
        { _args = [ (lib.generators.mkLuaInline ''mod .. " + K"'') (lib.generators.mkLuaInline ''hl.dsp.focus({ direction = "up" })'') ]; }
        { _args = [ (lib.generators.mkLuaInline ''mod .. " + J"'') (lib.generators.mkLuaInline ''hl.dsp.focus({ direction = "down" })'') ]; }

        # scrolling layout navigation
        { _args = [ (lib.generators.mkLuaInline ''mod .. " + SHIFT + N"'') (lib.generators.mkLuaInline ''hl.dsp.layout("move -col")'') ]; }
        { _args = [ (lib.generators.mkLuaInline ''mod .. " + SHIFT + M"'') (lib.generators.mkLuaInline ''hl.dsp.layout("move +col")'') ]; }

        # resizing active window
        { _args = [ (lib.generators.mkLuaInline ''mod .. " + E"'') (lib.generators.mkLuaInline ''hl.dsp.layout("colresize 0.5")'') ]; }
        { _args = [ (lib.generators.mkLuaInline ''mod .. " + R"'') (lib.generators.mkLuaInline ''hl.dsp.layout("colresize 1.0")'') ]; }
        { _args = [ (lib.generators.mkLuaInline ''mod .. " + SHIFT + L"'') (lib.generators.mkLuaInline ''hl.dsp.layout("colresize +0.05")'') ]; }
        { _args = [ (lib.generators.mkLuaInline ''mod .. " + SHIFT + H"'') (lib.generators.mkLuaInline ''hl.dsp.layout("colresize -0.05")'') ]; }
        { _args = [ (lib.generators.mkLuaInline ''mod .. " + SHIFT + K"'') (lib.generators.mkLuaInline ''hl.dsp.window.resize({ x = 0, y = -20, relative = true })'') ]; }
        { _args = [ (lib.generators.mkLuaInline ''mod .. " + SHIFT + J"'') (lib.generators.mkLuaInline ''hl.dsp.window.resize({ x = 0, y = 20, relative = true })'') ]; }

        # moving active window
        { _args = [ (lib.generators.mkLuaInline ''mod .. " + CTRL + H"'') (lib.generators.mkLuaInline ''hl.dsp.window.move({ direction = "left" })'') ]; }
        { _args = [ (lib.generators.mkLuaInline ''mod .. " + CTRL + L"'') (lib.generators.mkLuaInline ''hl.dsp.window.move({ direction = "right" })'') ]; }
        { _args = [ (lib.generators.mkLuaInline ''mod .. " + CTRL + K"'') (lib.generators.mkLuaInline ''hl.dsp.window.move({ direction = "up" })'') ]; }
        { _args = [ (lib.generators.mkLuaInline ''mod .. " + CTRL + J"'') (lib.generators.mkLuaInline ''hl.dsp.window.move({ direction = "down" })'') ]; }
      ]
      # moving workspaces & windows to workspaces
      ++ (lib.flatten (map (i:
        let
          key = if i == 10 then "0" else toString i;
          ws = toString i;
        in [
          { _args = [ (lib.generators.mkLuaInline ''mod .. " + ${key}"'') (lib.generators.mkLuaInline ''hl.dsp.focus({ workspace = "${ws}" })'') ]; }
          { _args = [ (lib.generators.mkLuaInline ''mod .. " + SHIFT + ${key}"'') (lib.generators.mkLuaInline ''hl.dsp.window.move({ workspace = "${ws}" })'') ]; }
          { _args = [ (lib.generators.mkLuaInline ''mod .. " + CTRL + SHIFT + ${key}"'') (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("python3 ~/.dotfiles/home/hyprland/scripts/move_workspace_windows.py ${ws}")'') ]; }
        ]
      ) (lib.range 1 10)))
      # media keybinds
      ++ [
        { _args = [ "XF86AudioRaiseVolume" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("pamixer -i 5")'') { locked = true; repeating = true; } ]; }
        { _args = [ "XF86AudioLowerVolume" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("pamixer -d 5")'') { locked = true; repeating = true; } ]; }
        { _args = [ "XF86AudioMute" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("pamixer -t")'') { locked = true; } ]; }
        { _args = [ "XF86AudioPlay" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("playerctl play-pause")'') { locked = true; } ]; }
        { _args = [ "XF86AudioPause" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("playerctl play-pause")'') { locked = true; } ]; }
        { _args = [ "XF86AudioNext" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("playerctl next")'') { locked = true; } ]; }
        { _args = [ "XF86AudioPrev" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("playerctl previous")'') { locked = true; } ]; }

        # keyboard brightness control
        { _args = [ "XF86KbdBrightnessDown" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("brightnessctl -d dell::kbd_backlight set 33%-")'') { locked = true; repeating = true; } ]; }
        { _args = [ "XF86KbdBrightnessUp" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("brightnessctl -d dell::kbd_backlight set 33%+")'') { locked = true; repeating = true; } ]; }

        # screen backlight control
        { _args = [ "XF86MonBrightnessDown" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("brightnessctl set 5%-")'') { locked = true; repeating = true; } ]; }
        { _args = [ "XF86MonBrightnessUp" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("brightnessctl set 5%+")'') { locked = true; repeating = true; } ]; }
      ];
    };
  };
}
