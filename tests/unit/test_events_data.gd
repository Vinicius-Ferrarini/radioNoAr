extends GutTest

const EVENT_PATHS := [
	"res://data/events/event_01.tres",
	"res://data/events/event_02.tres",
	"res://data/events/event_03.tres",
]


func test_each_event_file_loads_with_three_choices_and_required_fields() -> void:
	for path in EVENT_PATHS:
		var event: RadioEvent = load(path)
		assert_not_null(event, "evento deveria carregar: %s" % path)
		assert_false(event.id.is_empty(), "id do evento nao deveria ser vazio: %s" % path)
		assert_false(event.headline.is_empty(), "headline nao deveria ser vazio: %s" % path)
		assert_false(event.body.is_empty(), "body nao deveria ser vazio: %s" % path)
		assert_eq(event.choices.size(), 3, "evento deveria ter exatamente 3 choices: %s" % path)

		var stances_found: Dictionary = {}
		for choice in event.choices:
			assert_false(choice.id.is_empty(), "choice.id nao deveria ser vazio em %s" % path)
			assert_false(choice.label.is_empty(), "choice.label nao deveria ser vazio em %s" % path)
			assert_false(choice.response_text.is_empty(), "choice.response_text nao deveria ser vazio em %s" % path)
			stances_found[choice.stance] = true

		assert_true(stances_found.has(Choice.Stance.TRUTH), "evento deveria ter uma choice TRUTH: %s" % path)
		assert_true(stances_found.has(Choice.Stance.CROWD_PLEASING), "evento deveria ter uma choice CROWD_PLEASING: %s" % path)
		assert_true(stances_found.has(Choice.Stance.ATTACK), "evento deveria ter uma choice ATTACK: %s" % path)
