{ ... }:
{
  nixosModules.shell-configs = { pkgs, ... }:
  let
    shellInit = ''
      export EDITOR="nvim"
      export ANTHROPIC_API_KEY=$(cat ~/.secrets/anthropic-api-key)
      export OPENAI_API_KEY=$(cat ~/.secrets/openai-api-key)
      export GEMINI_API_KEY=$(cat ~/.secrets/gemini-api-key)
      export GPG_TTY=$(tty)
      export SOPS_EDITOR="vim"

      eval "$(direnv hook zsh)"
    '';

    loginShellInit = ''
      # source <(ssh-agent)
      # ssh-add
      # ssh-add ~/.ssh/id_ed25519_sk_rk
    '';

    shellAliases = {
      n = "nvim";
      t = "tmux";
      ll = "ls -lh";
      l = "ls";
      g = "grep";
      k = "kubectl";

      # git aliases
      gfa = "git fetch --all";
      ga = "git add .";
      gca = "git add . && git commit -am";
      gpo = "git push origin";
      gpob = "git push origin $(git branch | grep \\* | awk '{ print $2 }')";
      gp = "git pull";
      gs = "git switch";
      gclean = "git branch -D $(git branch | grep -v \\* | grep -v main | grep -v master)";

      tarz = "tar --zstd";
      venv = "source .venv/bin/activate";
      necho = "echo -n";

      pwgen-secure = "pwgen -1cns 16";
    };
  in
  {
    users.defaultUserShell = pkgs.zsh;

    programs.zsh = {
      enable = true;
      enableCompletion = true;
      enableBashCompletion = true;
      enableLsColors = true;

      autosuggestions = {
        enable = true;
        async = true;
      };

      ohMyZsh = {
        enable = true;
        theme = "clean";
        # plugins = [ ];
      };

      syntaxHighlighting = {
        enable = true;
        highlighters = [ "main" "brackets" "root" "cursor" "line" ];
      };
      
      inherit shellInit;
      inherit shellAliases;
      inherit loginShellInit;
    };
  };
}
