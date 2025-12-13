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
      name = "carl";
      home = "/Users/carl";
      users.users.carl = {
        packages = self.common.${system}.common;
      };
    };

  nixosModules."${system}-carlschader-user" =
    { ... }:
    {
      name = "carlschader";
      home = "/Users/carlschader";
      users.users.carl = {
        packages = self.common.${system}.common;
      };
    };

  # my saronic user on my work macbooks
  nixosModules."${system}-carl.schader-user" =
    { ... }:
    {
      users.users."carl.schader" = {
        name = "carl.schader";
        home = "/Users/carl.schader";
        packages = self.common.${system}.common;
      };
    };
}
