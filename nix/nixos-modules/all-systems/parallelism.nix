{ ... }:
{
  nixosModules.parallelism = { ... }:
  {
      nix.settings = {
      # 0 tells Nix to use all available CPU cores for each build
      cores = 0; 
      
      # 'auto' lets Nix decide how many separate builds to run at once
      max-jobs = "auto";
    };
  };
}
