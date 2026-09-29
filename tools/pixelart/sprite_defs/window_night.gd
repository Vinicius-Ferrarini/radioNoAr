extends RefCounted

## A janela para a rua: a única pista sobre o regime. O farol parado no
## meio-fio é o tipo de sinal vago que o design pede — nunca um número.

static func definition() -> Dictionary:
	return {
		"name": "window_night",
		"size": Vector2i(96, 56),
		"primitives": [
			{"op": "rect", "x": 0, "y": 0, "w": 96, "h": 56, "color": "night_deep"},
			{"op": "rect", "x": 3, "y": 3, "w": 90, "h": 50, "color": "night_blue"},
			{"op": "rect", "x": 6, "y": 30, "w": 14, "h": 23, "color": "street_blue"},
			{"op": "rect", "x": 24, "y": 24, "w": 10, "h": 29, "color": "street_blue"},
			{"op": "rect", "x": 38, "y": 34, "w": 18, "h": 19, "color": "street_blue"},
			{"op": "rect", "x": 60, "y": 20, "w": 12, "h": 33, "color": "street_blue"},
			{"op": "rect", "x": 76, "y": 36, "w": 14, "h": 17, "color": "street_blue"},
			{"op": "rect", "x": 9, "y": 34, "w": 2, "h": 2, "color": "amber_dim"},
			{"op": "rect", "x": 27, "y": 28, "w": 2, "h": 2, "color": "amber_dim"},
			{"op": "rect", "x": 64, "y": 25, "w": 2, "h": 2, "color": "cold_glow"},
			{"op": "rect", "x": 80, "y": 40, "w": 2, "h": 2, "color": "amber_dim"},
			{"op": "rect", "x": 3, "y": 46, "w": 90, "h": 7, "color": "night_deep"},
			{"op": "rect", "x": 42, "y": 48, "w": 8, "h": 3, "color": "cold_glow"},
			{"op": "pixels", "points": [Vector2i(41, 49), Vector2i(50, 49), Vector2i(41, 50), Vector2i(50, 50)], "color": "street_hi"},
			{"op": "line", "x1": 48, "y1": 3, "x2": 48, "y2": 52, "color": "desk_hi"},
			{"op": "line", "x1": 3, "y1": 26, "x2": 92, "y2": 26, "color": "desk_hi"},
			{"op": "frame", "x": 2, "y": 2, "w": 92, "h": 52, "color": "shadow"},
			{"op": "frame", "x": 0, "y": 0, "w": 96, "h": 56, "color": "desk_hi"},
		],
	}
