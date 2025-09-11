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
  xdg.configFile."electron-flags.conf".source = ./electron-flags.conf;
  xdg.configFile."electron32-flags.conf".source = ./electron-flags.conf;
  xdg.configFile."code-flags.conf".source = ./electron-flags.conf;

  home.pointerCursor = {
    enable = true;
    package = pkgs.google-cursor;
    name = "GoogleDot-Violet";
    size = 12;
  };
  home.file.".icons" = {
    source = ../icons;
    recursive = true;
  };

  home.packages = with pkgs; [
    cargo
    zoxide
    fzf
    conda
    zip
    unzip
    zoom-us

    google-cursor

    # google-chrome
    # google-cursor
    # obsidian
    # texliveFull
    # cargo
    # julia
    # zoxide
    # fzf
    # slack
    # conda
    # zip
    # zoom-us
    # unzip
    # gimp
    # viu
    # vlc
    # strawberry
    # meshlab
    # inkscape
    # yt-dlp
    # gnupg
    # pinentry
    # gemini-cli
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
    # DEFAULT_BROWSER = "${pkgs.google-chrome}/bin/google-chrome-stable";
  };

  dconf.settings = {
    # configuring dark mode
    "org/gnome/desktop/background" = {
      picture-uri-dark =
        "file://${pkgs.nixos-artwork.wallpapers.nineish-dark-gray.src}";
    };
    "org/gnome/desktop/interface" = { color-scheme = "prefer-dark"; };

  };

  gtk = {
    enable = true;

    cursorTheme.name = "GoogleDot-Violet";
    cursorTheme.size = 12;

    # configuring dark mode
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
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
      ls = "ls -a";
      ".." = "cd ..";
      "gitac" = "git status; git add -A; git commit -m";
      "ssh" = "kitten ssh";
      "b" = "btop";
      "n" = "nvtop";
      "ns" = "nix-shell";
      "nix-reb" = "~/.dotfiles/scripts/nix-rebuild-nice.sh";
    };

    envExtra = ''
      eval "$(zoxide init --cmd cd zsh)"

      ff() {
   
      	# run script
         	~/.dotfiles/scripts/firefox_shortcuts.sh "$1"
      
      	# case on script exit code to decide whether to kill terminal
      	if [ $? -eq 0 ]; then
      		exit
      	else 
      		echo "firefox shortcut script failed."
      	fi
      		
      }
      
    '';
  };

  programs.git = {
    enable = true;
    userName = "David Chan";
    userEmail = "davidlechan@gmail.com";
    extraConfig = {
      init.defaultBranch = "master";
      # safe.directory = [
      #  "/home/theo/Documents/Obsidian_Vault"
      #  "/home/theo/Documents/HMC/HMC_MATH019_Answer_Keys"
      #  "/home/theo/Documents/HMC/HMC_Semester_2"
      #  "/home/theo/Documents/HMC/HMC_Semester_3"
      #  "/home/theo/Documents/HMC/HMC_Semester_4"
      #  "/home/theo/Documents/Resume"
      #  "/home/theo/Documents/CalTech/julia_retrieval/Retrieval"
      # ];
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
