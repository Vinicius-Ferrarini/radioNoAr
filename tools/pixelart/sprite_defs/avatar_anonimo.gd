extends RefCounted

## Sem remetente. Não há foto: é o quadrado cinza que o aparelho mostra
## quando o número não tem nada. A única coisa visível é o lacre.

static func definition() -> Dictionary:
	return {
		"name": "avatar_anonimo",
		"size": Vector2i(16, 16),
		"primitives": [
			{"op": "rect", "x": 0, "y": 0, "w": 16, "h": 16, "color": "desk_dark"},
			{"op": "dither", "x": 0, "y": 0, "w": 16, "h": 16, "color": "shadow", "step": 2},
			{"op": "rect", "x": 6, "y": 6, "w": 4, "h": 4, "color": "red_dim"},
			{"op": "pixels", "points": [
				Vector2i(5, 7), Vector2i(10, 7), Vector2i(5, 8), Vector2i(10, 8),
				Vector2i(7, 5), Vector2i(8, 5), Vector2i(7, 10), Vector2i(8, 10)
			], "color": "red_dim"},
			{"op": "frame", "x": 0, "y": 0, "w": 16, "h": 16, "color": "desk_mid"},
		],
	}
