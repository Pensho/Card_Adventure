class_name EnemyCombatData
extends RefCounted

enum IntentType {
	ATTACK,
	DEFEND,
	DEBUFF,
	BUFF,
	UNKNOWN,
}

var enemy_name: String = ""
var max_hp: int = 30
var current_hp: int = 30
var intent_type: IntentType = IntentType.ATTACK
var intent_value: int = 8

func is_downed() -> bool:
	return current_hp <= 0

func receive_damage(amount: int) -> void:
	current_hp = max(0, current_hp - amount)
