{ ... }:

{
  # Yazi file manager. The `y()` cwd-wrapper lives in shell/zsh.nix (ported in
  # Phase 1), so we don't enable yazi's own shell integration to avoid a clash.
  programs.yazi.enable = true;
}
