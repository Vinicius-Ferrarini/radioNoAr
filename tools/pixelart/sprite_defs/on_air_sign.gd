extends RefCounted

## O letreiro NO AR. Aceso significa que a cidade está ouvindo.

static func definition() -> Dictionary:
	return {
		"name": "on_air_sign",
		"size": Vector2i(40, 14),
		"primitives": [
			{"op": "rect", "x": 0, "y": 0, "w": 40, "h": 14, "color": "shadow"},
			{"op": "rect", "x": 2, "y": 2, "w": 36, "h": 10, "color": "red_dim"},
			{"op": "dither", "x": 3, "y": 3, "w": 34, "h": 8, "color": "red_hi", "step": 2},
			{"op": "frame", "x": 0, "y": 0, "w": 40, "h": 14, "color": "desk_hi"},
		],
	}
