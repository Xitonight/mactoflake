{ config, ... }:
let
  hd = config.home.homeDirectory;
in
{
  xdg = {
    userDirs = {
      enable = true;
      setSessionVariables = true;
      createDirectories = true;
      download = "${hd}/dl";
      pictures = "${hd}/pics";
      documents = "${hd}/docs";
      projects = "${hd}/projects";
      videos = "${hd}/videos";
      publicShare = "${hd}";
      templates = "${hd}";
      music = "${hd}";
      desktop = "${hd}";
    };
  };
}
