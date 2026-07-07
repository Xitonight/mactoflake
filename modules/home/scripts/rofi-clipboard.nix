{ pkgs, ... }:

{
  home.packages = [
    (pkgs.writeShellScriptBin "rofi-clipboard" ''
      ${pkgs.cliphist}/bin/cliphist list | ${pkgs.rofi}/bin/rofi -dmenu -p "󰅏 Clipboard" -config ~/.config/rofi/clipboard.rasi | ${pkgs.cliphist}/bin/cliphist decode | ${pkgs.wl-clipboard}/bin/wl-copy
    '')
  ];
}
