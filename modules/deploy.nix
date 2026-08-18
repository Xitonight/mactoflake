{
  self,
  inputs,
  ...
}:

{
  flake.deploy = {
    autoRollback = true;
    magicRollback = true;

    nodes.mactoncino = {
      hostname = "mactoncino";
      sshUser = "xitonight";
      profiles.system = {
        user = "root";
        path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.mactoncino;
      };
    };
  };
}
