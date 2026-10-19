{ config, pkgs, ... }: {
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl eval 'hl.dispatch(hl.dsp.dpms({ action = \"on\" }))'";
      };

      listener = [
        {
          timeout = 3600;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 3630;
          on-timeout = "hyprctl eval 'hl.dispatch(hl.dsp.dpms({ action = \"off\" }))'"; # screen off
          on-resume = "hyprctl eval 'hl.dispatch(hl.dsp.dpms({ action = \"on\" }))'"; # screen on
        }
        {
          timeout = 4200;
          on-timeout = "systemctl suspend"; # suspend
        }
      ];
    };
  };
}
