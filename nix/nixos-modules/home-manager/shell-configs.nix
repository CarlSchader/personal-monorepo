{ ... }:
{
  nixosModules.shell-configs-home = { ... }:
  let
    sessionVariables = {
      EDITOR = "nvim";
      SOPS_EDITOR = "vim";
    };

    initContent = ''
      export ANTHROPIC_API_KEY=$(cat ~/.secrets/anthropic-api-key)
      export OPENAI_API_KEY=$(cat ~/.secrets/openai-api-key)
      export GEMINI_API_KEY=$(cat ~/.secrets/gemini-api-key)
      export GPG_TTY=$(tty)

      eval "$(direnv hook zsh)"

      # only run this code if we're not in an ssh session 
      if [ -z "$SSH_CLIENT" ] && [ -z "$SSH_TTY" ] && [ -z "$SSH_CONNECTION" ]; then
        source <(ssh-agent)
        ssh-add
        ssh-add ~/.ssh/id_ed25519_sk_rk
      fi
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
    home.shell.enableZshIntegration = true;

    programs.zsh = {
      enable = true;
      autosuggestion.enable = true;
      enableCompletion = true;
      enableVteIntegration = true;
    
      history = {
        append = true;
        expireDuplicatesFirst = true;
        extended = true;
      };

      oh-my-zsh = {
        enable = true;
        theme = "clean";
        # plugins = [ ];
      };

      syntaxHighlighting = {
        enable = true;
        highlighters = [ "main" "brackets" "root" "cursor" "line" ];
      };

      inherit sessionVariables;
      inherit initContent;
      inherit shellAliases;
    };
  };
}
