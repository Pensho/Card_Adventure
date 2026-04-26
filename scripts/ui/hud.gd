class_name HUD
extends Control

signal end_turn_pressed
signal card_selected(card: CardData)
signal target_selected(target: EnemyCombatData)

const CardScene := preload("res://scenes/cards/Card.tscn")

@onready var _party_container: HBoxContainer = $VBox/TopBar/PartyPanel/PartyContainer
@onready var _enemy_container: HBoxContainer = $VBox/TopBar/EnemyPanel/EnemyContainer
@onready var _hand_container: HBoxContainer = $VBox/HandContainer
@onready var _deck_label: Label = $VBox/BottomBar/DeckLabel
@onready var _discard_label: Label = $VBox/BottomBar/DiscardLabel
@onready var _end_turn_button: Button = $VBox/BottomBar/EndTurnButton

var _char_panels: Dictionary = {}
var _enemy_panel_data: Array = []


func _ready() -> void:
	GameState.hand_changed.connect(_refresh_hand)
	GameState.character_hp_changed.connect(_on_character_hp_changed)
	_end_turn_button.pressed.connect(func() -> void: end_turn_pressed.emit())


func refresh_party(party: Array[CharacterData]) -> void:
	for character: CharacterData in party:
		if not _char_panels.has(character.character_id):
			var panel := VBoxContainer.new()
			panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			var name_label := Label.new()
			var hp_label := Label.new()
			var state_label := Label.new()
			var momentum_label := Label.new()
			var performance_label := Label.new()
			panel.add_child(name_label)
			panel.add_child(hp_label)
			panel.add_child(state_label)
			panel.add_child(momentum_label)
			panel.add_child(performance_label)
			_party_container.add_child(panel)
			_char_panels[character.character_id] = {
				"panel": panel,
				"name_label": name_label,
				"hp_label": hp_label,
				"state_label": state_label,
				"momentum_label": momentum_label,
				"performance_label": performance_label,
			}
		var labels: Dictionary = _char_panels[character.character_id]
		labels["name_label"].text = character.character_name
		labels["hp_label"].text = "HP: %d / %d" % [character.current_hp, character.max_hp]
		labels["state_label"].text = _state_text(character.character_state)
		labels["momentum_label"].text = "Momentum: %d" % character.momentum if character.momentum > 0 else ""
		labels["performance_label"].text = "Performance: %d" % character.performance if character.performance > 0 else ""
		labels["panel"].modulate = Color(0.5, 0.5, 0.5, 1.0) if character.is_downed() else Color.WHITE


func refresh_enemies(enemies: Array[EnemyCombatData]) -> void:
	for child in _enemy_container.get_children():
		child.queue_free()
	_enemy_panel_data.clear()
	for enemy: EnemyCombatData in enemies:
		var panel := VBoxContainer.new()
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var name_label := Label.new()
		name_label.text = enemy.enemy_name
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		var hp_label := Label.new()
		hp_label.text = "HP: %d / %d" % [enemy.current_hp, enemy.max_hp]
		hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		var intent_label := Label.new()
		intent_label.text = _intent_text(enemy)
		intent_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		panel.add_child(name_label)
		panel.add_child(hp_label)
		panel.add_child(intent_label)
		_enemy_container.add_child(panel)
		_enemy_panel_data.append({"panel": panel, "enemy": enemy})


func show_target_selection(enemies: Array[EnemyCombatData]) -> void:
	for entry: Dictionary in _enemy_panel_data:
		var panel: VBoxContainer = entry["panel"]
		var enemy: EnemyCombatData = entry["enemy"]
		if enemies.has(enemy):
			var btn := Button.new()
			btn.text = "Target"
			btn.pressed.connect(_on_target_button_pressed.bind(enemy))
			panel.add_child(btn)


func _on_target_button_pressed(enemy: EnemyCombatData) -> void:
	for entry: Dictionary in _enemy_panel_data:
		var panel: VBoxContainer = entry["panel"]
		for child in panel.get_children():
			if child is Button:
				child.queue_free()
	target_selected.emit(enemy)


func set_player_input_enabled(enabled: bool) -> void:
	_end_turn_button.disabled = not enabled
	for card_node: CardDisplay in _hand_container.get_children():
		card_node.set_input_enabled(enabled)


func _refresh_hand() -> void:
	for child in _hand_container.get_children():
		child.queue_free()
	for card: CardData in GameState.hand:
		var card_node := CardScene.instantiate() as CardDisplay
		card_node.card_data = card
		card_node.card_pressed.connect(func(c: CardData) -> void: card_selected.emit(c))
		_hand_container.add_child(card_node)
	_deck_label.text = "Deck: %d" % GameState.deck.size()
	_discard_label.text = "Discard: %d" % GameState.discard_pile.size()


func _on_character_hp_changed(_character_id: String, _new_hp: int) -> void:
	refresh_party(GameState.party)


func _state_text(state: CharacterData.CharacterState) -> String:
	match state:
		CharacterData.CharacterState.COILED:    return "[Coiled]"
		CharacterData.CharacterState.WOUNDED:   return "[Wounded]"
		CharacterData.CharacterState.COMMITTED: return "[Committed]"
		CharacterData.CharacterState.BRACED:    return "[Braced]"
		CharacterData.CharacterState.RATTLED:   return "[Rattled]"
		CharacterData.CharacterState.SEVERED:   return "[Severed]"
		_:                                      return ""


func _intent_text(enemy: EnemyCombatData) -> String:
	match enemy.intent_type:
		EnemyCombatData.IntentType.ATTACK:
			return "Intent: Attack %d" % enemy.intent_value
		_:
			return "Intent: Unknown"
