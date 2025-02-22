{
  perSystem = {pkgs, ...}: {
    devShells.default = pkgs.mkShellNoCC {
      name = "ookscraft devshell";
      packages = builtins.attrValues {
        inherit (pkgs) packwiz;
      };
    };
  };
}
