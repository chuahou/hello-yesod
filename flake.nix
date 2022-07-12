{
  inputs = {
    flake-compat = { url = "github:edolstra/flake-compat"; flake = false; };
    flake-utils.url = "github:numtide/flake-utils";
    haskellNix.url = "github:input-output-hk/haskell.nix";
    nixpkgs.follows = "haskellNix/nixpkgs-unstable";
  };

  # haskell.nix binary cache
  nixConfig = {
    extra-substituters = "https://cache.iog.io";
    extra-trusted-public-keys = "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ=";
  };

  outputs = inputs@{ self, nixpkgs, flake-utils, haskellNix, ... }:
  flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
  let
    compiler-version = "902";
    compiler-nix-name = "ghc${compiler-version}";
    compiler = pkgs.haskell-nix.compiler.${compiler-nix-name};
    overlays = [
      haskellNix.overlay
      (self: super: {
        hello-yesod = self.haskell-nix.stackProject' {
          src = self.haskell-nix.haskellLib.cleanSourceWith {
            name = "hello-yesod-source";
            src = ./.;
          };
          materialized = ./materialized/hello-yesod;
        };
      })
    ];
    pkgs = import nixpkgs {
      inherit system overlays;
      inherit (haskellNix) config;
    };
    flake = pkgs.hello-yesod.flake {};

  in flake // {
    inherit pkgs;
    defaultPackage = flake.packages."hello-yesod:exe:hello-yesod";
    devShell = self.devShells.${system}.stack;
    devShells = {
      # For stack's use when building.
      stack = pkgs.mkShell {
        buildInputs = with pkgs; [ compiler git nix stack zlib ];
        NIX_PATH = "nixpkgs=${pkgs.path}";
        LC_ALL = "C.UTF-8";
      };
      # Development shell for use with `nix develop`.
      dev = pkgs.hello-yesod.shellFor {
        tools.hoogle = {
          version = "5.0.18.3";
          index-state = "2022-07-04T00:00:00Z";
          materialized = ./materialized/hoogle;
        };
        nativeBuildInputs = with pkgs; [
          cabal-install
          (haskell-language-server.override {
            dynamic = true; # Required for Template Haskell. See HLS#2665.
            supportedGhcVersions = [ compiler-version ];
          })
          hpack
        ];
        exactDeps = true;
      };
    };
  });
}
