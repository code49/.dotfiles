# initial configuration from: https://github.com/justinlime/dotfiles
{ pkgs, theme, ... }: {
  home.packages = with pkgs; [ playerctl pavucontrol ];
  #Overlays/Overrides
  nixpkgs.overlays = [
    (self: super: {
      waybar = super.waybar.overrideAttrs (oldAttrs: {
        mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
      });
    })
  ];
  programs.waybar = {
    enable = true;
    settings.mainBar = {
      position = "top";
      layer = "top";
      height = 25;
      margin-top = 0;
      margin-bottom = 0;
      margin-left = 0;
      margin-right = 0;
      modules-left = [
        "custom/launcher"
        "cpu"
        "memory"
        # "disk"
        "custom/playerctl#backward"
        "custom/playerctl#play"
        "custom/playerctl#forward"
        "custom/playerlabel"
      ];
      modules-center = [ "hyprland/workspaces" ];
      modules-right = [
        "tray"
        "battery"
        "pulseaudio"
        "backlight"
        # "network" 
        "clock"
      ];
      clock = {
        format = "{:%a, %d %b, %I:%M %p}";
        tooltip = "true";
        tooltip-format = ''
          <big>{:%Y %B}</big>
          <tt><small>{calendar}</small></tt>'';
        format-alt = " {:%d/%m}";
      };
      "wlr/workspaces" = {
        active-only = false;
        all-outputs = false;
        disable-scroll = false;
        on-scroll-up = "hyprctl dispatch workspace e-1";
        on-scroll-down = "hyprctl dispatch workspace e+1";
        format = "{name}";
        on-click = "activate";
        format-icons = {
          urgent = "";
          active = "";
          default = "";
          sort-by-number = true;
        };
      };
      "custom/playerctl#backward" = {
        format = "󰙣 ";
        on-click = "playerctl previous";
        on-scroll-up = "playerctl volume .05+";
        on-scroll-down = "playerctl volume .05-";
      };
      "custom/playerctl#play" = {
        format = "{icon}";
        return-type = "json";
        exec = ''
          playerctl -a metadata --format '{"text": "{{artist}} - {{markup_escape(title)}}", "tooltip": "{{playerName}} : {{markup_escape(title)}}", "alt": "{{status}}", "class": "{{status}}"}' -F'';
        on-click = "playerctl play-pause";
        on-scroll-up = "playerctl volume .05+";
        on-scroll-down = "playerctl volume .05-";
        format-icons = {
          Playing = "<span>󰏥 </span>";
          Paused = "<span> </span>";
          Stopped = "<span> </span>";
        };
      };
      "custom/playerctl#forward" = {
        format = "󰙡 ";
        on-click = "playerctl next";
        on-scroll-up = "playerctl volume .05+";
        on-scroll-down = "playerctl volume .05-";
      };
      "custom/playerlabel" = {
        format = "<span>󰎈 {} 󰎈</span>";
        return-type = "json";
        max-length = 40;
        exec = ''
          playerctl -a metadata --format '{"text": "{{artist}} - {{markup_escape(title)}}", "tooltip": "{{playerName}} : {{markup_escape(title)}}", "alt": "{{status}}", "class": "{{status}}"}' -F'';
        on-click = "";
      };
      battery = {
        states = {
          good = 95;
          warning = 30;
          critical = 15;
        };
        format = "{icon}  {capacity}%";
        format-charging = "  {capacity}%";
        format-plugged = " {capacity}% ";
        format-alt = "{icon} {time}";
        format-icons = [ "" "" "" "" "" ];
      };

      backlight = {
        device = "intel_backlight";
        format = "{icon} {percent}%";
        format-icons = [ "󰃞 " "󰃟 " "󰃠 " ];
      };

      cpu = {
        interval = 15;
        format = "  {}%";
        max-length = 10;
      };

      memory = {
        interval = 30;
        format = "  {}%";
        max-length = 10;
      };

      disk = {
        interval = 30;
        format = "  {}%";
        max-length = 10;
      };

      network = {
        format-wifi = "  {signalStrength}%";
        format-ethernet = "󰈀 100% ";
        tooltip-format = "Connected to {essid} {ifname} via {gwaddr}";
        format-linked = "{ifname} (No IP)";
        format-disconnected = "󰖪 0% ";
      };
      tray = {
        icon-size = 20;
        spacing = 8;
      };
      pulseaudio = {
        format = "{icon} {volume}%";
        format-muted = "󰝟";
        format-icons = { default = [ "󰕿" "󰖀" "󰕾" ]; };
        # on-scroll-up= "bash ~/.scripts/volume up";
        # on-scroll-down= "bash ~/.scripts/volume down";
        scroll-step = 5;
        on-click = "pavucontrol";
      };
      "custom/randwall" = {
        format = "󰏘";
        # on-click= "bash $HOME/.config/hypr/randwall.sh";
        # on-click-right= "bash $HOME/.config/hypr/wall.sh";
      };
      "custom/launcher" = {
        format = " ";
        on-click = "pkill wofi || wofi";
        tooltip = "false";
      };
    };
    style = ''
      * {
        border: none;
        border-radius: 0px;
        font-family: 'JetBrainsMono Nerd Font';
        font-size: 10px; 
        min-height: 0;
      }

      window#waybar {
        background: transparent;
      }

      #workspaces {
        background: #${theme.dark_background_primary};
        margin: 5px 5px; 
        padding: 8px 5px; 
        border-radius: 16px;
        color: #${theme.base0B};
      }

      #workspaces button {
        padding: 0px 5px;
        margin: 0px 3px;
        border-radius: 16px;
        color: transparent;
        background: #${theme.base0B};
        transition: all 0.3s ease-in-out;
      }

      #workspaces button.active {
        background-color: #${theme.base0Balt};
        color: transparent;
        border-radius: 16px;
        min-width: 50px;
        background-size: 400% 400%; 
        transition: all 0.3s ease-in-out;
      }

      #workspaces button:hover {
        background-color: #${theme.base09};
        color: #${theme.dark_background_primary};
        border-radius: 16px; 
        min-width: 50px;
        background-size: 400% 400%;
      }

      #tray, #pulseaudio, #network, #battery, #disk, #cpu, #memory, #backlight,
      #custom-playerctl.backward, #custom-playerctl.play, #custom-playerctl.forward{
        background: #${theme.dark_background_primary};
        font-weight: bold;
        margin: 5px 0px;
      }

      #tray, #network {
        color: #${theme.base09};
        border-radius: 24px 24px 24px 24px;
        padding: 0 20px;
        margin-left: 7px;
      }

      #pulseaudio, #battery, #backlight {
        color: #${theme.base09};
      }

      #pulseaudio {
        padding: 0;
      }

      #battery {
        border-radius: 24px 0 0 24px;
        margin-left: 7px;
        padding: 0 20px; 
      }

      #backlight {
        border-radius: 0 24px 24px 0;
        padding: 0 20px; 
      }

      #disk, #cpu, #memory {
        color: #${theme.base09};
      }

      #cpu {
        margin-left: 7px; 
        padding: 0 0 0 20px; 
        border-radius: 24px 0 0 24px;
      }

      #memory {
        padding: 0 20px 0 20px; 
        border-radius: 0 24px 24px 0;
      }

      #clock {
        color: #${theme.base0B};
        background: #${theme.dark_background_primary};
        border-radius: 24px 24px 24px 24px;
        padding: 0 20px;
        margin: 5px 7px 5px 7px;
        font-weight: bold;
        font-size: 10px;
      }

      #custom-launcher {
        color: #${theme.base0B};
        background: #${theme.dark_background_primary};
        border-radius: 24px 24px 24px 24px;
        margin: 5px 1px 5px 7px;
        padding: 0px 7px 0px 10px;
        font-size: 14px;
      }

      #custom-playerctl.backward, #custom-playerctl.play, #custom-playerctl.forward {
        background: #${theme.dark_background_primary};
        font-size: 18px;
      }

      #custom-playerctl.backward:hover, #custom-playerctl.play:hover, #custom-playerctl.forward:hover {
        color: #${theme.base09};
      }

      #custom-playerctl.backward {
        color: #${theme.base0B};
        border-radius: 24px 0px 0px 24px;
        padding-left: 16px;
        margin-left: 7px;
      }

      #custom-playerctl.play {
        color: #${theme.base0E};
        padding: 0 5px;
      }

      #custom-playerctl.forward {
        color: #${theme.base0B};
        border-radius: 0px 24px 24px 0px;
        padding-right: 12px;
        margin-right: 7px;
      }

      #custom-playerlabel {
        background: #${theme.dark_background_primary};
        color: #${theme.base09};
        padding: 0 20px;
        border-radius: 24px 24px 24px 24px;
        margin: 5px 0;
        font-weight: bold;
      }

      #window {
        background: #${theme.dark_background_primary};
        padding-left: 15px;
        padding-right: 15px;
        border-radius: 16px;
        margin-top: 5px;
        margin-bottom: 5px;
        font-weight: normal;
        font-style: normal;
      }
    '';
  };
}
# border-radius: 24px 24px 24px 24px;
# padding: 0 20px;
# margin-left: 7px;
