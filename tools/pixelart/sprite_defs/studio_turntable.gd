extends RefCounted

## Asset original da abertura; gerado pelo pipeline de pixel art.
static func definition() -> Dictionary:
	return {
		"name": "studio_turntable",
		"size": Vector2i(48, 24),
		"primitives": [
			{"op": "rect", "x": 0, "y": 2, "w": 48, "h": 22, "color": "ink"},
			{"op": "rect", "x": 1, "y": 1, "w": 46, "h": 21, "color": "desk_hi"},
			{"op": "frame", "x": 2, "y": 2, "w": 44, "h": 19, "color": "amber_dim"},
			{"op": "rect", "x": 6, "y": 4, "w": 20, "h": 15, "color": "shadow"},
			{"op": "rect", "x": 9, "y": 2, "w": 14, "h": 19, "color": "shadow"},
			{"op": "frame", "x": 10, "y": 6, "w": 12, "h": 11, "color": "desk_mid"},
			{"op": "rect", "x": 14, "y": 9, "w": 5, "h": 5, "color": "amber_hi"},
			{"op": "rect", "x": 16, "y": 11, "w": 1, "h": 1, "color": "ink"},
			{"op": "rect", "x": 35, "y": 5, "w": 3, "h": 10, "color": "paper_dark"},
			{"op": "rect", "x": 28, "y": 13, "w": 10, "h": 2, "color": "paper_shade"},
			{"op": "rect", "x": 27, "y": 12, "w": 3, "h": 5, "color": "paper"},
			{"op": "rect", "x": 40, "y": 17, "w": 3, "h": 2, "color": "red_hi"},
		],
	}
