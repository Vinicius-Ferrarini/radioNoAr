extends RefCounted

## Carimbo do Ministério, batido torto como todo carimbo de repartição.

static func definition() -> Dictionary:
	return {
		"name": "stamp_ministry",
		"size": Vector2i(20, 20),
		"primitives": [
			{"op": "frame", "x": 1, "y": 3, "w": 18, "h": 14, "color": "red_dim"},
			{"op": "frame", "x": 3, "y": 5, "w": 14, "h": 10, "color": "red_dim"},
			{"op": "dither", "x": 4, "y": 8, "w": 12, "h": 1, "color": "red_hi", "step": 2},
			{"op": "dither", "x": 5, "y": 11, "w": 10, "h": 1, "color": "red_hi", "step": 2},
			{"op": "pixels", "points": [Vector2i(1, 3), Vector2i(18, 16)], "color": "night_deep"},
		],
	}
