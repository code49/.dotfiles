# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, config, pkgs, systemSettings, userSettings, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./applications/steam/steam.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.kernelModules = [ "nvidia" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];

  networking.hostName = systemSettings.hostname; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # use zsh
  environment.shells = with pkgs; [ zsh ];
  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable CUPS to print documents
  services.printing.enable = true;

  # Enable sound with pipewire 
  # sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # caching for hyprland git version 
  # nix.settings = {
  #   substituters = [ "https://hyprland.cachix.org" ];
  #   trusted-public-keys =
  #     [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
  # };

  # Enabling hyprland
  programs.hyprland = {
    enable = true;
    # package =
    #   inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland; # enable git version of hyprland
    xwayland.enable = true;
  };

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    # NIXOS_OZONE_WL = "1"; # THIS WAS CAUSING PROBLEMS WITH (electron) APPS TAKING MINUTES TO LAUNCH

    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";

    POLKIT_AUTH_AGENT =
      "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
    # LIBVA_DRIVER_NAME = "nvidia";
    XDG_SESSION_TYPE = "wayland";

    VK_DRIVER_FILES =
      "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json";

  };

  hardware = {
    # opengl = {
    #   enable = true;
    #   driSupport = true;
    #   driSupport32Bit = true;
    # };

    # this might be needed to replace above? 
    # graphics = {
    #   enable32Bit = true;
    #   enable = true;

    #   extraPackages = with pkgs; [ vaapiVdpau libvdpau-va-gl ];

    #   extraPackages32 = with pkgs.pkgsi686Linux; [ vaapiVdpau libvdpau-va-gl ];
    # };

    nvidia = {
      modesetting.enable = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable; # .beta
      nvidiaSettings = true; # Nvidia settings menu. Run: nvidia-settings
      powerManagement.enable = false; # experimental
      powerManagement.finegrained = false; # experimental, might be bad
      open = false; # use NVidia open source drivers (still alpha)

      # make sure correct Bus ID for system! Can run: lspci
      prime = {
        # sync.enable = true; # might be good when plugged into external monitor? 
        nvidiaBusId = "PCI:1:0:0";
        intelBusId = "PCI:0:2:0";
      };
    };
  };

  xdg = {
    autostart.enable = true;
    portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };
  };

  # Security 
  security = {
    pam.services.swaylock = {
      text = ''
        auth include login
      '';
    };
    # pam.services.hyprlock = { }; # enable hyprlock
  };

  # Services 
  services = {
    xserver = {
      enable = true;
      xkb.layout = "us";
      xkb.variant = "";
      excludePackages = [ pkgs.xterm ];
      videoDrivers = [ "nvidia" ];
      displayManager.gdm = {
        enable = true;
        wayland = true;
      };
    };
    libinput.enable = true;
    dbus.enable = true;
    gvfs.enable = true;
    gnome = { gnome-keyring.enable = true; };
  };

  # Define a user account.
  users.users.${userSettings.username} = {
    isNormalUser = true;
    description = userSettings.name;
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [ ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  fonts.packages = with pkgs;
    [
      (nerdfonts.override {
        fonts = [ "FiraCode" "DroidSansMono" "JetBrainsMono" ];
      })
    ];

  # enabling flakes 
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    home-manager

    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    lf
    wget
    curl
    helix
    git

    (waybar.overrideAttrs (oldAttrs: {
      mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
    }))

    mako
    libnotify # for mako

    # hyprlock
    # hypridle

    swww
    kitty
    wofi
    firefox

    polkit_gnome
    libva-utils

    swaynotificationcenter
    wlr-randr
    wl-clipboard
    swayidle
    swaylock
    xdg-desktop-portal-hyprland
    xdg-utils
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    qt5.qtwayland
    qt6.qmake
    pciutils
    lshw

    pavucontrol # for managing audio
    pamixer # for changing audio volume

    brightnessctl # for changing keyboard brightness

    networkmanagerapplet
    blueman

    grim
    slurp

    fastfetch

    discord
    spotify
    btop
    nvtopPackages.full

    python3

    wireplumber
    pipewire
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  services.pcscd.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
