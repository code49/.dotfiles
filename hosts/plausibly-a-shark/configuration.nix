{ inputs, config, pkgs, systemSettings, userSettings, ... }: {
  imports = [ ../../modules/monitors.nix ];

  monitors = [ ];

  networking.hostName = "plausibly-a-shark";
}
