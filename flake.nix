{
  description = "Description for the project";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default-linux";
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = import inputs.systems;
      imports = [./outputs];
      _module.args.pkgs = import inputs.nixpkgs {
        overlays = [
          inputs.nix-minecraft.overlay
        ];
      };
    };
}
