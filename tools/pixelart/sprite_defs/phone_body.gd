extends RefCounted

## O corpo do celular no close: você está segurando ele perto do rosto.
## Nine-patch porque o miolo é a tela, que estica.

static func definition() -> Dictionary:
	return {
		"name": "phone_body",
		"size": Vector2i(32, 32),
		"nine_patch": 12,
		"primitives": [
			{"op": "rect", "x": 0, "y": 0, "w": 32, "h": 32, "color": "desk_dark"},
			{"op": "frame", "x": 0, "y": 0, "w": 32, "h": 32, "color": "desk_hi"},
			{"op": "frame", "x": 1, "y": 1, "w": 30, "h": 30, "color": "shadow"},
			{"op": "rect", "x": 5, "y": 5, "w": 22, "h": 22, "color": "night_blue"},
			{"op": "frame", "x": 5, "y": 5, "w": 22, "h": 22, "color": "ink"},
			{"op": "rect", "x": 13, "y": 2, "w": 6, "h": 1, "color": "shadow"},
		],
	}
