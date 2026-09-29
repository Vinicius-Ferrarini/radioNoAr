extends RefCounted

## Asset original da abertura; gerado pelo pipeline de pixel art.
static func definition() -> Dictionary:
	return {
		"name": "avatar_nilo",
		"size": Vector2i(16, 16),
		"primitives": [
			{"op": "rect", "x": 0, "y": 0, "w": 16, "h": 16, "color": "desk_dark"},
			{"op": "rect", "x": 4, "y": 3, "w": 8, "h": 9, "color": "paper_dark"},
			{"op": "rect", "x": 3, "y": 2, "w": 10, "h": 3, "color": "shadow"},
			{"op": "rect", "x": 3, "y": 6, "w": 4, "h": 3, "color": "ink"},
			{"op": "rect", "x": 9, "y": 6, "w": 4, "h": 3, "color": "ink"},
			{"op": "rect", "x": 7, "y": 7, "w": 2, "h": 1, "color": "ink"},
			{"op": "rect", "x": 2, "y": 12, "w": 12, "h": 4, "color": "amber_dim"},
			{"op": "rect", "x": 7, "y": 10, "w": 3, "h": 1, "color": "shadow"},
		],
	}
