{ ... }:

{
  xdg.enable = true;

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    MANPAGER = "sh -c 'col -bx | bat -l man -p'";
    MANROFFOPT = "-c";
    BAT_THEME = "base16";
    GOPATH = "$HOME/.go";
    ANDROID_HOME = "$HOME/.Android/Sdk";
    PNPM_HOME = "$HOME/.local/share/pnpm";
  };

  home.sessionPath =
    [ "$HOME/.local/share/pnpm" "$HOME/.go/bin" "$HOME/.local/bin" ];
}
