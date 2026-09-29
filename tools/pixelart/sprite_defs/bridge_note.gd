extends RefCounted

## Asset original da abertura; gerado pelo pipeline de pixel art.
static func definition() -> Dictionary:
	return {
		"name": "bridge_note",
		"size": Vector2i(24, 16),
		"primitives": [
			{"op": "rect", "x": 0, "y": 0, "w": 24, "h": 16, "color": "paper"},
			{"op": "rect", "x": 2, "y": 2, "w": 20, "h": 12, "color": "night_blue"},
			{"op": "rect", "x": 3, "y": 9, "w": 18, "h": 2, "color": "paper_shade"},
			{"op": "rect", "x": 5, "y": 5, "w": 2, "h": 8, "color": "paper_dark"},
			{"op": "rect", "x": 17, "y": 5, "w": 2, "h": 8, "color": "paper_dark"},
			{"op": "rect", "x": 7, "y": 7, "w": 10, "h": 1, "color": "cold_glow"},
			{"op": "rect", "x": 11, "y": 8, "w": 2, "h": 3, "color": "red_hi"},
		],
	}
