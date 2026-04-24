class_name CharacterData
extends RefCounted

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
var character_state: CharacterState = CharacterState.COILED
var momentum: int = 0
var performance: int = 0

func is_downed() -> bool:
	return current_hp <= 0

func receive_damage(amount: int) -> void:
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
