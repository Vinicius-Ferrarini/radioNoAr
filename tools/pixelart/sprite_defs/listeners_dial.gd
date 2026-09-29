extends RefCounted

## O ponteiro de ouvintes: o único medidor que reage ao vivo.

static func definition() -> Dictionary:
	return {
		"name": "listeners_dial",
		"size": Vector2i(56, 22),
		"primitives": [
			{"op": "rect", "x": 0, "y": 0, "w": 56, "h": 22, "color": "desk_dark"},
			{"op": "rect", "x": 2, "y": 2, "w": 52, "h": 18, "color": "ink"},
			{"op": "dither", "x": 5, "y": 15, "w": 46, "h": 1, "color": "paper_dark", "step": 4},
			{"op": "rect", "x": 45, "y": 4, "w": 6, "h": 2, "color": "red_hi"},
			{"op": "line", "x1": 30, "y1": 5, "x2": 30, "y2": 16, "color": "amber_hi"},
			{"op": "pixels", "points": [Vector2i(29, 7), Vector2i(31, 7), Vector2i(29, 12), Vector2i(31, 12)], "color": "amber_mid"},
			{"op": "rect", "x": 29, "y": 16, "w": 3, "h": 2, "color": "amber_dim"},
			{"op": "frame", "x": 2, "y": 2, "w": 52, "h": 18, "color": "shadow"},
			{"op": "frame", "x": 0, "y": 0, "w": 56, "h": 22, "color": "desk_hi"},
		],
	}
