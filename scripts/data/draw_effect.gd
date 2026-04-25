class_name DrawEffect
extends CardEffect

@export var value: int = 1

func execute(_source: CharacterData, _target: Object, game_state: Node) -> void:
	game_state.draw_cards(value)
