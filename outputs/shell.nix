{
  perSystem = {pkgs, ...}: {
    devShells.default = pkgs.mkShellNoCC {
      name = "ookscraft devshell";
      packages = builtins.attrValues {
        inherit (pkgs) packwiz;
      };
      shellHook = ''
        echo "Entered ookscraft devshell"
        alias add="packwiz mr add"
      '';
    };
  };
}
