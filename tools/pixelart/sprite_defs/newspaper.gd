extends RefCounted

## O jornal da manhã. Papel barato, tarja de cabeçalho e colunas de
## texto sugeridas por dithering — o que se lê de verdade é fonte, não
## pixel (ADR 0006).

static func definition() -> Dictionary:
	return {
		"name": "newspaper",
		"size": Vector2i(32, 32),
		"nine_patch": 12,
		"primitives": [
			{"op": "rect", "x": 0, "y": 0, "w": 32, "h": 32, "color": "paper_shade"},
			{"op": "rect", "x": 0, "y": 0, "w": 32, "h": 5, "color": "ink"},
			{"op": "dither", "x": 1, "y": 1, "w": 30, "h": 3, "color": "paper", "step": 3},
			{"op": "line", "x1": 0, "y1": 6, "x2": 31, "y2": 6, "color": "paper_dark"},
			{"op": "line", "x1": 15, "y1": 8, "x2": 15, "y2": 30, "color": "paper_dark"},
			{"op": "frame", "x": 0, "y": 0, "w": 32, "h": 32, "color": "paper_dark"},
			{"op": "line", "x1": 0, "y1": 31, "x2": 31, "y2": 31, "color": "desk_dark"},
		],
	}
