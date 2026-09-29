extends RefCounted

## Asset original da abertura; gerado pelo pipeline de pixel art.
static func definition() -> Dictionary:
	return {
		"name": "gift_record",
		"size": Vector2i(32, 24),
		"primitives": [
			{"op": "rect", "x": 1, "y": 3, "w": 28, "h": 20, "color": "paper_shade"},
			{"op": "rect", "x": 2, "y": 2, "w": 28, "h": 19, "color": "paper"},
			{"op": "rect", "x": 4, "y": 4, "w": 12, "h": 14, "color": "amber_dim"},
			{"op": "rect", "x": 16, "y": 3, "w": 11, "h": 18, "color": "shadow"},
			{"op": "rect", "x": 13, "y": 6, "w": 16, "h": 12, "color": "shadow"},
			{"op": "rect", "x": 18, "y": 10, "w": 6, "h": 4, "color": "red_hi"},
			{"op": "rect", "x": 20, "y": 11, "w": 1, "h": 1, "color": "paper"},
			{"op": "rect", "x": 4, "y": 6, "w": 9, "h": 2, "color": "glow"},
			{"op": "rect", "x": 4, "y": 11, "w": 6, "h": 1, "color": "ink"},
			{"op": "rect", "x": 4, "y": 14, "w": 8, "h": 1, "color": "ink"},
		],
	}
