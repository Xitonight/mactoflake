{
  self,
  inputs,
  ...
}:

let
  workUser = "alexpitzalis";
  workFlakeDir = "/home/${workUser}/.mactoflake";
in
{
  flake.homeConfigurations.NTB0000001 = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs {
      system = "x86_64-linux";
      config.allowUnfree = true;
    };
    extraSpecialArgs = {
      inherit inputs;
      username = workUser;
      flakeDir = workFlakeDir;
      limitedColors = true;
      inherit (self.const) papersDir email;
    };
    modules = [
      self.homeModules.base
      self.homeModules.bat
      self.homeModules.btop
      self.homeModules.devenv
      self.homeModules.eza
      self.homeModules.fsh
      self.homeModules.lazygit
      self.homeModules.nix
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
