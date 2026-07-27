{
  flake.homeModules.ssh =
    { config, ... }:
    let
      onePassPath = "${config.home.homeDirectory}/.1password/agent.sock";
    in
    {
      home.sessionVariables.SSH_AUTH_SOCK = onePassPath;

      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        settings."*" = {
          IdentityAgent = onePassPath;
        };
        settings.windev = {
          HostName = "192.168.188.152";
          Port = "2222";
          User = "alexpitzalis";
          IdentityFile = "${config.home.homeDirectory}/.ssh/id_ed25519";
          IdentitiesOnly = "yes";
          LogLevel = "ERROR";
        };
      };
    };
}
