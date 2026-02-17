{ pkgs, stylix, ... }:

{
  imports = [ ./config ];

  home.username = "zach";
  home.homeDirectory = "/home/zach";
  home.stateVersion = "25.11";

  nixpkgs.config.allowUnfree = true;

  services.swaync.enable = true;
  stylix.targets.swaync.enable = false; # stylix integration is bad, manual integration in config

  programs.foot.enable = true;
  programs.kakoune.enable = true;
  programs.vivaldi = {
    enable = true;
    package = pkgs.vivaldi.override {
      proprietaryCodecs = true;
      enableWidevine = true;
      # Spotify fix (they do dumb things with user agent)
      # commandLineArgs = "--user-agent=Mozilla/5.0_AppleWebKit/537.36_Chrome/142.0.0.0_Safari/537.36 --disable-features=UserAgentClientHint";
    };
  };
  programs.git = {
    enable = true;
    userName = "Zach Button";
    userEmail = "zachrey.button@gmail.com";
  };
  programs.fuzzel.enable = true;
  programs.yazi.enable = true;
  programs.jjui = {
    enable = true;
    settings.ssh.hijack_askpass = true;
  };
  programs.opencode.enable = true;
  programs.claude-code.enable = true;

  programs.btop = {
    enable = true;
    settings = {
      color_theme = "TTY";
      vim_keys = true;
      proc_sorting = "memory";
      proc_tree = true;
      update_ms = 1000;
    };
  };
  stylix.targets.btop.enable = false; # btop's "TTY" them actually matches stylix's them more nicely

  # systemd.user.services.user-nssdb = {
  #   description = "Register OpenSC module in NSS database";
  #   wantedBy = [ "default.target" ];
  #   after = [ "graphical-session.target" ];

  #   path = with pkgs; [
  #     nss.tools
  #     opensc
  #   ];

  #   serviceConfig = {
  #     Type = "oneshot";
  #     RemainAfterExit = true;
  #   };

  #   script = ''
  #     mkdir -p "$HOME/.pki/nssdb"
  #     certutil -d sql:"$HOME/.pki/nssdb" -N --empty-password 2>/dev/null || true

  #     if ! modutil -dbdir sql:"$HOME/.pki/nssdb" -list | grep -q "OpenSC"; then
  #       modutil -dbdir sql:"$HOME/.pki/nssdb" -add "OpenSC" \
  #         -libfile /run/current-system/sw/lib/opensc-pkcs11.so -force
  #     fi
  #   '';
  # };

  home.packages = with pkgs; [
    jujutsu
    ironbar
    ghostty
    alacritty
    fzf
    zellij
    delta
    meld
    xwayland
    keymapp
    ripgrep
    ast-grep
    gnupg
    silver-searcher
    postman
    logseq
    swaybg
    nodejs
    calc
    wl-clipboard
    inotify-tools
    unzip
    tree
    pciutils
    go
    python3
    gnumake
    cargo
    curl
    gcc
    playerctl
    p7zip
    lsof
    jq
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  home.shellAliases = {
    rustdesk = "flatpak run --socket=x11 --nosocket=wayland com.rustdesk.RustDesk";
  };
}
