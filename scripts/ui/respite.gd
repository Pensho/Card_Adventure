extends Control

@onready var party_panel: VBoxContainer = $VBox/PartyPanel
@onready var rest_button: Button = $VBox/RestButton


func _ready() -> void:
	_refresh_party()


func _refresh_party() -> void:
	for child in party_panel.get_children():
		child.queue_free()
	for character: CharacterData in GameState.party:
		var lbl := Label.new()
		var tag: String = " (downed)" if character.is_downed() else ""
		lbl.text = "%s%s — HP: %d / %d" % [character.character_name, tag, character.current_hp, character.max_hp]
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		party_panel.add_child(lbl)


func _on_rest_button_pressed() -> void:
	rest_button.disabled = true
	for character: CharacterData in GameState.party:
		if not character.is_downed():
			character.heal(15)
	_refresh_party()
	await get_tree().create_timer(0.8).timeout
	GameState.room_index += 1
	GameState.save_run()
	_go_to_room()


func _go_to_room() -> void:
	while GameState.room_index < GameState.corridor_rooms.size():
		var room: Dictionary = GameState.corridor_rooms[GameState.room_index]
		if room["type"] != "EMPTY":
			break
		GameState.room_index += 1
		GameState.save_run()

	if GameState.room_index >= GameState.corridor_rooms.size():
		SceneManager.go_to("res://scenes/game/DungeonJunction.tscn")
		return

	var room: Dictionary = GameState.corridor_rooms[GameState.room_index]
	match room["type"]:
		"ENCOUNTER":
			SceneManager.go_to("res://scenes/game/Battle.tscn")
		"RESPITE":
			SceneManager.go_to("res://scenes/ui/Respite.tscn")
