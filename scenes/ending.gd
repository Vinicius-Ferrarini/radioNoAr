extends Control

const RADIO_SHOW_SCENE := "res://scenes/radio_show.tscn"

const ENDING_TEXTS := {
	"cinza": "O país não vira utopia, nem colapsa. Nem toda emissora sobreviveu, mas a sua ainda está no ar. Você não salvou todo mundo. Mas também não desistiu.",
	"reforma": "O povo tomou as ruas e, dessa vez, ninguém precisou incendiar nada. Você disse a verdade quando doeu dizer, e ela pegou. O país começa, devagar, a se reformar — sem heróis, sem mártires. Só o trabalho difícil de reconstruir.",
	"repressao": "As ruas ficaram vazias antes mesmo do toque de recolher. Você escolheu o microfone seguro, noite após noite, e o governo aprendeu que podia contar com o seu silêncio. Não houve tanques na sua porta — só o seu nome, apagado aos poucos, de qualquer notícia que ainda importasse.",
}

@onready var ending_text: RichTextLabel = $EndingText
@onready var restart_button: Button = $RestartButton


func _ready() -> void:
	var ending_id := GameState.get_last_ending_id()
	ending_text.text = ENDING_TEXTS.get(ending_id, "")
	restart_button.pressed.connect(_on_restart_pressed)


func _on_restart_pressed() -> void:
	GameState.reset_run()
	get_tree().change_scene_to_file(RADIO_SHOW_SCENE)
