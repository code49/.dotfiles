# ❄️ NVIDIA GPU & Intel CPU Host Configuration Template
#
# Use this template as a starting point when setting up a host machine
# equipped with an Intel CPU and a dedicated NVIDIA GPU (e.g., hybrid laptops or towers).

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
    # Option: Import specific hardware modules if you use nixos-hardware profiles
    # inputs.nixos-hardware.nixosModules.common-gpu-nvidia
    # inputs.nixos-hardware.nixosModules.common-cpu-intel
  ];

  networking.hostName = "nvidia-intel-template";

  # ---------- NVIDIA & INTEL HARDWARE OVERRIDES ---------- #

  # 1. Boot / Kernel Modules
  boot.initrd.kernelModules = [ "nvidia" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];

  # 2. Xserver Video Drivers
  services.xserver.videoDrivers = [ "nvidia" ];

  # 3. Hardware Graphics & OpenGL
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      vaapiVdpau
      libvdpau-va-gl
      intel-media-driver # Intel QuickSync / VAAPI
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  # 4. NVIDIA Proprietary Driver Settings
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;      # Set to true if you encounter suspend/hibernate issues
    powerManagement.finegrained = false;  # Experimental offload-power-saving
    open = false;                         # Use NVIDIA open source kernel modules (true for Turing+)
    nvidiaSettings = true;                # Enable nvidia-settings panel (GUI)

    # Hybrid GPU / Optimus prime configuration (laptops only)
    # Run `lspci | grep -E "VGA|3D"` on your system to get the correct Bus IDs.
    prime = {
      # sync.enable = true;               # Keep GPU always active (recommended for external displays)
      # offload.enable = true;            # On-demand offload (saves battery on laptops)

      nvidiaBusId = "PCI:1:0:0";          # Replace with your nvidia Bus ID (lspci notation)
      intelBusId = "PCI:0:2:0";           # Replace with your intel Bus ID (lspci notation)
    };
  };

  # 5. Hardware-specific Environment Variables
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    VK_DRIVER_FILES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json";
  };

  # ---------- MONITOR CONFIGURATION TEMPLATE ---------- #
  monitors = [
    {
      name = "eDP-1";
      primary = true;
      width = 1920;
      height = 1080;
      refreshRate = 60;
      position = "0x0";
      scale = "1.00";
    }
  ];
}
