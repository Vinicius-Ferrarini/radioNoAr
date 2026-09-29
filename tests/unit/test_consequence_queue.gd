extends GutTest


func _make_effect(id: String, delay := 1) -> ConsequenceEffect:
	var effect := ConsequenceEffect.new()
	effect.id = id
	effect.delay_nights = delay
	effect.condition = ConsequenceEffect.Condition.ALWAYS
	return effect


func test_schedule_returns_the_morning_the_bill_arrives() -> void:
	var queue := ConsequenceQueue.new()
	assert_eq(queue.schedule(_make_effect("e1", 1), 3), 3,
		"delay 1 e a manha que fecha a propria noite")
	assert_eq(queue.schedule(_make_effect("e2", 2), 3), 4, "delay 2 pula uma manha")


func test_the_bill_arrives_in_the_morning_that_closes_the_night() -> void:
	var queue := ConsequenceQueue.new()
	queue.schedule(_make_effect("e1"), 1)

	var due := queue.pop_due(1)
	assert_eq(due.size(), 1, "a conta chega na manha seguinte ao programa")
	assert_eq(due[0].id, "e1")
	assert_eq(queue.pending_count(), 0, "o que venceu sai da fila")


func test_a_longer_delay_skips_a_morning() -> void:
	var queue := ConsequenceQueue.new()
	queue.schedule(_make_effect("e1", 2), 1)
	assert_eq(queue.pop_due(1).size(), 0, "esta ainda nao vence")
	assert_eq(queue.pop_due(2).size(), 1)


func test_delay_of_zero_is_treated_as_one() -> void:
	var queue := ConsequenceQueue.new()
	assert_eq(queue.schedule(_make_effect("e1", 0), 5), 5, "o minimo e 1")
	assert_eq(queue.pop_due(4).size(), 0)
	assert_eq(queue.pop_due(5).size(), 1)


func test_negative_delay_is_treated_as_one() -> void:
	var queue := ConsequenceQueue.new()
	assert_eq(queue.schedule(_make_effect("e1", -4), 5), 5)


func test_pop_due_also_brings_overdue_effects() -> void:
	var queue := ConsequenceQueue.new()
	queue.schedule(_make_effect("e1", 1), 1)
	queue.schedule(_make_effect("e2", 3), 1)

	var due := queue.pop_due(5)
	assert_eq(due.size(), 2, "o que venceu antes e nao foi lido ainda vence tambem")


func test_pop_due_keeps_the_scheduling_order() -> void:
	var queue := ConsequenceQueue.new()
	queue.schedule(_make_effect("primeiro", 3), 1)
	queue.schedule(_make_effect("segundo", 1), 1)

	var due := queue.pop_due(3)
	assert_eq(due[0].id, "primeiro", "a ordem e a de agendamento, nao a de vencimento")
	assert_eq(due[1].id, "segundo")


func test_peek_due_does_not_remove() -> void:
	var queue := ConsequenceQueue.new()
	queue.schedule(_make_effect("e1"), 1)
	assert_eq(queue.peek_due(1).size(), 1)
	assert_eq(queue.pending_count(), 1, "peek nao deveria consumir")
	assert_eq(queue.pop_due(1).size(), 1)


func test_null_effect_is_not_scheduled() -> void:
	var queue := ConsequenceQueue.new()
	assert_eq(queue.schedule(null, 1), -1)
	assert_eq(queue.pending_count(), 0)


func test_clear_empties_the_queue() -> void:
	var queue := ConsequenceQueue.new()
	queue.schedule(_make_effect("e1"), 1)
	queue.clear()
	assert_eq(queue.pending_count(), 0)
