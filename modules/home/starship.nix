{ ... }:

{
  programs.starship = {
    enable = false;
    enableZshIntegration = true;

    settings = {
      add_newline = true;
      format = "$directory$git_branch$git_status$custom$line_break$character";
      right_format = "$cmd_duration";

      directory = {
        style = "16";
        format = "[$path]($style)";
        truncation_length = 0;
        truncate_to_repo = false;
      };

      git_branch = {
        symbol = "";
        style = "245";
        format = "[ $branch]($style)";
      };

      git_status = {
        style = "245";
        modified = "*";
        staged = "*";
        untracked = "*";
        deleted = "*";
        renamed = "*";
        conflicted = "*";
        stashed = "";
        ahead = "⇡";
        behind = "⇣";
        diverged = "⇣⇡";
        up_to_date = "";
        format = "([$modified$staged$untracked$deleted$renamed$conflicted]($style)) [$ahead_behind](cyan)";
      };

      custom.devenv = {
        description = "devenv shell indicator";
        when = ''[ -n "$DEVENV_ROOT" ] || [ -n "$DEVENV_STATE" ]'';
        format = "[ $symbol devenv]($style)";
        symbol = "󱄅";
        style = "blue";
      };

      cmd_duration = {
        min_time = 5000;
        style = "yellow";
        format = "[$duration]($style)";
      };

      character = {
        success_symbol = "[❯](green)";
        error_symbol = "[❯](red)";
        vicmd_symbol = "[❯](green)";
        format = "$symbol ";
      };

      profiles.transient = "$character";
    };
  };
}
