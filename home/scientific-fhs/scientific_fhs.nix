{ inputs, pkgs, ... }: {

  imports = [ inputs.scientific-fhs.nixosModules.default ];

  programs.scientific-fhs = {
    enable = true;
    enableNVIDIA = true;
  };
}
