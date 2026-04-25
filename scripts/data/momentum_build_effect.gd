class_name MomentumBuildEffect
extends CardEffect

@export var value: int = 1

func execute(source: CharacterData, _target: Object, _game_state: Node) -> void:
	source.add_momentum(value)
