{ inputs, config, pkgs, systemSettings, userSettings, ... }:

{
  imports = [ ../../modules/monitors.nix ];

  monitors = [{
    name = "DP-5";
    primary = true;
    width = 3440;
    height = 1440;
    refreshRate = 175;
    position = "0x0";
    enabled = true;
    scale = "1";
  }];

  networking.hostName = "conceivably-a-shark";

  hardware = {
    nvidia = {
      # make sure correct Bus ID for system! Can run: lspci
      prime = {
        # sync.enable = true; # might be good when plugged into external monitor? 
        nvidiaBusId = "PCI:1:0:0";
        intelBusId = "PCI:0:2:0";
      };
    };
  };
}
