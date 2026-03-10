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
      primary = true;
      width = 2880;
      height = 1920;
      refreshRate = 120;
      position = "0x0";
      scale = "1.67";
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
}
