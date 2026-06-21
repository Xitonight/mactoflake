{ pkgs, ... }:

{
  fonts = {
    packages = with pkgs; [
      nerd-fonts.caskaydia-cove
      poppins
      noto-fonts-color-emoji
      font-awesome
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "CaskaydiaCove Nerd Font" ];
        serif = [ "Poppins" ];
        sansSerif = [ "Poppins" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
