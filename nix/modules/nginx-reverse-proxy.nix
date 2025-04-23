{ lib, config, ... }:
{
  options.host = lib.mkOption {
    type = lib.types.str;
    description = "The hostname for the virtual host";
    example = "localhost:8080";
  };

  config = {
    services.nginx = {
      enable = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
    };
    virtualHosts."${config.host}" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          
        };
    };
  };
}
