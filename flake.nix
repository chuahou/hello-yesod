{
  inputs = {
    flake-compat = { url = "github:edolstra/flake-compat"; flake = false; };
    haskellNix.url = "github:input-output-hk/haskell.nix";
    nixpkgs.follows = "haskellNix/nixpkgs-unstable";
  };

  # haskell.nix binary cache
  nixConfig = {
    extra-substituters = "https://cache.iog.io";
    extra-trusted-public-keys = "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ=";
  };

  outputs = inputs@{ self, nixpkgs, haskellNix, ... }:
  let
    system = "x86_64-linux";
    compiler-nix-name = "ghc902";
    compiler = pkgs.haskell-nix.compiler.${compiler-nix-name};
    overlays = [
      haskellNix.overlay
      (self: super: {
        hello-yesod = self.haskell-nix.stackProject' { src = ./.; };
      })
    ];
    pkgs = import nixpkgs {
      inherit system overlays;
      inherit (haskellNix) config;
    };
    flake = pkgs.hello-yesod.flake {};

  in flake // {
    inherit pkgs;
    defaultPackage.${system} = flake.packages."hello-yesod:exe:hello-yesod" // {
      meta.mainProgram = "hello-yesod"; # Necessary for nix-run to work.
    };
    devShell.${system} = self.devShells.${system}.stack;
    devShells.${system} = {
      # For stack's use when building.
      stack = pkgs.mkShell {
        buildInputs = with pkgs; [ compiler git nix stack zlib ];
        NIX_PATH = "nixpkgs=${pkgs.path}";
        LC_ALL = "C.UTF-8";
      };
      # Development shell for use with `nix develop`.
      dev = pkgs.hello-yesod.shellFor {
        tools = { cabal = {}; haskell-language-server = {}; };
        buildInputs = with pkgs; [ hpack stack ];
        exactDeps = true;
      };
    };
  };
}
