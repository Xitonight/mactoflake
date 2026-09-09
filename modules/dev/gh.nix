{
  flake.homeModules.gh = {
    programs.gh = {
      enable = true;
      gitCredentialHelper.enable = true;
      settings = {
        editor = "nvim";
        git_protocol = "ssh";
      };
    };
  };
}
