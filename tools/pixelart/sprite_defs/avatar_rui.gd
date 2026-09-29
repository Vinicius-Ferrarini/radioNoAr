extends RefCounted

## Asset original da abertura; gerado pelo pipeline de pixel art.
static func definition() -> Dictionary:
	return {
		"name": "avatar_rui",
		"size": Vector2i(16, 16),
		"primitives": [
			{"op": "rect", "x": 0, "y": 0, "w": 16, "h": 16, "color": "night_blue"},
			{"op": "rect", "x": 3, "y": 3, "w": 10, "h": 3, "color": "amber_mid"},
			{"op": "rect", "x": 4, "y": 6, "w": 8, "h": 6, "color": "paper_dark"},
			{"op": "rect", "x": 3, "y": 12, "w": 11, "h": 4, "color": "street_blue"},
			{"op": "rect", "x": 5, "y": 7, "w": 2, "h": 1, "color": "ink"},
			{"op": "rect", "x": 10, "y": 7, "w": 2, "h": 1, "color": "ink"},
			{"op": "rect", "x": 7, "y": 10, "w": 3, "h": 1, "color": "shadow"},
			{"op": "rect", "x": 4, "y": 2, "w": 8, "h": 2, "color": "desk_hi"},
		],
	}
