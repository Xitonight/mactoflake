{
  fileSystems."/srv/media" = {
    device = "/dev/disk/by-label/media";
    fsType = "ext4";
    options = [
      "noatime"
      "x-systemd.device-timeout=5s"
    ];
  };

  fileSystems."/mnt/backup" = {
    device = "/dev/disk/by-label/backup";
    fsType = "ext4";
    options = [
      "noatime"
      "nofail"
      "noauto"
      "x-systemd.automount"
      "x-systemd.device-timeout=5s"
    ];
  };
}
