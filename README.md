## hello-yesod

Figuring out Yesod with both Stack and Cabal, supported by haskell.nix.

Goals include:
- Build with Stack with nix support in `nix develop .#stack`.
- Use yesod-bin with `yesod devel` etc in `nix develop .#stack`.
- Build with Cabal with `exactDeps` in `nix develop .#dev`.
- Build with Nix for NixOS deployment.
