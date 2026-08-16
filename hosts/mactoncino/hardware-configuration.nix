# Placeholder: replace with the real file generated on mactoncino by
# `nixos-generate-config --root /mnt` (or copied from /etc/nixos/) before switching.
# The UUIDs below are fake; building against them will not produce a bootable system.
{
  lib,
  ...
}:

{
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/00000000-0000-0000-0000-000000000000";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/0000-0000";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
