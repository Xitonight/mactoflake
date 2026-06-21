{ pkgs, inputs, ... }:

{
  home.packages = with pkgs;
    [ bitwarden-desktop obsidian telegram-desktop cava ]
    ++ [ inputs.zen-browser.packages.${pkgs.system}.default ];
}
