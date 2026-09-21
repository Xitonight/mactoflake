local function focus_workspace(n)
	local specialws = hl.get_active_special_workspace()
	if specialws then
		hl.dispatch(hl.dsp.workspace.toggle_special())
	end
	hl.dispatch(hl.dsp.focus({ workspace = tostring(n) }))
end

-- Logging
hl.bind("SUPER + ALT + C", hl.dsp.exec_cmd([[hyprctl clients > ~/.cache/clients.txt && notify-send -t 1500 "Clients dumped"]]))
hl.bind("SUPER + ALT + L", hl.dsp.exec_cmd([[hyprctl layers > ~/.cache/layers.txt && notify-send -t 1500 "Layers dumped"]]))

-- Window management
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + M", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + Y", hl.dsp.window.pin({ action = "toggle" }))
hl.bind("SUPER + C", hl.dsp.window.center())
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Workspaces
for i = 1, 10 do
	local n = i == 10 and 0 or i
	hl.bind("SUPER + " .. n, function()
		focus_workspace(i)
	end)
end

-- Move window to workspace
for i = 1, 10 do
	local n = i == 10 and 0 or i
	hl.bind("SUPER + ALT + " .. n, hl.dsp.window.move({ workspace = tostring(n) }))
end

-- Move window to workspace (silent)
for i = 1, 10 do
	local n = i == 10 and 0 or i
	hl.bind("SUPER + SHIFT + ALT + " .. n, hl.dsp.window.move({ workspace = tostring(n), silent = true }))
end

-- Switch occupied workspaces
hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e-1" }))
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + SHIFT + Z", hl.dsp.focus({ workspace = "e-1" }))
hl.bind("SUPER + SHIFT + X", hl.dsp.focus({ workspace = "e+1" }))

-- Focus
hl.bind("SUPER + k", function()
	if hl.get_active_workspace().tiled_layout == "scrolling" then
		hl.dispatch(hl.dsp.layout("focus u"))
	else
		hl.dispatch(hl.dsp.focus({ direction = "u" }))
	end
end)
hl.bind("SUPER + j", function()
	if hl.get_active_workspace().tiled_layout == "scrolling" then
		hl.dispatch(hl.dsp.layout("focus d"))
	else
		hl.dispatch(hl.dsp.focus({ direction = "d" }))
	end
end)
hl.bind("SUPER + h", function()
	if hl.get_active_workspace().tiled_layout == "scrolling" then
		hl.dispatch(hl.dsp.layout("focus l"))
	else
		hl.dispatch(hl.dsp.focus({ direction = "l" }))
	end
end)
hl.bind("SUPER + l", function()
	if hl.get_active_workspace().tiled_layout == "scrolling" then
		hl.dispatch(hl.dsp.layout("focus r"))
	else
		hl.dispatch(hl.dsp.focus({ direction = "r" }))
	end
end)

local function focus_opposite_float()
	local active = hl.get_active_window()
	if not active then
		return
	end
	local is_floating = active.floating
	local ws = hl.get_active_special_workspace() or hl.get_active_workspace()
	if not ws then
		return
	end
	local windows = ws.get_windows(ws)
	if not windows then
		return
	end
	for _, w in ipairs(windows) do
		if w.floating ~= is_floating then
			hl.dispatch(hl.dsp.focus({ window = "address:" .. w.address }))
			return
		end
	end
end

hl.bind("ALT + Tab", function()
	focus_opposite_float()
end)

-- Move window direction
hl.bind("SUPER + SHIFT + h", hl.dsp.window.move({ direction = "l" }), { repeating = true })
hl.bind("SUPER + SHIFT + l", hl.dsp.window.move({ direction = "r" }), { repeating = true })
hl.bind("SUPER + SHIFT + k", hl.dsp.window.move({ direction = "u" }), { repeating = true })
hl.bind("SUPER + SHIFT + j", hl.dsp.window.move({ direction = "d" }), { repeating = true })

-- Resize
hl.bind("SUPER + CTRL + l", hl.dsp.window.resize({ x = 50, y = 0, relative = true }), { repeating = true })
hl.bind("SUPER + CTRL + h", hl.dsp.window.resize({ x = -50, y = 0, relative = true }), { repeating = true })
hl.bind("SUPER + CTRL + j", hl.dsp.window.resize({ x = 0, y = 50, relative = true }), { repeating = true })
hl.bind("SUPER + CTRL + k", hl.dsp.window.resize({ x = 0, y = -50, relative = true }), { repeating = true })

-- Move floating window
hl.bind("SUPER + ALT + H", hl.dsp.window.move({ x = -50, y = 0 }), { release = true })
hl.bind("SUPER + ALT + J", hl.dsp.window.move({ x = 0, y = -50 }), { release = true })
hl.bind("SUPER + ALT + K", hl.dsp.window.move({ x = 0, y = 50 }), { release = true })
hl.bind("SUPER + ALT + L", hl.dsp.window.move({ x = 50, y = 0 }), { release = true })

