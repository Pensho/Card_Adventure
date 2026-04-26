extends Control

@onready var depth_label: Label = $VBox/DepthLabel
@onready var passage_container: VBoxContainer = $VBox/PassageContainer
@onready var empty_overlay: CanvasLayer = $EmptyOverlay


func _ready() -> void:
	empty_overlay.visible = false
	depth_label.text = "Depth %d" % GameState.current_depth
	var passages: Array[Dictionary] = DungeonGenerator.generate_junction(
			GameState.rng, GameState.current_depth)
	for passage in passages:
		_add_passage_button(passage)


func _add_passage_button(passage: Dictionary) -> void:
	var btn := Button.new()
	btn.text = passage["hint"]
	btn.custom_minimum_size = Vector2(400, 0)
	btn.pressed.connect(_on_passage_selected.bind(passage))
	passage_container.add_child(btn)


func _on_passage_selected(passage: Dictionary) -> void:
	for child in passage_container.get_children():
		(child as Button).disabled = true
	GameState.corridor_rooms.assign(passage["rooms"])
	GameState.room_index = 0
	GameState.save_run()
	_go_to_room()


func _go_to_room() -> void:
	if GameState.room_index >= GameState.corridor_rooms.size():
		SceneManager.go_to("res://scenes/game/DungeonJunction.tscn")
		return
	var room: Dictionary = GameState.corridor_rooms[GameState.room_index]
	match room["type"]:
		"ENCOUNTER":
			SceneManager.go_to("res://scenes/game/Battle.tscn", {
				"enemies": room["enemies"],
				"is_sentinel": room.get("is_sentinel", false),
			})
		"RESPITE":
			SceneManager.go_to("res://scenes/ui/Respite.tscn")
		"EMPTY":
			_show_empty_room()


func _show_empty_room() -> void:
	empty_overlay.visible = true
	await get_tree().create_timer(2.0).timeout
	GameState.room_index += 1
	GameState.save_run()
	empty_overlay.visible = false
	_go_to_room()
