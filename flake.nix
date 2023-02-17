{
  description = "Generate docker image for my personal frp service";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs.follows = "nixpkgs";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.treefmt-nix.flakeModule
      ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      flake = {
        lib.mkImage = import ./mkImage.nix;
      };
      perSystem = {
        config,
        pkgs,
        ...
      }: {
        treefmt.config = {
          projectRootFile = "flake.nix";
          programs.alejandra.enable = true;
        };
        devShells.deafult = pkgs.mkShell {
          nativeBuildInputs = [config.treefmt.build.wrapper];
        };
        packages = let
          frpsConfig = import ./config.nix;
        in rec {
          frpsImage = pkgs.callPackage ./mkImage.nix {inherit frpsConfig;};
          default = frpsImage;
        };
      };
    };
}
