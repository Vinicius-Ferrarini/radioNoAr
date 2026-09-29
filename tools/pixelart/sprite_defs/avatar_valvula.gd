extends RefCounted

## Oficina do Portão Doze. Não mandou foto de gente: mandou foto da
## peça, para provar que tem. É a única coisa que interessa, e é
## exatamente o que uma isca mandaria.

static func definition() -> Dictionary:
	return {
		"name": "avatar_valvula",
		"size": Vector2i(16, 16),
		"primitives": [
			{"op": "rect", "x": 0, "y": 0, "w": 16, "h": 16, "color": "night_deep"},
			{"op": "rect", "x": 5, "y": 2, "w": 6, "h": 9, "color": "desk_mid"},
			{"op": "rect", "x": 6, "y": 3, "w": 4, "h": 7, "color": "amber_dim"},
			{"op": "rect", "x": 7, "y": 4, "w": 2, "h": 4, "color": "amber_hi"},
			{"op": "rect", "x": 4, "y": 11, "w": 8, "h": 3, "color": "desk_hi"},
			{"op": "dither", "x": 4, "y": 11, "w": 8, "h": 3, "color": "desk_dark", "step": 2},
			{"op": "pixels", "points": [Vector2i(5, 14), Vector2i(8, 14), Vector2i(10, 14)], "color": "desk_mid"},
		],
	}
