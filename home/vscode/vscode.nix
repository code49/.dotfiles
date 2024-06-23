{ config, pkgs, theme, ... }: {
  programs.vscode = {
    enable = true;

    package = pkgs.vscode;
  };
}
