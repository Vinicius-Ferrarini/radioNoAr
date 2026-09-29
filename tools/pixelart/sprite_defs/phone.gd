extends RefCounted

## O celular. Some no meio da campanha, quando cortarem a internet.

static func definition() -> Dictionary:
	return {
		"name": "phone",
		"size": Vector2i(26, 44),
		"primitives": [
			{"op": "rect", "x": 0, "y": 0, "w": 26, "h": 44, "color": "desk_dark"},
			{"op": "frame", "x": 0, "y": 0, "w": 26, "h": 44, "color": "desk_hi"},
			{"op": "rect", "x": 3, "y": 6, "w": 20, "h": 30, "color": "night_blue"},
			{"op": "dither", "x": 5, "y": 9, "w": 16, "h": 24, "color": "street_blue", "step": 4},
			{"op": "frame", "x": 3, "y": 6, "w": 20, "h": 30, "color": "shadow"},
			{"op": "rect", "x": 10, "y": 3, "w": 6, "h": 2, "color": "shadow"},
			{"op": "rect", "x": 11, "y": 38, "w": 4, "h": 3, "color": "desk_hi"},
		],
	}
