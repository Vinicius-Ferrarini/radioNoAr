class_name Notebook
extends RefCounted

## O caderno do apresentador: o livro de regras que cresce a cada noite.
## Nao existe remocao — o que foi anotado fica.

var _entries: Array[NotebookEntry] = []
var _by_id: Dictionary = {}


func add_entry(entry: NotebookEntry) -> bool:
	if entry == null or entry.id.is_empty() or _by_id.has(entry.id):
		return false
	_entries.append(entry)
	_by_id[entry.id] = entry
	return true


## Devolve quantas entradas foram realmente acrescentadas.
func add_entries(entries: Array[NotebookEntry]) -> int:
	var added := 0
	for entry in entries:
		if add_entry(entry):
			added += 1
	return added


func all_entries() -> Array[NotebookEntry]:
	return _entries.duplicate()


func entries_in_category(category: int) -> Array[NotebookEntry]:
	var found: Array[NotebookEntry] = []
	for entry in _entries:
		if entry.category == category:
			found.append(entry)
	return found


func entries_for_key(key: String) -> Array[NotebookEntry]:
	var found: Array[NotebookEntry] = []
	for entry in _entries:
		if entry.key == key:
			found.append(entry)
	return found


func find_entry(id: String) -> NotebookEntry:
	return _by_id.get(id, null)


func has_entry(id: String) -> bool:
	return _by_id.has(id)


func forbidden_words() -> PackedStringArray:
	var words := PackedStringArray()
	for entry in entries_in_category(NotebookEntry.Category.FORBIDDEN_WORD):
		if not words.has(entry.key):
			words.append(entry.key)
	return words
