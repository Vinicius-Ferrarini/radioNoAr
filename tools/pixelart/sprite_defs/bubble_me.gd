extends RefCounted

## Bolha do que você respondeu. Espelho da bubble_them: a ponta fica do
## outro lado e a cor é mais quente, para a thread se ler de relance
## (ADR 0013).

static func definition() -> Dictionary:
	return {
		"name": "bubble_me",
		"size": Vector2i(12, 12),
		"nine_patch": 4,
		"primitives": [
			{"op": "rect", "x": 0, "y": 0, "w": 11, "h": 12, "color": "desk_mid"},
			{"op": "rect", "x": 10, "y": 8, "w": 2, "h": 3, "color": "desk_mid"},
			{"op": "line", "x1": 0, "y1": 0, "x2": 10, "y2": 0, "color": "desk_hi"},
			{"op": "line", "x1": 0, "y1": 11, "x2": 10, "y2": 11, "color": "desk_dark"},
		],
	}
