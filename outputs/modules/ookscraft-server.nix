{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib) mkIf importTOML replaceStrings mkEnableOption;
  inherit (builtins) attrValues;
  src = ../../src;

  # modified fetchPackwizModpack to use local modpack instead of url
  # credit to https://github.com/sunziping2016/flakes
  localPackwizModpack = {src, ...} @ args:
    (pkgs.fetchPackwizModpack ({url = "";} // args)).overrideAttrs (old: {
      buildInputs = attrValues {inherit (pkgs) jq jre_headless moreutils;};
      buildPhase = ''
        java -jar "$packwizInstallerBootstrap" \
          --bootstrap-main-jar "$packwizInstaller" \
          --bootstrap-no-update \
          --no-gui \
          --side "server" \
          "${src}/pack.toml"
      '';
      passthru =
        old.passthru
        // {
          manifest = importTOML "${src}/pack.toml";
        };
    });
  modpack = localPackwizModpack {
    inherit src;
    packHash = "sha256-IK8Z8W4RRB/fwEa0xg2tRgpeq46ok73xYBgKEKp4hDg=";
  };

  mcVersion = modpack.manifest.versions.minecraft;
  loaderVersion = modpack.manifest.versions.fabric;
  serverVersion = replaceStrings ["."] ["_"] "fabric-${mcVersion}";

  cfg = config.services.ookscraft-server;
in {
  imports = [
    inputs.nix-minecraft.nixosModules.minecraft-servers
  ];
  options.services.ookscraft-server = {
    enable = mkEnableOption "Enable ookscraft minecraft server module";
  };
  config = mkIf cfg.enable {
    nixpkgs.overlays = [inputs.nix-minecraft.overlay];
    services.minecraft-servers = {
      enable = true;
      eula = true;
      servers.ookscraft = {
        enable = true;
        openFirewall = true;
        autoStart = true;
        whitelist = {
          ooksmoney = "ca8dae88-9b2c-4c17-9604-971219b70b9d";
        };
        operators = {
          ooksmoney = {
            uuid = "ca8dae88-9b2c-4c17-9604-971219b70b9d";
          };
        };
        package = pkgs.fabricServers.${serverVersion}.override {inherit loaderVersion;};
        symlinks = {
          mods = "${modpack}/mods";
        };
        serverProperties = {
          whitelist = true;
          difficulty = "hard";
          gamemode = "survival";

          view-distance = 16;
          simulation-distance = 8;
          allow-flight = true;
        };
      };
    };
  };
}