-- Fullscreen
hl.bind("SUPER + F", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
hl.bind("SUPER + ALT + F", hl.dsp.window.fullscreen({ action = "toggle" }))

-- Special workspace
hl.bind("SUPER + T", hl.dsp.workspace.toggle_special(""))
hl.bind("SUPER + ALT + T", hl.dsp.window.move({ workspace = "special" }))
hl.bind("SUPER + SHIFT + ALT + T", hl.dsp.window.move({ workspace = "special" }))

-- Applications
hl.bind("SUPER + Return", hl.dsp.exec_cmd("kitty"))
hl.bind("SUPER + ALT + Return", hl.dsp.exec_cmd("RAW_TERM=1 kitty --class kitty-floating"))
hl.bind("SUPER + ALT + Escape", hl.dsp.exec_cmd("kitty --class kitty-btop btop"))
hl.bind("SUPER + ALT + V", hl.dsp.exec_cmd("kitty --class kitty-wiremix wiremix"))
hl.bind("SUPER + ALT + W", hl.dsp.exec_cmd("kitty --class kitty-nmtui --override window_padding_width=0 nmtui"))
hl.bind("SUPER + ALT + K", hl.dsp.exec_cmd([[hyprctl switchxkblayout current next && sleep 0.1 && notify-send -t 1500 -h string:x-canonical-private-synchronous:layout "Layout: $(hyprctl -j devices | jq -r '.keyboards[] | select(.main) | .active_keymap')"]]))

-- Vicinae
hl.bind("SUPER + D", hl.dsp.exec_cmd("vicinae toggle"))
hl.bind("SUPER + A", hl.dsp.exec_cmd("vicinae toggle"))
hl.bind("SUPER + TAB", hl.dsp.exec_cmd('vicinae "vicinae://launch/wm/switch-windows?toggle=true"'))
hl.bind("SUPER + Period", hl.dsp.exec_cmd('vicinae "vicinae://launch/core/search-emojis?toggle=true"'))
hl.bind("SUPER + Comma", hl.dsp.exec_cmd('vicinae "vicinae://launch/@sovereign/awww-switcher/wpgrid?toggle=true"'))
hl.bind("SUPER + V", hl.dsp.exec_cmd('vicinae "vicinae://launch/clipboard/history?toggle=true"'))

-- wlr-which-key
hl.bind("SUPER + Space", hl.dsp.exec_cmd("wlr-which-key-menu"))

-- System
hl.bind("SUPER + N", hl.dsp.exec_cmd("swaync-client -t -sw"))
hl.bind("SUPER + SHIFT + R", hl.dsp.exec_cmd("nos start"))
hl.bind("SUPER + ALT + R", hl.dsp.exec_cmd("kitty --class kitty-floating nos watch"))
hl.bind("SUPER + SHIFT + CTRL + ALT + Escape", hl.dsp.exit())
hl.bind(
	"SUPER + ALT + SHIFT + K",
	hl.dsp.exec_cmd(
		"if systemctl is-active --quiet kanata; then systemctl stop kanata && notify-send -t 2000 kanata disabled; else systemctl start kanata && notify-send -t 2000 kanata enabled; fi"
	)
)

-- Lid switch
hl.bind("switch:Lid Switch", hl.dsp.exec_cmd("loginctl lock-session"))
hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd("hyprctl dispatch dpms off"))
hl.bind("switch:off:Lid Switch", hl.dsp.exec_cmd("hyprctl dispatch dpms on"))

-- Media keys
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"))
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioMedia", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioStop", hl.dsp.exec_cmd("playerctl stop"))

-- Volume
local function volume_notify()
	return [[v="$(wpctl get-volume @DEFAULT_AUDIO_SINK@)"; p="$(echo "$v" | awk '{print int($2*100)}')"; echo "$v" | grep -q MUTED && notify-send -t 900 -h string:x-canonical-private-synchronous:volume "Muted" || notify-send -t 900 -h string:x-canonical-private-synchronous:volume -h int:value:"$p" "Volume ${p}%"]]
end

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+; " .. volume_notify()), { repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%-; " .. volume_notify()), { repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle; " .. volume_notify()))

-- Screenshots
local function shot(args)
	return [[mkdir -p ~/.cache/hyprshot && hyprshot ]] .. args .. [[ --clipboard-only -s && wl-paste --type image/png > ~/.cache/hyprshot/last.png && notify-send -t 5000 -a Hyprshot -i ~/.cache/hyprshot/last.png "Screenshot" "Copied to clipboard"]]
end

hl.bind("SUPER + P", hl.dsp.exec_cmd(shot("-m output -m active")))
hl.bind("SUPER + ALT + P", hl.dsp.exec_cmd(shot("-m window -m active")))
hl.bind("SUPER + SHIFT + P", hl.dsp.exec_cmd(shot("-m region")))

-- Brightness
local function brightness_notify()
	return [[p="$(brightnessctl info | awk -F'[(%]' '/Current brightness/ {print $2}')"; [ -n "$p" ] && notify-send -t 900 -h string:x-canonical-private-synchronous:brightness -h int:value:"$p" "Brightness ${p}%"]]
end

hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 5%+; " .. brightness_notify()), { repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-; " .. brightness_notify()), { repeating = true })
