{ pkgs, lib, ... }:

{
  imports = [
    ./hardware.nix
  ];

  networking.hostName = "zach-parallels";
  networking.interfaces.enp0s5.mtu = 1400;

  hardware.graphics.enable = true;

  # parallels guest tools set this to false (they're wrong), force it
  services.timesyncd.enable = lib.mkForce true;

  security.pki.certificateFiles = lib.optional (builtins.pathExists ./rootCA.pem) ./rootCA.pem;

  services.zram-generator.enable = true;
  services.zram-generator.settings.zram0 = {
    zram-size = "ram * 3 / 2";
    zram-resident-limit = "ram / 2";
    compression-algorithm = "zstd";
  };

  systemd.tmpfiles.rules = [
    "d /mnt/psf 0755 root root -"
    "d /mnt/psf/RosettaLinux 0755 root root -"
  ];

  systemd.services.prltoolsd = {
    after = [ "systemd-tmpfiles-setup.service" ];
    wants = [ "systemd-tmpfiles-setup.service" ];
  };

  # Exists as a bad workaround to install zoom. The zoom-us package doesn't play nice with Rosetta
  services.flatpak.enable = true;

  # prevents binfmt from starting before rosetta is ready
  # Note to future self: Check if /proc/sys/fs/binfmt_misc/rosetta exists,
  # if not then `sudo systemctl restart systemd-binfmt`
  systemd.services.systemd-binfmt = {
    after = [ "prltoolsd.service" ];
    requires = [ "prltoolsd.service" ];
    serviceConfig = {
      ExecStartPre = "${pkgs.bash}/bin/bash -c 'until [ -f /mnt/psf/RosettaLinux/rosetta ]; do sleep 1; done'";
      TimeoutStartSec = 30;
    };
  };

  # Register Rosetta binfmt after prltoolsd mounts it
  boot.binfmt.registrations."rosetta" = {
    interpreter = "/mnt/psf/RosettaLinux/rosetta";
    magicOrExtension = ''\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x3e\x00'';
    mask = ''\xff\xff\xff\xff\xff\xfe\xfe\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff'';
    fixBinary = true;
    wrapInterpreterInShell = false;
    openBinary = true;
    matchCredentials = true;
  };

  # workarounds to make arm64 citrix_workspace install
  nixpkgs.overlays = [
    (final: prev: {
      citrix_workspace = prev.citrix_workspace.overrideAttrs (old: {
        src = prev.requireFile {
          name = "linuxarm64-25.08.10.111.tar.gz";
          url = "https://www.citrix.com/downloads/workspace-app/linux/workspace-app-for-linux-latest.html";
          sha256 = "0swy016ai1jdyrqm11y6qc5yd3wd4snypvqhgbmj39j951w07ip6";
        };
        # Replace all references to linuxx64 with linuxarm64
        postUnpack = (old.postUnpack or "") + ''
          if [ -d linuxarm64 ] && [ ! -d linuxx64 ]; then
            ln -s linuxarm64 linuxx64
          fi
        '';
        # these don't build easily, but are only needed for self-service ui
        # can run wfica directly without them
        autoPatchelfIgnoreMissingDeps = [
          "libwebkit2gtk-4.0.so.37"
          "libjavascriptcoregtk-4.0.so.18"
        ];
      });
    })
  ];

  nixpkgs.config.allowUnsupportedSystem = true;
  nixpkgs.config.allowUnfree = true;

  nix.settings.extra-platforms = [ "x86_64-linux" ];

  environment.variables = {
    DOCKER_DEFAULT_PLATFORM = "linux/amd64";
  };

  environment.sessionVariables = {
    GSK_RENDERER = "opengl";
  };

  nixpkgs.config.permittedInsecurePackages = [
    "libsoup-2.74.3"
  ];

  systemd.user.services.citrix-ica-watcher = {
    description = "Watch for .ica files and open with Citrix";
    wantedBy = [ "default.target" ];
    path = [ pkgs.inotify-tools ];
    environment = {
      DISPLAY = ":0";
    };
    serviceConfig = {
      ExecStart = pkgs.writeShellScript "citrix-ica-watcher" ''
        DIR="$HOME/Downloads"
        mkdir -p "$DIR"

        # Watch for new ones
        inotifywait -m -e close_write -e moved_to --format '%f' "$DIR" | while read -r f; do
          if [[ "$f" == *.ica ]]; then
            file="$DIR/$f"
            sleep 0.5
            /run/current-system/sw/bin/wfica "$file"
          fi
        done
      '';
      Restart = "on-failure";
      RestartSec = 5;
      StandardOutput = "journal";
      StandardError = "journal";
      PassEnvironment = "DISPLAY WAYLAND_DISPLAY XAUTHORITY";
    };
  };

  services.pcscd.enable = true;
  environment.systemPackages = with pkgs; [
    ddev
    mkcert
    openssl
    ccid
    opensc
    pcsc-tools
    nss.tools
    citrix_workspace
    inotify-tools
  ];
}
