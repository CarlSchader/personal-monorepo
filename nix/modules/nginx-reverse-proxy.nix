{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.nginxHost = lib.mkOption {
    type = lib.types.str;
    description = "The hostname for the virtual host";
    example = "carlschader.com:8080";
  };

  options.nginxHostPath = lib.mkOption {
    type = lib.types.str;
    description = "The url path for the virtual host";
    default = "/";
    example = "/webhook";
  };

  options.nginxProxy = lib.mkOption {
    type = lib.types.str;
    description = "The url to proxy unencrypted messages to";
    example = "http://127.0.0.1:8080";
  };

  options.nginxAcmeEmail = lib.mkOption {
    type = lib.types.str;
    description = "The email used to get acme certs";
    example = "dingus@hotmail.com";
  };

  config = {
    services.nginx = {
      enable = true;
      # because openssl is fucked I guess
      package = pkgs.nginxStable.override { openssl = pkgs.libressl; };
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      virtualHosts."${config.nginxHost}" = {
        enableACME = true;
        forceSSL = true;
        root = "/var/www/${config.nginxHost}";
        locations."${config.nginxHostPath}" = {
          proxyPass = config.nginxProxy;
          extraConfig = ''
            proxy_pass_header Authorization;
            rewrite ^${config.nginxHostPath}(/.*)$ $1 break;
            rewrite ^${config.nginxHostPath}$ / break;
          '';
        };
      };
    };

    security.acme.certs = {
      "${config.nginxHost}".email = config.nginxAcmeEmail;
    };
    security.acme.acceptTerms = true;

  };
}
