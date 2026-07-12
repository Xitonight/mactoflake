let
  onePassPath = "${config.home.homeDirectory}/.1password/agent.sock";
in {
  home.sessionVariables.SSH_AUTH_SOCK = onePassPath;

  # or, alternatively, set it in `.ssh/config` which has higher precedence:
  programs.ssh = {
    enable = true;
    extraConfig = ''
      Host *
          IdentityAgent ${onePassPath}
    '';
  };
}

