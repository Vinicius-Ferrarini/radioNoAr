extends RefCounted

## Bolha de mensagem de quem mandou. Nine-patch: o texto estica a bolha.

static func definition() -> Dictionary:
	return {
		"name": "bubble_them",
		"size": Vector2i(12, 12),
		"nine_patch": 4,
		"primitives": [
			{"op": "rect", "x": 1, "y": 0, "w": 11, "h": 12, "color": "street_blue"},
			{"op": "rect", "x": 0, "y": 8, "w": 2, "h": 3, "color": "street_blue"},
			{"op": "line", "x1": 1, "y1": 0, "x2": 11, "y2": 0, "color": "street_hi"},
			{"op": "line", "x1": 1, "y1": 11, "x2": 11, "y2": 11, "color": "night_blue"},
		],
	}
