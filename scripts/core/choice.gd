class_name Choice
extends Resource

enum Stance { TRUTH, CROWD_PLEASING, ATTACK }

@export var id: String
@export var label: String
@export var response_text: String
@export var power_delta: int
@export var integrity_delta: int
@export var stance: Stance
