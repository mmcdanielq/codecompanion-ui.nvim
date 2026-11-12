{
  description = "codecompanion-ui devShell, formatting, linting, and test checks";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Test-only runtime dependencies
    codecompanion-nvim = {
      url = "github:olimorris/codecompanion.nvim";
      flake = false;
    };
    plenary-nvim = {
      url = "github:nvim-lua/plenary.nvim";
      flake = false;
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      treefmt-nix,
      codecompanion-nvim,
      plenary-nvim,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        treefmt-eval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
        treefmt-wrapper = treefmt-eval.config.build.wrapper;
      in
      {
        formatter = treefmt-wrapper;
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            just
            lua51Packages.busted
            lua51Packages.nlua
            neovim
            selene
            stylua
            treefmt-wrapper
          ];
          # Consumed by tests/init.lua to put test-only deps on the runtimepath
          CODECOMPANION_NVIM_PATH = codecompanion-nvim;
          PLENARY_NVIM_PATH = plenary-nvim;
        };
        checks = {
          formatting = treefmt-eval.config.build.check self;
          selene = pkgs.callPackage (import ./checks/selene.nix) { inherit self pkgs; };
          tests = pkgs.callPackage (import ./checks/tests.nix) {
            inherit
              self
              pkgs
              codecompanion-nvim
              plenary-nvim
              ;
          };
        };
      }
    );
}
