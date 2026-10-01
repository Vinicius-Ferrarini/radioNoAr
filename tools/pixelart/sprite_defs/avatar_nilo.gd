extends RefCounted

## Nilo: técnico do estúdio, óculos e fones, cercado por LEDs, módulos e
## a ferramenta quente que segura perto da bancada.
static func definition() -> Dictionary:
	return {"name":"avatar_nilo","size":Vector2i(32,32),"primitives":[
		{"op":"rect","x":0,"y":0,"w":32,"h":32,"color":"desk_dark"},
		{"op":"rect","x":1,"y":1,"w":30,"h":30,"color":"shadow"},
		{"op":"rect","x":2,"y":3,"w":7,"h":18,"color":"desk_mid"},
		{"op":"rect","x":25,"y":3,"w":5,"h":18,"color":"night_deep"},
		{"op":"pixels","points":[Vector2i(4,5),Vector2i(7,8),Vector2i(4,12),Vector2i(27,6),Vector2i(28,11),Vector2i(26,16)],"color":"amber_mid"},
		{"op":"rect","x":9,"y":6,"w":16,"h":17,"color":"amber_dim"},
		{"op":"rect","x":11,"y":8,"w":12,"h":14,"color":"paper_dark"},
		{"op":"rect","x":10,"y":4,"w":15,"h":6,"color":"ink"},
		{"op":"pixels","points":[Vector2i(9,6),Vector2i(11,3),Vector2i(13,3),Vector2i(15,2),Vector2i(18,2),Vector2i(21,3),Vector2i(24,5)],"color":"shadow"},
		{"op":"rect","x":7,"y":8,"w":4,"h":10,"color":"night_deep"},
		{"op":"rect","x":23,"y":8,"w":4,"h":10,"color":"night_deep"},
		{"op":"line","x1":9,"y1":5,"x2":24,"y2":5,"color":"street_hi"},
		{"op":"frame","x":11,"y":12,"w":6,"h":5,"color":"ink"},
		{"op":"frame","x":19,"y":12,"w":6,"h":5,"color":"ink"},
		{"op":"line","x1":16,"y1":14,"x2":19,"y2":14,"color":"ink"},
		{"op":"pixels","points":[Vector2i(14,14),Vector2i(22,14)],"color":"cold_glow"},
		{"op":"line","x1":17,"y1":15,"x2":17,"y2":18,"color":"amber_dim"},
		{"op":"line","x1":14,"y1":20,"x2":20,"y2":20,"color":"ink"},
		{"op":"rect","x":5,"y":25,"w":23,"h":7,"color":"ink"},
		{"op":"rect","x":9,"y":24,"w":16,"h":3,"color":"night_deep"},
		{"op":"line","x1":25,"y1":22,"x2":25,"y2":29,"color":"amber_hi"},
		{"op":"line","x1":25,"y1":29,"x2":29,"y2":29,"color":"amber_hi"},
		{"op":"pixels","points":[Vector2i(29,28),Vector2i(29,29),Vector2i(28,30)],"color":"glow"},
		{"op":"rect","x":2,"y":24,"w":5,"h":6,"color":"desk_mid"},
		{"op":"pixels","points":[Vector2i(3,25),Vector2i(5,27),Vector2i(3,29)],"color":"red_hi"},
	],"source_details":[
		{"op":"pixels","points":[Vector2i(25,27),Vector2i(28,27),Vector2i(41,27),Vector2i(44,27)],"color":"street_hi"},
		{"op":"pixels","points":[Vector2i(31,38),Vector2i(33,39),Vector2i(35,38),Vector2i(29,42),Vector2i(39,42)],"color":"desk_hi"},
		{"op":"pixels","points":[Vector2i(55,53),Vector2i(58,55),Vector2i(53,58)],"color":"glow"},
		{"op":"line","x1":19,"y1":57,"x2":25,"y2":57,"color":"street_blue"}
	]}
