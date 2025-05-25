{ inputs, config, pkgs, systemSettings, userSettings, ... }:

{
  imports = [ "./conceivably-a-shark-hardware-configuration.nix" ];

  networking.hostName = "conceivably-a-shark";

  nvidia = {
    # make sure correct Bus ID for system! Can run: lspci
    prime = {
      # sync.enable = true; # might be good when plugged into external monitor? 
      nvidiaBusId = "PCI:1:0:0";
      intelBusId = "PCI:0:2:0";
    };
  };
}
