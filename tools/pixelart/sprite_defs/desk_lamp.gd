extends RefCounted

## A lâmpada da mesa: a fonte do âmbar. É ela que se apaga conforme o
## cerco aperta (ADR 0008).

static func definition() -> Dictionary:
	return {
		"name": "desk_lamp",
		"size": Vector2i(20, 26),
		"primitives": [
			{"op": "rect", "x": 2, "y": 2, "w": 16, "h": 7, "color": "desk_hi"},
			{"op": "frame", "x": 2, "y": 2, "w": 16, "h": 7, "color": "shadow"},
			{"op": "rect", "x": 4, "y": 9, "w": 12, "h": 3, "color": "amber_dim"},
			{"op": "rect", "x": 6, "y": 12, "w": 8, "h": 2, "color": "amber_mid"},
			{"op": "rect", "x": 8, "y": 14, "w": 4, "h": 2, "color": "glow"},
			{"op": "rect", "x": 9, "y": 16, "w": 2, "h": 7, "color": "desk_hi"},
			{"op": "rect", "x": 5, "y": 23, "w": 10, "h": 3, "color": "desk_dark"},
		],
	}
