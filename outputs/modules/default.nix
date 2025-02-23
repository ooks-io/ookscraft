{
  flake.nixosModules = {
    ookscraft-server = import ./ookscraft-server.nix;
  };
}
