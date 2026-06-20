{ ... }:

{
  programs.zsh = {
    enable = true;
    autocd = true;
    enableCompletion = false; # zinit manages completions

    history = {
      path = "$HOME/.zsh_history";
      size = 10000;
      save = 10000;
      ignoreDups = true;
      ignoreAllDups = true;
      ignoreSpace = true;
      findNoDups = true;
      saveNoDups = true;
      share = true;
      append = true;
    };

    initContent = builtins.readFile ./zshrc.zsh;
  };
}
