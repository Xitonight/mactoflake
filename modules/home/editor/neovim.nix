{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    vimAlias = true;
    # Runtime tools for lazy.nvim/mason.nvim (not managed by nixpkgs):
    # ripgrep+fd (telescope), gcc (native builds), unzip (mason),
    # rustc+cargo (blink.cmp build step).
    extraPackages = with pkgs; [
      ripgrep
      fd
      gcc
      unzip
      rustc
      cargo
    ];
  };

  # NvChad config tree, shipped verbatim. lazy.nvim + mason.nvim bootstrap
  # themselves on first launch.
  xdg.configFile."nvim".source = ./nvim;
}
