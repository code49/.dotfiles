{ inputs, config, pkgs, lib, userSettings, ... }:

{
  imports = [
    ./helix/helix.nix
    ./starship/starship.nix
    ./kitty/kitty.nix
    ./waybar/waybar.nix
    ./wofi/wofi.nix
    ./hyprland/hyprland.nix
    ./mako/mako.nix
    ./swaylock/swaylock.nix
    ./btop/btop.nix
    ./vscode/vscode.nix
    ./fastfetch/fastfetch.nix
  ];

  home.username = userSettings.username;
  home.homeDirectory = "/home/${userSettings.username}";

  home.stateVersion = "23.11"; # DONT CHANGE

  # set config for nix-shell and home-manager nixpkgs
  # nixpkgs.config.allowUnfree = true;
  nixpkgs.config = import ./nixpkgs-config.nix;
  xdg.configFile."nixpkgs/config.nix".source = ./nixpkgs-config.nix;

  home.packages = with pkgs; [
    texliveFull
    cargo
    # julia
    zoxide
    fzf
    conda
    zip
    unzip
  ];

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/theo/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
    DEFAULT_BROWSER = "${pkgs.firefox}/bin/firefox";
  };

  dconf.settings = {
    # configuring dark mode
    "org/gnome/desktop/background" = {
      picture-uri-dark =
        "file://${pkgs.nixos-artwork.wallpapers.nineish-dark-gray.src}";
    };
    "org/gnome/desktop/interface" = { color-scheme = "prefer-dark"; };
    "org/gnome/desktop/datetime" = { automatic-timezone = true; };
  };

  gtk = {
    enable = true;

    # configuring dark mode
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome.gnome-themes-extra;
    };
  };

  # apparently necessary for dark mode: 
  # systemd.user.sessionVariables = home.sessionVariables;

  qt = {
    enable = true;

    # configuring dark mode
    platformTheme.name = "adwaita";
    style.name = "adwaita-dark";
  };

  # configuring zsh
  programs.zsh = {
    enable = true;

    shellAliases = {

      # shell shortcuts
      ls = "ls -al"; # shows hidden files, list view :)
      rm = "rm -i"; # adds reminder before rm'ing
      ssh = "kitty ssh"; # allows kitty-stuff to work over ssh
      rb = ''
        printf 'manually-requested REBOOT in 1 second; `ctrl + c` or otherwise destroy this terminal window to cancel this operation.
        '; sleep 1; reboot''; # quickly reboot the system
      sd = ''
        printf 'manually-requested SHUTDOWN in 1 second; `ctrl + c` or otherwise destroy this terminal window to cancel this operation.
        '; sleep 1; shutdown now''; # add delay for shutdown-ing
      cls = "clear"; # windows-style clear terminal command
      ncode = "code .; exit"; # opens current directory in VS code, then exits

      # nix-y stuff
      hmreb = "home-manager switch --flake ~/.dotfiles"; # rebuild home manager
      nixreb =
        "~/.dotfiles/scripts/nix-rebuild-nice.sh"; # rebuild nix (with nice generation clearing)

      # matlab (because matlab is very funny apparently)
      mtlb = "./.dotfiles/scripts/matlab.sh &! ; exit";

      # firefox shortcuts (this is crazy scuffed)
      ff =
        "tmp_func() {./.dotfiles/scripts/firefox_shortcuts.sh $1; exit} ; tmp_func";

    };

    envExtra = ''
      eval "$(zoxide init --cmd cd zsh)"
    '';
  };

  programs.git = {
    enable = true;
    userName = "code49";
    userEmail = "davidlechan@gmail.com";
    extraConfig = {
      init.defaultBranch = "master";
      safe.directory = [ ];
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
