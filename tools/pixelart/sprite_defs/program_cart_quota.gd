extends RefCounted

## Variante oficial: a faixa vermelha torna a cota visível sem depender de texto.
static func definition() -> Dictionary:
	return {
		"name": "program_cart_quota",
		"size": Vector2i(44, 28),
		"primitives": [
			{"op": "rect", "x": 1, "y": 3, "w": 42, "h": 24, "color": "ink"},
			{"op": "rect", "x": 0, "y": 1, "w": 42, "h": 24, "color": "paper_shade"},
			{"op": "frame", "x": 0, "y": 1, "w": 42, "h": 24, "color": "red_dim"},
			{"op": "rect", "x": 0, "y": 1, "w": 5, "h": 24, "color": "red_dim"},
			{"op": "rect", "x": 8, "y": 4, "w": 29, "h": 5, "color": "red_hi"},
			{"op": "rect", "x": 8, "y": 12, "w": 21, "h": 2, "color": "paper_dark"},
			{"op": "rect", "x": 8, "y": 17, "w": 27, "h": 2, "color": "paper_dark"},
			{"op": "rect", "x": 34, "y": 20, "w": 4, "h": 3, "color": "red_hi"},
		],
	}
