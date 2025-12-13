{ neovim-config, ... }:
{
  nixosModules = { ... }:
  {
    environment.etc.neovim-config = {
      source
    }
  }; 
}

  
