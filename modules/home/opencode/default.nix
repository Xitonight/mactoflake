{
  programs.opencode = {
    enable = true;

    settings = {
      plugin = [ "opencode-gemini-auth" ];
      model = "zai-coding-plan/glm-5.2";
      autoupdate = false;
    };

    tui = {
      leader_timeout = 2000;
      keybinds = {
        leader = "ctrl+o";
        app_exit = "ctrl+c,<leader>q";
        editor_open = "ctrl+e";
        messages_half_page_up = "ctrl+u";
        messages_half_page_down = "ctrl+d";
      };
    };

    agents = ./source/agent;
  };
}
