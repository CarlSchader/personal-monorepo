{ ... }:
{
  nixosModules.saronic-opk-home = { pkgs, ... }:
  {
    home.packages = with pkgs; [
      opkssh 
    ];

    home.file.".opk/config.yml" = {
      text = ''
  ---
  default_provider: saronic
  providers:
    - alias: saronic
      issuer: https://auth.saronic.dev
      client_id: a43e351d-3935-410c-866f-d8bd24027ea2
      client_secret: _Ligm26P8v5PKkdSDBLWvGTYU638iEaJZIVXa0JiYPE
      scopes: openid email groups
      access_type: offline
      prompt: consent
      redirect_uris:
        - http://localhost:3000/login-callback
        - http://localhost:10001/login-callback
        - http://localhost:11110/login-callback
  '';
    };
  };
}

