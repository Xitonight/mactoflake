{ ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Xitonight";
        email = "xitonight@gmail.com";
      };
      init.defaultBranch = "main";
      core.editor = "nvim";
      pull.rebase = true;
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      syntax-theme = "base16";
      line-numbers = true;
      navigate = true;
    };
  };
}
