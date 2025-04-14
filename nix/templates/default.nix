# templates sub-flake

{ ... }:
{
  templates = {
    venv = {
      path = ./nix/templates/python;
      description = "Python virutal environment project template";
      welcomeText = ''
        # Nix and python
        - $ nix develop
        - you're in a python virtual environment
        - use pip like normal
      '';
    };

    ml = {
      path = ./nix/templates/python-cuda;
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
