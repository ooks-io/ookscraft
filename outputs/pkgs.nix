{self, ...}: {
  perSystem = {
    pkgs,
    lib,
    ...
  }: let
    inherit (lib) importTOML;
    hash = "sha256-iJq4o3bqi9UETgmSFaHZVcqj6xmEWVQFpzK+ZJcwntM=";
  in {
    packages = {
      # credit to https://github.com/pedorich-n/MinecraftModpack
      mrpack = pkgs.stdenvNoCC.mkDerivation (finalAttrs: let
        inherit (finalAttrs.passthru.manifest) version;
        pname = lib.strings.sanitizeDerivationName finalAttrs.passthru.manifest.name;
        finalName = "${pname}-${version}.mrpack";
      in {
        outputHashMode = "recursive";
        outputHashAlgo = "sha256";
        outputHash = hash;
        inherit pname version;
        src = "${self}/src";
        dontFixup = true;

        nativeBuildInputs = [pkgs.packwiz pkgs.strip-nondeterminism];

        buildPhase = ''
          runHook preBuild
          export HOME=$TMPDIR

          mkdir -p $out

          packwiz modrinth export --output "$out/${finalName}"
          strip-nondeterminism --type zip "$out/${finalName}"

          runHook postBuild
        '';

        passthru.manifest = importTOML ../src/pack.toml;
      });
    };
  };
}
