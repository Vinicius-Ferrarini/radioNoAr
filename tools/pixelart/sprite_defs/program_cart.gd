extends RefCounted

## Cartucho de pauta: objeto arrastável que substitui o bloco abstrato.
static func definition() -> Dictionary:
	return {
		"name": "program_cart",
		"size": Vector2i(44, 28),
		"primitives": [
			{"op": "rect", "x": 1, "y": 3, "w": 42, "h": 24, "color": "ink"},
			{"op": "rect", "x": 0, "y": 1, "w": 42, "h": 24, "color": "paper_shade"},
			{"op": "frame", "x": 0, "y": 1, "w": 42, "h": 24, "color": "paper_dark"},
			{"op": "rect", "x": 4, "y": 4, "w": 34, "h": 5, "color": "night_blue"},
			{"op": "rect", "x": 4, "y": 12, "w": 25, "h": 2, "color": "paper_dark"},
			{"op": "rect", "x": 4, "y": 17, "w": 31, "h": 2, "color": "paper_dark"},
			{"op": "rect", "x": 34, "y": 20, "w": 4, "h": 3, "color": "amber_mid"},
			{"op": "rect", "x": 39, "y": 7, "w": 3, "h": 11, "color": "desk_hi"},
		],
	}
