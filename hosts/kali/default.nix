{
  self,
  inputs,
  ...
}:

{
  flake.homeConfigurations.kali = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs {
      system = "x86_64-linux";
      config.allowUnfree = true;
    };
    extraSpecialArgs = {
      inherit inputs;
      username = "kali";
      flakeDir = "/home/kali/.mactoflake";
      limitedColors = false;
      inherit (self.const) papersDir email;
    };
    modules = [
      self.homeModules.base
      self.homeModules.bat
      self.homeModules.btop
      self.homeModules.eza
      self.homeModules.fsh
      self.homeModules.fzf
      self.homeModules.lazygit
      self.homeModules.nix
      self.homeModules.nvim
      self.homeModules.oh-my-posh
      self.homeModules.opencode
      self.homeModules.pay-respects
      self.homeModules.ssh
      self.homeModules.tmux
      self.homeModules.yazi
      self.homeModules.zoxide
      self.homeModules.zsh
    ];
  };
}
