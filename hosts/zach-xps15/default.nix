{ pkgs, config, ... }:

let
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    		export __NV_PRIME_RENDER_OFFLOAD=1
    		export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    		export __GLX_VENDOR_LIBRARY_NAME=nvidia
    		export __VK_LAYER_NV_optimus=NVIDIA_only
    		exec "$@"
    	'';
in
{
  imports = [
    ./hardware.nix
  ];

  networking.hostName = "zach-xps15";

  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  programs.adb.enable = true;
  programs.steam.enable = true;
  services.fwupd.enable = true;

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics.enable = true;
  nixpkgs.config.cudaSupport = true;
  hardware.nvidia.open = false;
  # Optionally, you may need to select the appropriate driver version for your specific GPU.
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.production;

  # nvidia-drm.modeset=1 is required for some wayland compositors, e.g. sway
  hardware.nvidia.modesetting.enable = true;

  hardware.nvidia.prime = {
    offload.enable = true;
    #sync.enable = true;

    # Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA
    intelBusId = "PCI:0:2:0";

    # Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA
    nvidiaBusId = "PCI:1:0:0";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-gnome3;
    enableSSHSupport = true;
  };

  environment.systemPackages = with pkgs; [
    nvidia-offload
    gparted
    inotify-tools
    ngrok
    google-cloud-sdk
    flyctl
  ];
}
