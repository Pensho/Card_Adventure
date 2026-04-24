class_name DamageEffect
extends CardEffect

@export var value: int = 0

func execute(_source: CharacterData, target: Object, _game_state: Node) -> void:
	if target != null and target.has_method("receive_damage"):
		target.receive_damage(value)
