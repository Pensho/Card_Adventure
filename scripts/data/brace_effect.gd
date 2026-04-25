class_name BraceEffect
extends CardEffect

func execute(source: CharacterData, _target: Object, _game_state: Node) -> void:
	source.character_state = CharacterData.CharacterState.BRACED
