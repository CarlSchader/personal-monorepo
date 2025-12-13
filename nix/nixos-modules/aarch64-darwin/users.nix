{
  self,
  ...
}:
let
  system = "aarch64-darwin";
in
{
  nixosModules."${system}-carl-user" =
    { ... }:
    {
      users.users.carl = {
        name = "carl";
        home = "/Users/carl";
        packages = self.common.${system}.user-packages;
      };
    };

  nixosModules."${system}-carlschader-user" =
    { ... }:
    {
      users.users.carl = {
        name = "carlschader";
        home = "/Users/carlschader";
        packages = self.common.${system}.user-packages;
      };
    };

  # my saronic user on my work macbooks
  nixosModules."${system}-carl.schader-user" =
    { ... }:
    {
      users.users."carl.schader" = {
        name = "carl.schader";
        uid = 501;
        home = "/Users/carl.schader";
        packages = self.common.${system}.user-packages;
      };
    };
}
