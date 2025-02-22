{self, ...}: {
  perSystem = {
    pkgs,
    lib,
    ...
  }: {
    packages = {
      # credit to https://github.com/pedorich-n/MinecraftModpack
      mrpack = pkgs.stdenvNoCC.mkDerivation (finalAttrs: let
        inherit (lib) importTOML;
        inherit (finalAttrs.passthru.manifest) version;

        pname = lib.strings.sanitizeDerivationName finalAttrs.passthru.manifest.name;
        finalName = "${pname}-${version}.mrpack";
        src = "${self}/src";
      in {
        inherit src version pname;
        nativeBuildInputs = [pkgs.packwiz];

        buildPhase = ''
          runHook preBuild
          export HOME=$TMPDIR
          result="$out/${finalName}"
          mkdir -p $out
          packwiz mr export --output "$result"
          runHook postBuild
        '';
        dontInstall = true;

        passthru.manifest = importTOML "${src}/pack.toml";
      });
    };
  };
}
