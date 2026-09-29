extends RefCounted

## Asset original da abertura; gerado pelo pipeline de pixel art.
static func definition() -> Dictionary:
	return {
		"name": "sponsor_plaque",
		"size": Vector2i(24, 16),
		"primitives": [
			{"op": "rect", "x": 0, "y": 0, "w": 24, "h": 16, "color": "desk_dark"},
			{"op": "frame", "x": 1, "y": 1, "w": 22, "h": 14, "color": "amber_mid"},
			{"op": "rect", "x": 3, "y": 4, "w": 18, "h": 2, "color": "glow"},
			{"op": "rect", "x": 5, "y": 8, "w": 14, "h": 1, "color": "amber_hi"},
			{"op": "rect", "x": 8, "y": 11, "w": 8, "h": 1, "color": "amber_mid"},
		],
	}
