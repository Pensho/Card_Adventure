extends Control

const LANCER_HP: int = 50
const JESTER_HP: int = 50


func _on_descend_button_pressed() -> void:
	var lancer := CharacterData.new()
	lancer.character_id = "lancer"
	lancer.character_name = "Lancer"
	lancer.max_hp = LANCER_HP
	lancer.current_hp = LANCER_HP

	var jester := CharacterData.new()
	jester.character_id = "jester"
	jester.character_name = "Jester"
	jester.max_hp = JESTER_HP
	jester.current_hp = JESTER_HP

	GameState.start_run([lancer, jester])
	SceneManager.go_to("res://scenes/game/DungeonJunction.tscn")
