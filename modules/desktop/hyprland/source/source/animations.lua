hl.config({
	animations = {
		enabled = true,
	},
})

hl.curve("myBezier", { type = "bezier", points = { { 0.4, 0.0 }, { 0.2, 1.0 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 2.5, bezier = "myBezier", style = "popin 80%" })
hl.animation({ leaf = "border", enabled = true, speed = 2.5, bezier = "myBezier" })
hl.animation({ leaf = "fade", enabled = true, speed = 2.5, bezier = "myBezier" })
hl.animation({
	leaf = "workspaces",
	enabled = true,
	speed = 2.5,
	bezier = "myBezier",
	style = "slidefadevert 20%",
})

-- Material 3 emphasized easing (decelerate for entrances, accelerate for exits)
hl.curve("mdDecel", { type = "bezier", points = { { 0.05, 0.7 }, { 0.1, 1.0 } } })
hl.curve("mdAccel", { type = "bezier", points = { { 0.3, 0.0 }, { 0.8, 0.15 } } })

hl.animation({ leaf = "layers", enabled = true, speed = 2.8, bezier = "mdDecel", style = "popin 90%" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.4, bezier = "mdAccel", style = "fade" })
