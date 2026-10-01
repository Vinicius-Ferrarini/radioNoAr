extends Button

signal row_pressed(row_id: String)

var _row_id: String = ""


func _ready() -> void:
	pressed.connect(func() -> void: row_pressed.emit(_row_id))


func setup(
	row_id: String,
	sender: String,
	at: String,
	preview: String,
	unread: int,
	avatar: Texture2D = null
) -> void:
	_row_id = row_id
	$Avatar.texture = avatar
	$Name.text = ("(%d) " % unread if unread > 0 else "") + sender
	$Time.text = at
	$Preview.text = preview


func row_id() -> String:
	return _row_id
