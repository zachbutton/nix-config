{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    stylix.url = "github:nix-community/stylix";
    nixvim.url = "github:nix-community/nixvim";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      stylix,
      nixpkgs,
      home-manager,
      nixvim,
      ...
    }:
    let
      hmModule = {
        imports = [
          home-manager.nixosModules.home-manager
        ];
        home-manager.sharedModules = [
          nixvim.homeModules.nixvim
        ];
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.zach = import ./home;
      };
    in
    {
      nixosConfigurations.zach-xps15 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          hmModule
          stylix.nixosModules.stylix
          ./stylix.nix
          ./common
          ./hosts/zach-xps15
          ./modules/desktop.nix
          ./modules/docker.nix
        ];
      };

      nixosConfigurations.zach-parallels = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          hmModule
          stylix.nixosModules.stylix
          ./stylix.nix
          ./common
          ./hosts/zach-parallels
          ./modules/desktop.nix
          ./modules/docker.nix
        ];
      };
    };
}
