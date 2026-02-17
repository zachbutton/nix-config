
{ config, lib, pkgs, ... }:

{
	imports = [ 
		./niri.nix
		./neovim.nix
		./ironbar.nix
		./swaync.nix
	];

	home.file.".docker/cli-plugins/docker-buildx".source = "${pkgs.docker-buildx}/bin/docker-buildx";
}
