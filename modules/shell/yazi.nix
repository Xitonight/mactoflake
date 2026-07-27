{
  flake.homeModules.yazi = {
    programs.yazi = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
