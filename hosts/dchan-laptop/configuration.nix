{
  inputs,
  config,
  pkgs,
  systemSettings,
  userSettings,
  ...
}:

{
  imports = [ ../../modules/monitors.nix ];

  monitors = [
    {
      name = "eDP-1";
      primary = false;
      width = 2880;
      height = 1920;
      # refreshRate = 120;
      refreshRate = 60;
      position = "0x0";
      scale = "1.67";
    }
    { # austin desk monitor
       name = "DP-1";
       primary = true;
       width = 2560;
       height = 1440;
       refreshRate = 144;
       # refreshRate = 60;
       # position = "0x0";
       scale = "1.00";
    }
    {
      # Home desktop monitor (Dell G2724D)
      name = "DP-2";
      primary = false;
      width = 2560;
      height = 1440;
      refreshRate = 165;
      position = "auto";
      scale = "1";
    }
  ];

  networking.hostName = "dchan-laptop";

  # hardware = {
  #   nvidia = {
  #     # make sure correct Bus ID for system! Can run: lspci
  #     prime = {
  #       # sync.enable = true; # might be good when plugged into external monitor?
  #       nvidiaBusId = "PCI:1:0:0";
  #       intelBusId = "PCI:0:2:0";
  #     };
  #   };
  # };

  # fileSystems."/mnt/windows" = {
  #   device = "/dev/disk/by-label/windows";
  #   fsType = "ntfs3";
  #   options = [ "rw" "uid=1000" "gid=100" "fmask=0022" "dmask=0022" "nofail" ];
  # };
}
