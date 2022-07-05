{
  extras = hackage:
    { packages = { hello-yesod = ./hello-yesod.nix; }; };
  resolver = "lts-19.14";
  modules = [
    ({ lib, ... }:
      { packages = {}; })
    { packages = {}; }
    ({ lib, ... }:
      { planned = lib.mkOverride 900 true; })
    ];
  }