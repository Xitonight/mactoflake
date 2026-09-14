{
  flake.nixosModules.shell =
    {
      pkgs,
      lib,
      ...
    }:
    {
      options.mactoflake.shell.multiplexer = lib.mkOption {
        type = lib.types.enum [
          "tmux"
          "herdr"
        ];
        default = "tmux";
        description = ''
          Which terminal multiplexer the shell stack standardizes on.
          "tmux" installs tmux + sesh, auto-generates the "main" session on
          zsh login and applies the tmux keybinds; "herdr" installs herdr
          instead, auto-attaches it on zsh login (skipping the tmux session)
          and ports the keybinds to herdr's config.
        '';
      };

      config = {
        programs.zsh.enable = true; # installs zsh system-wide (required by defaultUserShell)
        programs.fish.enable = true; # alternative shell; zsh remains the login shell
        users.defaultUserShell = pkgs.zsh;
      };
    };
}
