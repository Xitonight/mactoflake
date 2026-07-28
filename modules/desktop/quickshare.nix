{
  flake.nixosModules.quickshare =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [ rquickshare ];
      programs.kdeconnect.enable = true;
    };
}
