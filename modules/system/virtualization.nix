{
  lib,
  config,
  pkgs,
  username,
  ...
}:

let
  cfg = config.mactoflake.virtualization;
in
{
  options.mactoflake.virtualization = {
    enable = lib.mkEnableOption "libvirt + QEMU/KVM virtualization stack with virt-manager";

    enableUSBRedirection = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Enable SPICE USB redirection so USB devices can be passed through
        to VMs from virt-manager.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = false;
        vhostUserPackages = [ pkgs.virtiofsd ];
        swtpm.enable = true;
      };
    };

    virtualisation.spiceUSBRedirection.enable = cfg.enableUSBRedirection;

    programs.virt-manager.enable = true;

    environment.systemPackages = with pkgs; [
      virtio-win
    ];

    users.users."${username}".extraGroups = [
      "libvirtd"
      "kvm"
    ];

    networking.firewall.trustedInterfaces = [ "virbr0" ];
  };
}
