extends Control

var _character_panels: Dictionary = {}  # character_id -> VBoxContainer

@onready var character_section: HBoxContainer = $MainVBox/ContentRow/CharacterSection
@onready var loot_container: VBoxContainer = $MainVBox/ContentRow/LootPanel/LootContainer
@onready var deck_list: VBoxContainer = $MainVBox/ContentRow/DeckPanel/ScrollContainer/DeckList


func _ready() -> void:
	_build_character_panels()
	_refresh_equipment()
	_refresh_loot()
	_refresh_deck()


func _build_character_panels() -> void:
	for character: CharacterData in GameState.party:
		var panel := VBoxContainer.new()
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		character_section.add_child(panel)
		_character_panels[character.character_id] = panel


func _refresh_equipment() -> void:
	for character: CharacterData in GameState.party:
		var panel: VBoxContainer = _character_panels.get(character.character_id)
		if panel == null:
			continue
		for child in panel.get_children():
			child.queue_free()
		var name_lbl := Label.new()
		name_lbl.text = "%s — HP: %d / %d" % [character.character_name, character.current_hp, character.max_hp]
		name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		panel.add_child(name_lbl)
		for slot: int in [ItemData.SlotType.WEAPON, ItemData.SlotType.OFF_HAND,
				ItemData.SlotType.ARMOUR, ItemData.SlotType.ACCESSORY]:
			var item: ItemData = character.equipment.get(slot, null)
			var slot_name: String = ItemData.SlotType.keys()[slot]
			var lbl := Label.new()
			lbl.text = "%s: %s" % [slot_name, item.item_name if item != null else "(empty)"]
			lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			panel.add_child(lbl)


func _refresh_loot() -> void:
	for child in loot_container.get_children():
		child.queue_free()
	if GameState.pending_loot.is_empty():
		var lbl := Label.new()
		lbl.text = "(no loot)"
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		loot_container.add_child(lbl)
		return
	for raw_item in GameState.pending_loot:
		var item := raw_item as ItemData
		if item == null:
			continue
		var btn := Button.new()
		btn.text = "%s [%s]" % [item.item_name, ItemData.SlotType.keys()[item.slot_type]]
		btn.pressed.connect(_on_loot_item_pressed.bind(item))
		loot_container.add_child(btn)


func _refresh_deck() -> void:
	for child in deck_list.get_children():
		child.queue_free()
	if GameState.deck.is_empty():
		var lbl := Label.new()
		lbl.text = "(empty)"
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		deck_list.add_child(lbl)
		return
	for card: CardData in GameState.deck:
		var lbl := Label.new()
		lbl.text = card.card_name
		deck_list.add_child(lbl)


func _on_loot_item_pressed(item: ItemData) -> void:
	for child in loot_container.get_children():
		child.queue_free()
	var prompt := Label.new()
	prompt.text = "Equip to:"
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	loot_container.add_child(prompt)
	for character: CharacterData in GameState.party:
		var btn := Button.new()
		var has_item: bool = character.equipment.get(item.slot_type, null) != null
		btn.text = character.character_name + (" (replace)" if has_item else "")
		btn.pressed.connect(_do_equip.bind(item, character))
		loot_container.add_child(btn)
	var cancel_btn := Button.new()
	cancel_btn.text = "Cancel"
	cancel_btn.pressed.connect(_refresh_loot)
	loot_container.add_child(cancel_btn)


func _do_equip(item: ItemData, character: CharacterData) -> void:
	GameState.equip_item(character, item.slot_type, item)
	GameState.pending_loot.erase(item)
	_refresh_equipment()
	_refresh_loot()
	_refresh_deck()


func _on_continue_button_pressed() -> void:
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
