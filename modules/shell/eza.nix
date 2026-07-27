{
  flake.homeModules.eza = {
    programs.eza = {
      enable = true;
      enableZshIntegration = true;
      icons = "auto";
      colors = "always";
    };
  };
}
