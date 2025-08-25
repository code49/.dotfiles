{
  description = "flake";

  inputs = {
    nixpkgs = { url = "nixpkgs/nixos-unstable"; };
    home-manager = {
      url = "github:nix-community/home-manager/master";

      # ensure nixpkgs version is consistent
      inputs = { nixpkgs.follows = "nixpkgs"; };
    };

    # git version of hyprland
    # hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";

    # hyprland-plugins = {
    #   url = "github:hyprwm/hyprland-plugins";
    #   inputs.hyprland.follows = "hyprland";
    # };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      lib = nixpkgs.lib;
      pkgs = nixpkgs.legacyPackages.${system};

      # ---------- SYSTEM SETTINGS ---------- # 
      system = "x86_64-linux";
      systemSettings = { timezone = "America/New_York"; };

      # ----------- USER SETTINGS ----------- #
      userSettings = {
        username = "dchan";
        name = "David Chan";

      };

      # ----------- THEME SETTINGS ---------- #
      theme = {
        # grayscale going from dark to light - "dark mode"
        base00 = "1d1f21";
        base01 = "282a2e";
        base02 = "373b41";
        base03 = "969896";
        base04 = "b4b7b4";
        base05 = "c5c8c6";
        base06 = "e0e0e0";
        base07 = "ffffff";

        base00_rgb = "29, 31, 33";
        base01_rgb = "40, 42, 46";
        base02_rgb = "55, 59, 65";
        base03_rgb = "150, 152, 150";
        base04_rgb = "180, 183, 180";
        base05_rgb = "197, 200, 198";
        base06_rgb = "224, 224, 224";
        base07_rgb = "255, 255, 255";

        # accent colors
        base08 = "ffadad"; # light red
        base09 = "f8cfd2"; # light-light red ; tertiary (background) accent
        base0A = "fdffb6"; # yellow
        base0B = "daa9ff"; # magenta ; secondary accent
        base0C = "caffbf"; # green
        base0D = "bdb2ff"; # purple ; primary accent "daa9ff";
        base0E = "9bf6ff"; # light blue
        base0F = "a0c4ff"; # blue

        base08_rgb = "255, 173, 173";
        base09_rgb = "248, 207, 210";
        base0A_rgb = "253, 255, 182";
        base0B_rgb = "218, 169, 255";
        base0C_rgb = "202, 255, 191";
        base0D_rgb = "189, 178, 255"; 
        base0E_rgb = "155, 246, 255";
        base0F_rgb = "160, 196, 255";

        # accent colors alts for kitty - accents, but desaturated 50%
        base08alt = "eac1c1";
        base09alt = "eed9db";
        base0Aalt = "ecedc8";
        base0Balt = "d7bee9"; 
        base0Calt = "d4efcf";
        base0Dalt = "cbc5ec"; 
        base0Ealt = "b4e1e6";
        base0Falt = "b8cae7";

        base08alt_rgb = "234, 193, 193";
        base09alt_rgb = "238, 217, 219";
        base0Aalt_rgb = "236, 237, 200";
        base0Balt_rgb = "215, 190, 233"; 
        base0Calt_rgb = "212, 239, 207";
        base0Dalt_rgb = "203, 197, 236"; 
        base0Ealt_rgb = "180, 225, 230";
        base0Falt_rgb = "184, 202, 231";

        # base0Dalt gradient (main accent)
        base0Dalt2 = "c4bcf5";
        base0Dalt3 = "cbc5ec";
        base0Dalt4 = "d2cfe2";

        base0Dalt2_rgb = "196, 188, 245";
        base0Dalt3_rgb = "203, 197, 236";
        base0Dalt4_rgb = "210, 207, 226";

        # main background options 
        dark_background_primary = "343061";
        dark_background_primary_rgb = "52, 48, 97";
      };

    in {
      nixosConfigurations = {
        dchan-laptop = lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/dchan-laptop/configuration.nix
            ./configuration.nix
            ./hosts/dchan-laptop/hardware-configuration.nix
            inputs.home-manager.nixosModules.default
          ];
          specialArgs = {
            inherit inputs;
            inherit systemSettings;
            inherit userSettings;
            inherit theme;
          };
        };
      };
    };
}
