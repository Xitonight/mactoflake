{
  flake.homeModules.lazygit = {
    programs.lazygit = {
      enable = true;
      settings = {
        quitOnTopLevelReturn = true;
        gui.theme.selectedLineBgColor = [
          "bold"
          "underline"
        ];
      };
    };
  };
}
