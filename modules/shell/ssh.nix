{
  flake.homeModules.ssh =
    {
      config,
      lib,
      osConfig,
      ...
    }:
    let
      onePassPath = "${config.home.homeDirectory}/.1password/agent.sock";
      forwardToMactone = osConfig != null && osConfig.networking.hostName != "mactone";
    in
    {
      home.sessionVariables.SSH_AUTH_SOCK = "\${SSH_AUTH_SOCK:-${onePassPath}}";

      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        settings = {
          "Match host * exec \"test -z \$SSH_TTY\"" = {
            IdentityAgent = onePassPath;
          };
        }
        // lib.optionalAttrs forwardToMactone {
          mactone.ForwardAgent = true;
        };
      };
    };
}
