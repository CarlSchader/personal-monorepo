{ ... }:
{
  nixosModules.saronic-awscli-home = { pkgs, ... }:
  {
    home.packages = with pkgs; [
      awscli2
    ];

    home.file.".aws/config" = {
      text = ''
[default]
sso_session = default
sso_account_id = 395872407596
sso_role_name = Developer
region = us-gov-west-1
[sso-session default]
sso_start_url = https://start.us-gov-west-1.us-gov-home.awsapps.com/directory/saronic
sso_region = us-gov-west-1
sso_registration_scopes = sso:account:access

[sso-session commercial]
sso_start_url = https://d-9a6761a818.awsapps.com/start/#
sso_region = us-east-2
sso_registration_scopes = sso:account:access

[profile commercial-software]
sso_session = commercial
sso_region = us-east-2
sso_account_id = 898313346540
sso_role_name = SoftwareAdministratorAccess
region = us-east-2
output = json
      '';
    };
  };
}
