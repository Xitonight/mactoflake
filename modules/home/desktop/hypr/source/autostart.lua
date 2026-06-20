hl.on("hyprland.start", function()
	hl.exec_cmd("hyprpolkitagent")
	hl.exec_cmd('udiskie --event-hook="stow --target=$HOME/Mounts/ --dir=/run/media/ --restow $USER"')

	-- awww-daemon (wallpaper daemon) — Phase 2
	-- hl.exec_cmd("awww-daemon")

	hl.exec_cmd("wl-paste --type text --watch cliphist store")
	hl.exec_cmd("wl-paste --type image --watch cliphist store")
	-- swaync (notifications) — Phase 2
	-- hl.exec_cmd("swaync")

	-- Phase 2 autostart apps (not yet packaged in the flake)
	-- hl.exec_cmd("[workspace special silent] Telegram")
	-- hl.exec_cmd("[workspace 2 silent] zen-browser")
	-- hl.exec_cmd("[workspace 3 silent] bitwarden-desktop")
	hl.exec_cmd("[workspace 1 silent] kitty")
end)
