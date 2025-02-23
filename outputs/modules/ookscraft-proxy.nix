{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf mkOption mkEnableOption mkMerge;
  inherit (lib.types) port str;
  cfg = config.services.ookscraft-proxy;
in {
  options.services.ookscraft-proxy = {
    minecraft = {
      enable = mkEnableOption "Enable ookscraft minecraft proxy";
      port = mkOption {
        type = port;
        default = 25565;
      };
      endpoint = mkOption {
        type = str;
        default = "";
      };
    };
    map = {
      enable = mkEnableOption "Enable proxy to server map";
      port = mkOption {
        type = port;
        default = 80;
      };
      endpoint = mkOption {
        type = str;
        default = "";
      };
    };
  };
  config = mkMerge [
    (mkIf cfg.minecraft.enable {
      services.haproxy = let
        port = toString cfg.minecraft.port;
      in {
        enable = true;
        config = ''
          global
          maxconn 32768
          log stdout format raw local0 info

          defaults
            mode tcp
            log global
            option tcplog
            option dontlognull
            timeout connect 5s
            timeout client 30s
            timeout server 30s

          frontend minecraft_frontend
            bind :${port}
            default_backend minecraft_backend

          backend minecraft_backend
            server minecraft ${cfg.minecraft.endpoint}:${port} check
        '';
      };
      networking.firewall = {
        allowedTCPPorts = [cfg.minecraft.port];
        allowedUDPPorts = [cfg.minecraft.port];
      };
    })
  ];
}
