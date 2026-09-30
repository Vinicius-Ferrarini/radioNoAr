extends RefCounted

## Concept art funcional para a tela de preparação em 320x180.
## Não é uma cena final: registra proporção, materiais e hierarquia.
static func definition() -> Dictionary:
	return {
		"name": "ui_planning_concept",
		"size": Vector2i(320, 180),
		"primitives": [
			# Parede e barra superior compacta.
			{"op": "rect", "x": 0, "y": 0, "w": 320, "h": 180, "color": "desk_dark"},
			{"op": "dither", "x": 0, "y": 14, "w": 320, "h": 112, "step": 7, "color": "desk_mid"},
			{"op": "rect", "x": 0, "y": 0, "w": 320, "h": 14, "color": "ink"},
			{"op": "rect", "x": 8, "y": 5, "w": 38, "h": 3, "color": "paper_shade"},
			{"op": "rect", "x": 137, "y": 5, "w": 47, "h": 3, "color": "amber_hi"},
			{"op": "rect", "x": 271, "y": 5, "w": 40, "h": 3, "color": "paper_shade"},

			# Janela ainda visível por trás do close.
			{"op": "rect", "x": 136, "y": 22, "w": 78, "h": 58, "color": "ink"},
			{"op": "rect", "x": 140, "y": 26, "w": 70, "h": 50, "color": "night_deep"},
			{"op": "rect", "x": 142, "y": 54, "w": 66, "h": 2, "color": "street_blue"},
			{"op": "rect", "x": 150, "y": 61, "w": 12, "h": 15, "color": "street_blue"},
			{"op": "rect", "x": 180, "y": 45, "w": 18, "h": 31, "color": "street_blue"},
			{"op": "rect", "x": 184, "y": 49, "w": 3, "h": 2, "color": "amber_dim"},

			# Celular: painel azul ocupa só 39% da tela.
			{"op": "rect", "x": 7, "y": 19, "w": 118, "h": 148, "color": "ink"},
			{"op": "frame", "x": 8, "y": 17, "w": 114, "h": 148, "color": "desk_hi"},
			{"op": "rect", "x": 12, "y": 22, "w": 106, "h": 137, "color": "night_deep"},
			{"op": "frame", "x": 12, "y": 22, "w": 106, "h": 137, "color": "street_blue"},
			{"op": "rect", "x": 48, "y": 19, "w": 34, "h": 2, "color": "paper_dark"},
			# Cabeçalho da conversa.
			{"op": "rect", "x": 16, "y": 27, "w": 14, "h": 14, "color": "street_blue"},
			{"op": "rect", "x": 34, "y": 29, "w": 46, "h": 3, "color": "cold_glow"},
			{"op": "rect", "x": 34, "y": 35, "w": 28, "h": 2, "color": "street_hi"},
			# Balões recebidos e enviados.
			{"op": "rect", "x": 17, "y": 48, "w": 70, "h": 22, "color": "street_blue"},
			{"op": "rect", "x": 21, "y": 53, "w": 52, "h": 2, "color": "cold_glow"},
			{"op": "rect", "x": 21, "y": 59, "w": 58, "h": 2, "color": "street_hi"},
			{"op": "rect", "x": 44, "y": 76, "w": 69, "h": 20, "color": "desk_mid"},
			{"op": "rect", "x": 51, "y": 81, "w": 53, "h": 2, "color": "paper_shade"},
			{"op": "rect", "x": 58, "y": 87, "w": 46, "h": 2, "color": "paper_dark"},
			# Respostas têm três tons/intenções e ícones, sem virar mural vermelho.
			{"op": "rect", "x": 17, "y": 106, "w": 96, "h": 13, "color": "desk_mid"},
			{"op": "frame", "x": 17, "y": 106, "w": 96, "h": 13, "color": "street_hi"},
			{"op": "rect", "x": 22, "y": 111, "w": 6, "h": 3, "color": "cold_glow"},
			{"op": "rect", "x": 33, "y": 111, "w": 66, "h": 2, "color": "paper_shade"},
			{"op": "rect", "x": 17, "y": 123, "w": 96, "h": 13, "color": "desk_mid"},
			{"op": "frame", "x": 17, "y": 123, "w": 96, "h": 13, "color": "amber_dim"},
			{"op": "rect", "x": 22, "y": 128, "w": 6, "h": 3, "color": "amber_hi"},
			{"op": "rect", "x": 33, "y": 128, "w": 58, "h": 2, "color": "paper_shade"},
			{"op": "rect", "x": 17, "y": 140, "w": 96, "h": 13, "color": "desk_mid"},
			{"op": "frame", "x": 17, "y": 140, "w": 96, "h": 13, "color": "red_dim"},
			{"op": "rect", "x": 22, "y": 145, "w": 6, "h": 3, "color": "red_hi"},
			{"op": "rect", "x": 33, "y": 145, "w": 63, "h": 2, "color": "paper_shade"},

			# Mesa física com pauta em cartuchos, caderno e telefone.
			{"op": "rect", "x": 128, "y": 89, "w": 192, "h": 91, "color": "desk_mid"},
			{"op": "dither", "x": 128, "y": 89, "w": 192, "h": 91, "step": 5, "color": "desk_hi"},
			{"op": "rect", "x": 136, "y": 96, "w": 176, "h": 9, "color": "ink"},
			{"op": "rect", "x": 140, "y": 99, "w": 75, "h": 2, "color": "amber_hi"},
			{"op": "rect", "x": 219, "y": 99, "w": 67, "h": 2, "color": "paper_dark"},
			# Quatro cartuchos com título curto e selo.
			{"op": "rect", "x": 136, "y": 112, "w": 40, "h": 27, "color": "paper_shade"},
			{"op": "frame", "x": 136, "y": 112, "w": 40, "h": 27, "color": "paper_dark"},
			{"op": "rect", "x": 141, "y": 117, "w": 24, "h": 3, "color": "night_blue"},
			{"op": "rect", "x": 141, "y": 125, "w": 28, "h": 2, "color": "paper_dark"},
			{"op": "rect", "x": 180, "y": 112, "w": 40, "h": 27, "color": "paper_shade"},
			{"op": "frame", "x": 180, "y": 112, "w": 40, "h": 27, "color": "paper_dark"},
			{"op": "rect", "x": 185, "y": 117, "w": 24, "h": 3, "color": "night_blue"},
			{"op": "rect", "x": 224, "y": 112, "w": 40, "h": 27, "color": "paper_shade"},
			{"op": "frame", "x": 224, "y": 112, "w": 40, "h": 27, "color": "paper_dark"},
			{"op": "rect", "x": 229, "y": 117, "w": 24, "h": 3, "color": "night_blue"},
			{"op": "rect", "x": 268, "y": 112, "w": 40, "h": 27, "color": "paper_shade"},
			{"op": "frame", "x": 268, "y": 112, "w": 40, "h": 27, "color": "red_dim"},
			{"op": "rect", "x": 268, "y": 112, "w": 5, "h": 27, "color": "red_dim"},
			{"op": "rect", "x": 278, "y": 117, "w": 24, "h": 3, "color": "red_hi"},
			# Ação final pequena, acoplada à sequência.
			{"op": "rect", "x": 224, "y": 148, "w": 84, "h": 22, "color": "ink"},
			{"op": "frame", "x": 224, "y": 148, "w": 84, "h": 22, "color": "amber_mid"},
			{"op": "rect", "x": 239, "y": 157, "w": 54, "h": 3, "color": "amber_hi"},
		],
	}
