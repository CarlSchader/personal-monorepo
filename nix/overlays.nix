{ self, ...}:
   
{
  overlays = { 
    default = final: prev: 
    let
      repo-packages = self.packages.${final.system};
      repo-packages-list = builtins.attrValues repo-packages; 
    in 
    {
        inherit repo-packages repo-packages-list;
    };
  };
}
