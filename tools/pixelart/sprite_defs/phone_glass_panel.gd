extends RefCounted

## Painel de conversa: vidro frio e borda de aparelho, em contraste com papel.
static func definition() -> Dictionary:
	return {
		"name": "phone_glass_panel",
		"size": Vector2i(32, 32),
		"nine_patch": 12,
		"primitives": [
			{"op": "rect", "x": 0, "y": 0, "w": 32, "h": 32, "color": "ink"},
			{"op": "frame", "x": 1, "y": 1, "w": 30, "h": 30, "color": "desk_hi"},
			{"op": "rect", "x": 4, "y": 5, "w": 24, "h": 23, "color": "night_deep"},
			{"op": "frame", "x": 4, "y": 5, "w": 24, "h": 23, "color": "street_blue"},
			{"op": "rect", "x": 12, "y": 2, "w": 8, "h": 1, "color": "paper_dark"},
			{"op": "rect", "x": 15, "y": 29, "w": 2, "h": 1, "color": "street_hi"},
			{"op": "dither", "x": 6, "y": 7, "w": 20, "h": 2, "step": 3, "color": "street_blue"},
		],
	}
