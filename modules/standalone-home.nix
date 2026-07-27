{
  self,
  inputs,
  ...
}:

let
  username = self.const.username;
in
{
  flake.homeConfigurations.work = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
    extraSpecialArgs = {
      inherit inputs;
      inherit (self.const)
        username
        flakeDir
        papersDir
        email
        ;
    };
    modules = [
      self.homeModules.base
      self.homeModules.bat
      self.homeModules.btop
      self.homeModules.devenv
      self.homeModules.eza
      self.homeModules.fsh
      self.homeModules.git
      self.homeModules.lazygit
      self.homeModules.nvim
      self.homeModules.oh-my-posh
      self.homeModules.opencode
      self.homeModules.pay-respects
      self.homeModules.secretspec
      self.homeModules.ssh
      self.homeModules.tmux
      self.homeModules.yazi
      self.homeModules.zoxide
      self.homeModules.zsh
    ];
  };
}
