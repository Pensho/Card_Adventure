extends Control

@onready var continue_button: Button = $VBox/ContinueButton


func _ready() -> void:
	continue_button.visible = false
	if GameState.load_run():
		continue_button.visible = true


func _on_new_run_button_pressed() -> void:
	SceneManager.go_to("res://scenes/ui/CharacterSelect.tscn")


func _on_continue_button_pressed() -> void:
	SceneManager.go_to(_resume_scene())


func _on_glossary_button_pressed() -> void:
	SceneManager.go_to("res://scenes/ui/Glossary.tscn")


func _resume_scene() -> String:
	if GameState.corridor_rooms.is_empty() or GameState.room_index >= GameState.corridor_rooms.size():
		return "res://scenes/game/DungeonJunction.tscn"
	var room: Dictionary = GameState.corridor_rooms[GameState.room_index]
	match room["type"]:
		"ENCOUNTER":
			return "res://scenes/game/Battle.tscn"
		"RESPITE":
			return "res://scenes/ui/Respite.tscn"
		_:
			return "res://scenes/game/DungeonJunction.tscn"
