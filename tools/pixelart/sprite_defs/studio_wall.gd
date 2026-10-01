extends RefCounted

## Parede reduzida a uma moldura acústica escura para a janela panorâmica.
static func definition() -> Dictionary:
	var parts: Array[Dictionary] = [
		{"op":"rect","x":0,"y":0,"w":320,"h":180,"color":"shadow"},
		{"op":"rect","x":0,"y":14,"w":320,"h":112,"color":"desk_dark"},
		{"op":"rect","x":0,"y":118,"w":320,"h":8,"color":"ink"},
		{"op":"rect","x":0,"y":118,"w":320,"h":2,"color":"amber_dim"},
	]
	for x in range(0, 320, 16):
		parts.append({"op":"rect","x":x,"y":14,"w":1,"h":104,"color":"desk_mid"})
		parts.append({"op":"rect","x":x + 2,"y":15,"w":1,"h":102,"color":"shadow"})
	return {"name":"studio_wall","size":Vector2i(320,180),"primitives":parts}
