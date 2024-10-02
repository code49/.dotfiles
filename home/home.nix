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
      ls = "ls -a"; # shows hidden files :)
      rm = "rm -i"; # adds reminder before rm'ing
      ssh = "kitty ssh"; # allows kitty-stuff to work over ssh
      rb = "printf 'manually-requested REBOOT in 3 seconds; \`ctrl + c\` or otherwise destroy this terminal window to cancel this operation.\n'; sleep 3; reboot"; # quickly reboot the system
      sd = "printf 'manually-requested SHUTDOWN in 3 seconds; \`ctrl + c\` or otherwise destroy this terminal window to cancel this operation.\n'; sleep 3; shutdown now"; # add delay for shutdown-ing
      cls = "clear"; # windows-style clear terminal command
      ncode = "code .; exit"; # opens current directory in VS code, then exits

      # firefox window shortcuts
      ffc = "nohup /run/current-system/sw/bin/firefox -p dchan2-cmu &! ; exit";
      ffcmu = "nohup /run/current-system/sw/bin/firefox -p dchan2-cmu &! ; exit";
      ffp = "nohup /run/current-system/sw/bin/firefox -p dchan-personal 'https://davidlechan.dev' 'https://google.com' &! ; exit";
      ffpri = "nohup /run/current-system/sw/bin/firefox -private-window &! ; exit";

      # firefox window + tab shortcuts; work-y stuff
      ffcan = "nohup /run/current-system/sw/bin/firefox -p dchan2-cmu -new-window 'https://canvas.cmu.edu' &! ; exit";
      ffgs = "nohup /run/current-system/sw/bin/firefox -p dchan2-cmu -new-window 'https://gradescope.com' &! ; exit";
      ffpz = "nohup /run/current-system/sw/bin/firefox -p dchan2-cmu -new-window 'https://piazza.com/class/lzszsxremeq3r3' &! ; exit"; # default to 18-100 F24
      ffciab = "nohup /run/current-system/sw/bin/firefox -p dchan2-cmu -new-window 'https://docs.google.com/spreadsheets/d/1TGXTU7LcW0SnHU4GyXS6LyfdWWZ7TZOOrYGZ6hPWRoQ/edit?gid=1723876336#gid=1723876336' &! ; exit";

      ffdrive = "nohup /run/current-system/sw/bin/firefox -p dchan-personal -new-window 'https://drive.google.com' &! ; exit";
      ffcal = "nohup /run/current-system/sw/bin/firefox -p dchan-personal -new-window 'https://calendar.google.com' &! ; exit";

      ffgmail = "nohup /run/current-system/sw/bin/firefox -p dchan-personal -new-window 'https://mail.google.com/mail/u/0/#inbox' &! ; exit";
      ffcmail = "nohup /run/current-system/sw/bin/firefox -p dchan2-cmu -new-window 'https://mail.google.com/mail/u/0/#inbox' &! ; exit";

      ffno="nohup /run/current-system/sw/bin/firefox -p dchan-personal -new-window 'https://www.notion.so/davidlechan/d03cd6231ead496e808bdf0fe03f8566' &! ; exit";

      # firefox window + tab shortcuts; message-y stuff
      ffmsg = "nohup /run/current-system/sw/bin/firefox -p dchan-personal -new-window 'https://messages.google.com/web/conversations' &! ; exit";
      ffig = "nohup /run/current-system/sw/bin/firefox -p dchan-personal -new-window 'https://instagram.com/direct/inbox/' &! ; exit";
      ffwa = "nohup /run/current-system/sw/bin/firefox -p dchan-personal -new-window 'https://web.whatsapp.com' &! ; exit";
      fftele = "nohup /run/current-system/sw/bin/firefox -p dchan-personal -new-window 'https://web.telegram.org' &! ; exit";
      ffdisc = "nohup /run/current-system/sw/bin/firefox -p dchan-personal -new-window 'https://discord.com/channels/@me' &! ; exit";

      # firefox window + tab shortcuts; slack (because slack is *exceptionally* annoying)
      ffcia = "nohup /run/current-system/sw/bin/firefox -p dchan2-cmu -new-window 'https://app.slack.com/client/T15JH0RJ8' &! ; exit";
      ff100 = "nohup /run/current-system/sw/bin/firefox -p dchan2-cmu -new-window 'https://app.slack.com/client/T0785RZ6M5L' &! ; exit";
      ffio = "nohup /run/current-system/sw/bin/firefox -p dchan2-cmu -new-window 'https://app.slack.com/client/T070WJHP2E4' &! ; exit";

      # firefox window + tab shortcuts; other stuff
      ffsptfy = "nohup /run/current-system/sw/bin/firefox -p dchan-personal -new-window 'https://open.spotify.com' &! ; exit";
      ffyou = "nohup /run/current-system/sw/bin/firefox -p dchan-personal -new-window 'https://youtube.com' &! ; exit";
      fftv = "nohup /run/current-system/sw/bin/firefox -p dchan-personal -new-window 'https://tv.youtube.com' &! ; exit";

      ffph = "nohup /run/current-system/sw/bin/firefox -p dchan-personal -new-window 'https://photos.google.com' &! ; exit";

      ffsfg = "nohup /run/current-system/sw/bin/firefox -p dchan-personal -new-window 'https://www.espn.com/mlb/team/_/name/sf/san-francisco-giants' &! ; exit";
      fflbs = "nohup /run/current-system/sw/bin/firefox -p dchan-personal 'https://tv.youtube.com' 'https://livebaseballscorecards.com' &! ; exit";

      ffnas = "nohup /run/current-system/sw/bin/firefox -p dchan-personal -new-window 'https://chandisk.us6.quickconnect.to/' &! ; exit";

      ffgem = "nohup /run/current-system/sw/bin/firefox -p dchan-personal -new-window 'https://gemini.google.com/app' &! ; exit";
      ffnews = "nohup /run/current-system/sw/bin/firefox -p dchan-personal -new-window 'https://news.google.com' &! ; exit";

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
      safe.directory = [
      ];
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
