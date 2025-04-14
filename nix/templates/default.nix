# templates sub-flake

{ ... }:
{
  templates = {
    venv = {
      path = ./python;
      description = "Python virutal environment project template";
      welcomeText = ''
        # Nix and python
        - $ nix develop
        - you're in a python virtual environment
        - use pip like normal
      '';
    };

    ml = {
      path = ./python-cuda;
      description = "Cuda python environment project template";
      welcomeText = ''
        # Nix and python
        - $ nix develop
        - you're in a python cuda virtual environment
        - use pip like normal
      '';
    };
  };
}
