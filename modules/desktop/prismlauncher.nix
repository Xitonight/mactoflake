{
  flake.homeModules.prismlauncher =
    { pkgs, ... }:
    {
      programs.prismlauncher = {
        enable = true;
        package = pkgs.prismlauncher.override {
          jdks = with pkgs; [
            jdk17
            jdk21
          ];
        };
      };
    };
}
