local hostname_file = io.open("/proc/sys/kernel/hostname")
local hostname = hostname_file and hostname_file:read("*a"):gsub("%s+", "") or ""
if hostname_file then
	hostname_file:close()
end

-- NixOS: "vm" (QEMU) has no nvidia GPU; only real nvidia hosts load this.
if hostname ~= "archpad" and hostname ~= "vm" then
	require("source/nvidia")
end

require("source/env")
require("source/autostart")
require("source/misc")
require("source/submaps")
require("source/appearence")
require("source/animations")
require("source/input")
require("source/windowrules")
require("source/keybinds")

require("monitors")
