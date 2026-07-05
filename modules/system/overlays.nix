{ ... }:

{
  nixpkgs.overlays = [
    (_final: prev: {
      zsh-vi-mode = prev.zsh-vi-mode.overrideAttrs (old: {
        # Revert upstream fa5e6fc: it broke escape-prefixed key bindings such
        # as the oh-my-zsh sudo plugin's double-Esc. Remove once upstream ships
        # a fix (zsh-vi-mode issue #334).
        postPatch = (old.postPatch or "") + ''
          sed -i 's#prefix_keys=$keys#prefix_keys=#' zsh-vi-mode.zsh
        '';
      });
    })
  ];
}
