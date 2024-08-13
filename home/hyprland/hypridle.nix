{ config, pkgs, ... }: {
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };

      listener = [
        {
          timeout = 3600;
          on-timeout = "loginctl lock-session";
        }
        {
          timout = 3630;
          on-timeout = "hyprctl dispatch dpms off"; # screen off
          on-resume = "hyprctl dispatch dpms on"; # screen on
        }
        {
          timeout = 4200;
          on-timeout = "systemctl suspend"; # suspend
        }
      ];
    };
  };
}
