{ inputs, config, pkgs, theme, nixosSystemMonitors, ... }: {
  # imports = [ ./hyprlock.nix ./hypridle.nix ];

  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";

    # package =
    #   inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    xwayland.enable = true;

    extraConfig = ''

      -- hyprcursor

      hl.env("XCURSOR_SIZE", "12")
      hl.env("XCURSOR_THEME", "GoogleDot-Violet")
      hl.env("HYPRCURSOR_THEME", "hypr_GoogleDot-Violet")
      hl.env("HYPRCURSOR_SIZE", "16")

      -- configuration

      hl.config({
          monitor = {
              ${
                builtins.concatStringsSep ",\n              " (map (s: ''"${s}"'')
                  ([ ",preferred,auto,auto" ] ++ (map (m:
                    "${m.name},${
                      if m.enabled then
                        "${toString m.width}x${toString m.height}@${
                          toString m.refreshRate
                        },${m.position},${m.scale}"
                      else
                        "disable"
                    }") (nixosSystemMonitors))))
              }
          },

          input = {
              kb_layout = "us",
              kb_variant = "",
              kb_model = "",
              kb_options = "",
              kb_rules = "",

              follow_mouse = 1,

              touchpad = { natural_scroll = true },

              sensitivity = 0.0,
              force_no_accel = 1,
              accel_profile = "flat",
          },

          xwayland = { 
              force_zero_scaling = true 
          },

          misc = {
              disable_hyprland_logo = true,
              force_default_wallpaper = 0,
          },

          decoration = {
              rounding = 5,

              blur = {
                  enabled = true,
                  size = 5,
                  passes = 2,
                  new_optimizations = true,
              },
          },

          animations = {
              enabled = true,
          },
          
          general = {
              gaps_in = 4,
              gaps_out = {
                  top = 4,
                  right = 8,
                  bottom = 8,
                  left = 8,
              },
              border_size = 2,
              ["col.active_border"] = "rgba(${theme.base0B}ee)",
              ["col.inactive_border"] = "rgba(${theme.dark_background_primary}aa)",
              layout = "master",
              allow_tearing = false,
          },

          -- dwindle layout configuration

          dwindle = { 
              preserve_split = true,
          },

          -- master layout configuration

          master = {
              allow_small_split = true,
              mfact = 0.6,
              new_status = "inherit",
              new_on_top = true,
              orientation = "right",
          },

          -- scrolling layout configuration

          scrolling = {
              fullscreen_on_one_column = true,
              column_width = 0.6,
              wrap_focus = true,
              wrap_swapcol = true,
              direction = "right",
          },  

          debug = { disable_logs = false },
      })

      -- animations

      hl.curve("myBezier", { type = "bezier", points = { {0.65, 0}, {0.35, 1} } })
      hl.curve("borderChangeBezier", { type = "bezier", points = { {0.34, 1.56}, {0.64, 1} } })
      hl.curve("workspaceChangeBezier", { type = "bezier", points = { {0.33, 1}, {0.68, 1} } })

      hl.animation({ leaf = "windows", enabled = true, speed = 7, bezier = "default", style = "slide" })
      hl.animation({ leaf = "border", enabled = true, speed = 20, bezier = "borderChangeBezier" })
      -- hl.animation({ leaf = "borderangle", enabled = true, speed = 800, bezier = "default", style = "loop" }) -- 800 might be too fast?
      hl.animation({ leaf = "fade", enabled = true, speed = 7, bezier = "default" })
      hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "workspaceChangeBezier", style = "fade" })

      -- variables

      local mod = "SUPER"
      local terminal = "kitty"
      local menu = "wofi"

      -- autostart
      
      hl.on("hyprland.start", function()
          hl.exec_cmd("bash ~/.dotfiles/home/hyprland/scripts/start.sh")
      end)

      -- window rules

      hl.window_rule({
          {
              name = "Suppress Maximize",
              match = { class = ".*" },
              suppressevent = "maximize",
          },
          {
              name = "Dve Minsize",
              match = { class = "^(Dve.exe)$" },
              minsize = "100 100",
          },
          {
              name = "Kitty Opacity",
              match = { class = "^(kitty)$" },
              opacity = "1.0 0.6",
          },
          {
              name = "VSCode Opacity",
              match = { class = "^(code-oss)$" },
              opacity = "1.0 1.0",
          },
          {
              name = "Wofi Noanim",
              match = { class = "^(wofi)$" },
              noanim = true,
          },
          {
              name = "Obsidian",
              match = { class = "^(obsidian)$" },
              opacity = "0.7 0.5",
              tile = true,
          },
          {
              name = "Discord Opacity",
              match = { class = "^(discord)$" },
              opacity = "0.7 0.7",
          },
          {
              name = "Spotify Opacity",
              match = { class = "^(Spotify)$" },
              opacity = "0.7 0.7",
          },
          {
              name = "Firefox Gradescope",
              match = { class = "^(firefox)$", title = "(Gradescope)(.*)" },
              opacity = "0.8 0.8",
          },
          {
              name = "Firefox Google Calendar",
              match = { class = "^(firefox)$", title = "(Google Calendar)(.*)" },
              opacity = "0.7 0.7",
          },
          {
              name = "Firefox Dashboard",
              match = { class = "^(firefox)$", title = "^((?!GitHub))(Dashboard — )(.*)" },
              opacity = "0.7 0.7",
          },
          {
              name = "Firefox Tasks",
              match = { class = "^(firefox)$", title = "(.*)(Tasks and Schedule)(.*)" },
              opacity = "0.7 0.7",
          },
      })

      -- -- keybindings
      
      -- suspend/hibernate
      hl.bind(mod .. " + CTRL + SHIFT + ALT + H", hl.dsp.exec_cmd("systemctl hibernate"))
      hl.bind(mod .. " + CTRL + SHIFT + S", hl.dsp.exec_cmd("systemctl suspend"))      

      -- screenshot
      hl.bind(mod .. " + S", hl.dsp.exec_cmd([[grim -l 2 -g "$(slurp -d)" - | wl-copy]]))
      
      -- open/close stuff
      hl.bind(mod .. " + SPACE", hl.dsp.exec_cmd(menu))
      hl.bind(mod .. " + W", hl.dsp.window.close())
      hl.bind(mod .. " + Q", hl.dsp.exec_cmd(terminal))

      -- master layout window management 
      hl.bind(mod .. " + F", hl.dsp.window.float({ action = "toggle" }))     
      hl.bind(mod .. " + F1", hl.dsp.layout("swapnext"))
      hl.bind(mod .. " + F2", hl.dsp.layout("swapwithmaster master"))
      hl.bind(mod .. " + F3", hl.dsp.layout("orientationcycle left right center"))
      hl.bind(mod .. " + F4", hl.dsp.layout("addmaster"))
      hl.bind(mod .. " + F5", hl.dsp.layout("removemaster"))
 
      -- scrolling layout window management
      -- hl.bind()

      -- moving focus
      hl.bind(mod .. " + H", hl.dsp.focus({ direction = "l" }))
      hl.bind(mod .. " + L", hl.dsp.focus({ direction = "r" }))
      hl.bind(mod .. " + K", hl.dsp.focus({ direction = "u" }))
      hl.bind(mod .. " + J", hl.dsp.focus({ direction = "d" }))

      -- resizing active window
      hl.bind(mod .. " + SHIFT + L", hl.dsp.window.resize({ x = 20, y = 0, relative = true }))
      hl.bind(mod .. " + SHIFT + H", hl.dsp.window.resize({ x = -20, y = 0, relative = true }))
      hl.bind(mod .. " + SHIFT + K", hl.dsp.window.resize({ x = 0, y = -20, relative = true }))
      hl.bind(mod .. " + SHIFT + J", hl.dsp.window.resize({ x = 0, y = 20, relative = true }))

      -- moving active window
      hl.bind(mod .. " + CTRL + H", hl.dsp.window.move({ direction = "l" }))
      hl.bind(mod .. " + CTRL + L", hl.dsp.window.move({ direction = "r" }))
      hl.bind(mod .. " + CTRL + K", hl.dsp.window.move({ direction = "u" }))
      hl.bind(mod .. " + CTRL + J", hl.dsp.window.move({ direction = "d" }))

      -- moving workspaces
      for i = 1, 10 do
          local ws = i
          local key = tostring(i % 10)
          hl.bind(mod .. " + " .. (i % 10), hl.dsp.focus({ workspace = ws }))
          hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = ws }))
      end

      -- media keybinds
      hl.bind(" + xf86audioraisevolume", hl.dsp.exec_cmd("pamixer -i 5"))
      hl.bind(" + xf86audiolowervolume", hl.dsp.exec_cmd("pamixer -d 5"))
      hl.bind(" + xf86audioMute", hl.dsp.exec_cmd("pamixer -t"))

      -- keyboard brightness control
      hl.bind(" + xf86KbdBrightnessDown", hl.dsp.exec_cmd("brightnessctl -d dell::kbd_backlight set 33%-"))
      hl.bind(" + xf86KbdBrightnessUp", hl.dsp.exec_cmd("brightnessctl -d dell::kbd_backlight set 33%+"))

      -- screen backlight control
      hl.bind(" + xf86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"))
      hl.bind(" + xf86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 5%+"))

      -- lid Switch
      hl.bind("switch:off:Lid Switch", hl.dsp.exec_cmd("hyprctl reload"), { locked = true })
      hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd([[hyprctl keyword monitor "eDP-1,disable"]]), { locked = true })
    '';
  };
}
