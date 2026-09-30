extends RefCounted

static func definition() -> Dictionary:
	return {
		"name": "console_lamp_free",
		"size": Vector2i(14, 10),
		"primitives": [
			{"op": "rect", "x": 1, "y": 2, "w": 12, "h": 7, "color": "ink"},
			{"op": "frame", "x": 0, "y": 1, "w": 14, "h": 9, "color": "desk_hi"},
			{"op": "rect", "x": 3, "y": 3, "w": 8, "h": 4, "color": "street_blue"},
			{"op": "rect", "x": 4, "y": 3, "w": 5, "h": 1, "color": "cold_glow"},
		],
	}
