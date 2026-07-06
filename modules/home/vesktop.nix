{ ... }:

{
  programs.vesktop = {
    enable = true;
    settings = {
      appBadge = false;
      arRPC = true;
      checkUpdates = false;
      customTitleBar = false;
      disableMinSize = true;
      minimizeToTray = false;
      tray = false;
      splashTheming = true;
      staticTitle = true;
      hardwareAcceleration = true;
      discordBranch = "stable";
    };
    vencord.settings = {
      autoUpdate = false;
      autoUpdateNotification = false;
      notifyAboutUpdates = false;
      plugins = {
        FakeNitro = {
          enabled = true;
        };
      };
    };
  };
}
