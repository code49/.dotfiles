{
  inputs,
  config,
  pkgs,
  systemSettings,
  userSettings,
  ...
}:

{
  imports = [
    ../../modules/monitors.nix
    inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series
  ];

  # AMD GPU/SoC specific hardware configurations
  boot.initrd.kernelModules = [ "amdgpu" ];
  services.xserver.videoDrivers = [ "amdgpu" ];

  # AMDGPU configuration for Ryzen AI 300 series (Strix Point / GFX1150).
  # Note: amdgpu.cwsr_enable=0 and amdgpu.mes=0 both break ring queue preemption and cause "AMD MES ring buffer full" deadlocks on GFX1150.
  # Panel Self Refresh (PSR) power state transitions are the true cause of hangs; amdgpu.dcdebugmask=0x10 mitigates PSR issues while keeping MES/CWSR operational.
  boot.kernelParams = [
    "amdgpu.dcdebugmask=0x10"
  ];

  monitors = [
    {
      name = "eDP-1";
      primary = false;
      width = 2880;
      height = 1920;
      # refreshRate = 120;
      refreshRate = 60;
      position = "0x0";
      scale = "1.60";
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
  # Enable USB autosuspend for the Framework Storage Expansion Card to reduce heat and power draw
  services.udev.extraRules = ''
    # Enable autosuspend on the parent Framework Storage Expansion USB device
    ACTION=="add|change", SUBSYSTEM=="usb", ATTRS{idVendor}=="32ac", ATTRS{idProduct}=="0005", ATTR{power/control}="auto"

    # Configure power management for the SCSI disk backing the USB device
    ACTION=="add|change", SUBSYSTEM=="scsi", ATTRS{idVendor}=="32ac", ATTRS{idProduct}=="0005", ATTR{power/control}="auto", ATTR{power/autosuspend_delay_ms}="2000"
    ACTION=="add|change", SUBSYSTEM=="scsi_disk", ATTRS{idVendor}=="32ac", ATTRS{idProduct}=="0005", ATTR{manage_runtime_start_stop}="1", ATTR{manage_system_start_stop}="1"
  '';
}

