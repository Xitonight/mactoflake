{
  flake.homeModules.opencode =
    {
      config,
      pkgs,
      inputs,
      flakeDir,
      ...
    }:
    {
      programs.opencode = {
        enable = true;
        # TODO: drop overrides once upstream fixes their nix packaging:
        #  - nix/hashes.json is chronically stale (deps merge before the hash bot
        #    re-pins, releases are tagged un-hashed; upstream #59882)
        #  - their nixpkgs pin ships bun 1.4.2, whose linker breaks the ws named
        #    re-export shim at runtime; official releases compile with 1.4.4
        package = inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system}.opencode.override {
          node_modules =
            inputs.opencode.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.callPackage
              "${inputs.opencode}/nix/node_modules.nix"
              {
                rev = inputs.opencode.shortRev or "dirty";
                hash = "sha256-oh5JDEByBdqH+Es3cShMrLWYX8KEHHVudrdVvKyaSuA=";
              };
          inherit (pkgs) bun;
        };

        settings = {
          model = "zai-coding-plan/glm-5.3";
          autoupdate = false;
        };

        tui = {
          leader_timeout = 2000;
          plugin = [ "./herdr-tui-session.js" ];
          keybinds = {
            leader = "ctrl+o";
            app_exit = "ctrl+c,<leader>q";
            editor_open = "ctrl+e";
            messages_half_page_up = "ctrl+u";
            messages_half_page_down = "ctrl+d";
          };
        };

        agents = ./source/agents;

        skills.herdr = "${inputs.herdr}/skills/herdr";
      };

      xdg.configFile = {
        "opencode/plugins/herdr-agent-state.js".source =
          "${inputs.herdr}/src/integration/assets/opencode/herdr-agent-state.js";
        "opencode/herdr-tui-session.js".source =
          "${inputs.herdr}/src/integration/assets/opencode/herdr-tui-session.js";
      };
    };
}
