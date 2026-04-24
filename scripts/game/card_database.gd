extends Node

var _cards: Dictionary = {}

func _ready() -> void:
	_load_from_directory("res://data/cards/")

func _load_from_directory(path: String) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		return
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			var resource_path := path + file_name
			var card := load(resource_path) as CardData
			if card != null:
				_cards[resource_path] = card
		file_name = dir.get_next()
	dir.list_dir_end()

func register(id: String, card: CardData) -> void:
	_cards[id] = card

func get_card(id: String) -> CardData:
	return _cards.get(id, null)

func all_cards() -> Array[CardData]:
	var result: Array[CardData] = []
	for card: CardData in _cards.values():
		result.append(card)
	return result
