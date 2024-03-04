{
  description = "Personal NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
  };

  outputs = { self, nixpkgs, ...}:
    {
    nixosConfigurations = {
     jubjub = nixpkgs.lib.nixosSystem {
        modules = [
          ./configuration.nix
        ];
    };
      };
    };
}
