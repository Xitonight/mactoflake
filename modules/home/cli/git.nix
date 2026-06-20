{ ... }:

{
  programs.git = {
    enable = true;
    userName = "Xitonight";
    userEmail = "xitonight@gmail.com";
    extraConfig = {
      init.defaultBranch = "main";
      core.editor = "nvim";
      pull.rebase = true;
    };
    delta = {
      enable = true;
      options = {
        syntax-theme = "base16";
        line-numbers = true;
        navigate = true;
      };
    };
  };
}
