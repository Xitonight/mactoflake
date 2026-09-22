{
  flake.nixosModules.ssh =
    {
      lib,
      config,
      ...
    }:
    {
      options.mactoflake.ssh.agent = lib.mkOption {
        type = lib.types.enum [
          "1password"
          "bitwarden"
          "rbw"
        ];
        default = "1password";
        description = ''
          Which app's SSH agent backs SSH_AUTH_SOCK, git commit signing and
          the Hyprland autostart: 1Password, the Bitwarden desktop app
          (works with Vaultwarden, socket ~/.bitwarden-ssh-agent.sock,
          authorization prompts inside the desktop window) or rbw (CLI
          Bitwarden client against Vaultwarden, pinentry prompts, socket
          $XDG_RUNTIME_DIR/rbw/ssh-agent-socket, keys stored as SSH key
          vault items). App installation follows this choice: 1Password is
          only installed when this is "1password"; bitwarden-desktop is
          only added when this is "bitwarden"; rbw + pinentry-qt only
          when this is "rbw".
        '';
      };

      config = lib.mkIf (config.mactoflake.ssh.agent == "rbw") {
        systemd.user.sockets.gcr-ssh-agent.wantedBy = lib.mkForce [ ];
      };
    };

  flake.homeModules.ssh =
    {
      config,
      pkgs,
      lib,
      osConfig,
      email,
      ...
    }:
    let
      agent = if osConfig == null then "1password" else osConfig.mactoflake.ssh.agent;

      agentSock =
        if agent == "bitwarden" then
          "${config.home.homeDirectory}/.bitwarden-ssh-agent.sock"
        else if agent == "rbw" then
          "\${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/rbw/ssh-agent-socket"
        else
          "${config.home.homeDirectory}/.1password/agent.sock";

      agentApp = if agent == "rbw" then "rbw-agent" else agent;
    in
    {
      home.sessionVariables = {
        MACTOFLAKE_SSH_AGENT = agentApp;
      };

      home.packages = lib.mkIf (agent == "rbw") [ pkgs.pinentry-qt ];

      programs = {
        zsh.envExtra = ''
          if [[ "$SSH_AUTH_SOCK" != /tmp/auth-agent*/listener.sock ]]; then
            export SSH_AUTH_SOCK="${agentSock}"
          fi
        '';

        rbw = lib.mkIf (agent == "rbw") {
          enable = true;
          settings = {
            inherit email;
            base_url = "https://vault.mactonet.com";
            pinentry = pkgs.pinentry-qt;
          };
        };

        ssh = {
          enable = true;
          enableDefaultConfig = false;
          matchBlocks = {
            mactone.forwardAgent = true;
            mactopad.forwardAgent = true;
            mactoncino.forwardAgent = true;
            vm.forwardAgent = true;
          };
          settings = lib.optionalAttrs (agent != "rbw") {
            "Match host * exec \"test -z \$SSH_TTY\"" = {
              IdentityAgent = agentSock;
            };
          };
        };
      };
    };
}
