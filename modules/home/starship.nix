{ ... }:

{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      add_newline = true;
      format = "$directory$git_branch$git_status$nix_shell$line_break$character";
      right_format = "$cmd_duration";

      directory = {
        style = "16";
        format = "[$path]($style)";
        truncation_length = 0;
        truncate_to_repo = false;
      };

      git_branch = {
        symbol = "";
        style = "bright-black";
        format = "[ $branch]($style)";
      };

      git_status = {
        style = "bright-black";
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

      nix_shell = {
        symbol = "󱄅 ";
        style = "blue";
        format = "[ $symbol$state( \\($name\\))]($style)";
        heuristic = true;
        unknown_msg = "";
        impure_msg = "impure";
        pure_msg = "pure";
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
