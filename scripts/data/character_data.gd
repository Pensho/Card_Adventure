class_name CharacterData
extends RefCounted

const _ItemData = preload("res://scripts/data/item_data.gd")

enum CharacterState {
	NONE,
	COILED,
	WOUNDED,
	COMMITTED,
	BRACED,
	RATTLED,
	SEVERED,
}

var character_id: String = ""
var character_name: String = ""
var max_hp: int = 50
var current_hp: int = 50
var character_state: CharacterState = CharacterState.NONE
var momentum: int = 0
var performance: int = 0
# Keys are ItemData.SlotType int values; values are ItemData or null.
var equipment: Dictionary = {}

func is_downed() -> bool:
	return current_hp <= 0

const BRACE_REDUCTION := 5

func receive_damage(amount: int) -> void:
	if character_state == CharacterState.BRACED:
		amount = max(0, amount - BRACE_REDUCTION)
		character_state = CharacterState.NONE
	current_hp = max(0, current_hp - amount)
	if amount > 0 and not is_downed():
		character_state = CharacterState.WOUNDED

func heal(amount: int) -> void:
	current_hp = min(max_hp, current_hp + amount)

func add_momentum(amount: int) -> void:
	momentum += amount

func spend_momentum(amount: int) -> bool:
	if momentum < amount:
		return false
	momentum -= amount
	return true

func add_performance(amount: int) -> void:
	performance += amount

func spend_performance(amount: int) -> bool:
	if performance < amount:
		return false
	performance -= amount
	return true

func get_all_cards() -> Array[CardData]:
	var result: Array[CardData] = []
	for raw_item in equipment.values():
		if raw_item == null:
			continue
		var item: _ItemData = raw_item
		result.append_array(item.cards)
		result.append_array(item.curse_cards)
	return result
