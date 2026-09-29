extends RefCounted

## O microfone. Elemento central da tela: é o botão que o jogador segura
## para ficar no ar.

static func definition() -> Dictionary:
	return {
		"name": "microphone",
		"size": Vector2i(28, 48),
		"primitives": [
			{"op": "rect", "x": 6, "y": 44, "w": 16, "h": 3, "color": "shadow"},
			{"op": "rect", "x": 8, "y": 41, "w": 12, "h": 3, "color": "desk_dark"},
			{"op": "rect", "x": 13, "y": 26, "w": 2, "h": 15, "color": "desk_hi"},
			{"op": "rect", "x": 7, "y": 6, "w": 14, "h": 20, "color": "desk_dark"},
			{"op": "dither", "x": 9, "y": 8, "w": 10, "h": 16, "color": "amber_dim", "step": 2},
			{"op": "line", "x1": 9, "y1": 8, "x2": 9, "y2": 23, "color": "amber_mid"},
			{"op": "frame", "x": 7, "y": 6, "w": 14, "h": 20, "color": "desk_hi"},
			{"op": "rect", "x": 8, "y": 3, "w": 12, "h": 3, "color": "desk_hi"},
			{"op": "rect", "x": 10, "y": 1, "w": 8, "h": 2, "color": "desk_mid"},
		],
	}
