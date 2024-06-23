{ config, pkgs, theme, ... }: {
  programs.fastfetch = {
    enable = true;

    settings = {
      modules = [
        "title"
        "separator"
        "os"
        "kernel"
        "wm"
        "host"
        "packages"
        "shell"
        "terminal"
        "display"
        "cpu"
        "gpu"
        "memory"
        "disk"
        "battery"
        "uptime"
      ];
    };
  };
}
