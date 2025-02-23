{
  flake.nixosModules = {
    ookscraft-server = import ./ookscraft-server.nix;
    ookscraft-proxy = import ./ookscraft-proxy.nix;
  };
}
