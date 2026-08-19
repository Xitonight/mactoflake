{
  flake.homeModules.ssh =
    { config, ... }:
    let
      onePassPath = "${config.home.homeDirectory}/.1password/agent.sock";
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
        };
      };
    };
}
