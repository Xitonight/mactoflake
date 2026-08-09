{ inputs, ... }:

{
  flake.nixosModules.sops =
    { username, ... }:
    {
      imports = [ inputs.sops-nix.nixosModules.sops ];

      sops = {
        defaultSopsFile = ../../secrets/user-password.yaml;
        defaultSopsFormat = "yaml";
        age = {
          generateKey = false;
          keyFile = "/home/${username}/.config/sops/age/keys.txt";
        };

        secrets.xitonight-password = {
          neededForUsers = true;
        };
      };
    };
}
