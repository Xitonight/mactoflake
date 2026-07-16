{ username, ... }:

{
  users.groups.plugdev = { };

  # Fixes silakka54 not being recognized
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="feed", ATTRS{idProduct}=="0000", MODE="0666", GROUP="plugdev", TAG+="uaccess"
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="feed", ATTRS{idProduct}=="0000", MODE="0666", GROUP="plugdev", TAG+="uaccess"
  '';
  users.users."${username}" = {
    extraGroups = [
      "input"
      "plugdev"
    ];
  };
}
