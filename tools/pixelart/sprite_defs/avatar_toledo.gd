extends RefCounted

## J. Toledo: retrato frontal rígido, testa marcada, sobrancelhas pesadas,
## terno e gravata; papéis acumulados ao fundo.
static func definition() -> Dictionary:
	return {"name":"avatar_toledo","size":Vector2i(32,32),"primitives":[
		{"op":"rect","x":0,"y":0,"w":32,"h":32,"color":"night_blue"},
		{"op":"rect","x":1,"y":1,"w":30,"h":30,"color":"desk_dark"},
		{"op":"rect","x":2,"y":5,"w":7,"h":13,"color":"paper_dark"},
		{"op":"line","x1":3,"y1":7,"x2":7,"y2":7,"color":"paper_shade"},
		{"op":"line","x1":3,"y1":10,"x2":8,"y2":10,"color":"paper_shade"},
		{"op":"rect","x":25,"y":3,"w":5,"h":17,"color":"shadow"},
		{"op":"rect","x":8,"y":5,"w":17,"h":18,"color":"amber_dim"},
		{"op":"rect","x":10,"y":7,"w":13,"h":15,"color":"amber_mid"},
		{"op":"pixels","points":[Vector2i(7,10),Vector2i(7,11),Vector2i(24,10),Vector2i(24,11),Vector2i(9,5),Vector2i(10,4),Vector2i(11,3),Vector2i(21,3),Vector2i(22,4),Vector2i(23,5)],"color":"amber_dim"},
		{"op":"rect","x":9,"y":3,"w":14,"h":5,"color":"shadow"},
		{"op":"pixels","points":[Vector2i(8,5),Vector2i(10,2),Vector2i(11,2),Vector2i(13,2),Vector2i(15,2),Vector2i(17,2),Vector2i(19,2),Vector2i(21,2),Vector2i(23,5)],"color":"desk_mid"},
		{"op":"line","x1":10,"y1":11,"x2":15,"y2":11,"color":"ink"},
		{"op":"line","x1":18,"y1":11,"x2":23,"y2":11,"color":"ink"},
		{"op":"pixels","points":[Vector2i(13,13),Vector2i(20,13)],"color":"night_deep"},
		{"op":"line","x1":16,"y1":13,"x2":16,"y2":17,"color":"amber_dim"},
		{"op":"pixels","points":[Vector2i(15,17),Vector2i(16,18),Vector2i(17,17)],"color":"desk_dark"},
		{"op":"line","x1":13,"y1":20,"x2":20,"y2":20,"color":"ink"},
		{"op":"pixels","points":[Vector2i(12,19),Vector2i(21,19),Vector2i(14,21),Vector2i(19,21)],"color":"amber_dim"},
		{"op":"rect","x":4,"y":25,"w":24,"h":7,"color":"shadow"},
		{"op":"pixels","points":[Vector2i(8,24),Vector2i(9,25),Vector2i(10,26),Vector2i(23,24),Vector2i(22,25),Vector2i(21,26)],"color":"paper"},
		{"op":"rect","x":14,"y":24,"w":5,"h":8,"color":"paper"},
		{"op":"pixels","points":[Vector2i(15,25),Vector2i(18,25),Vector2i(15,26),Vector2i(18,26)],"color":"red_hi"},
		{"op":"rect","x":16,"y":27,"w":2,"h":5,"color":"red_dim"},
	],"source_details":[
		{"op":"line","x1":27,"y1":16,"x2":36,"y2":16,"color":"amber_dim"},
		{"op":"line","x1":25,"y1":19,"x2":30,"y2":19,"color":"desk_dark"},
		{"op":"line","x1":37,"y1":19,"x2":42,"y2":19,"color":"desk_dark"},
		{"op":"pixels","points":[Vector2i(29,38),Vector2i(33,39),Vector2i(38,38),Vector2i(32,57),Vector2i(35,57)],"color":"amber_hi"},
		{"op":"line","x1":7,"y1":27,"x2":15,"y2":27,"color":"paper"}
	]}
