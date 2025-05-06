{ lib, config, ... }:
{
  options.nginx-host = lib.mkOption {
    type = lib.types.str;
    description = "The hostname for the virtual host";
    example = "carlschader.com:8080";
  };

  options.nginx-proxy = lib.mkOption {
    type = lib.types.str;
    description = "The url to proxy unencrypted messages to";
    example = "http://127.0.0.1:8080";
  };

  config = {
    services.nginx = {
      enable = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      virtualHosts."${config.nginx-host}" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = config.nginx-proxy;
        };
      };
    };
  };
}
