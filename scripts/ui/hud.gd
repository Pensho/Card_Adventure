class_name HUD
extends Control

signal end_turn_pressed
signal card_selected(card: CardData)

const CardScene := preload("res://scenes/cards/Card.tscn")

@onready var _char_name_label: Label = $VBox/TopBar/PartyPanel/CharNameLabel
@onready var _char_hp_label: Label = $VBox/TopBar/PartyPanel/CharHPLabel
@onready var _enemy_name_label: Label = $VBox/TopBar/EnemyPanel/EnemyNameLabel
@onready var _enemy_hp_label: Label = $VBox/TopBar/EnemyPanel/EnemyHPLabel
@onready var _enemy_intent_label: Label = $VBox/TopBar/EnemyPanel/EnemyIntentLabel
@onready var _hand_container: HBoxContainer = $VBox/HandContainer
@onready var _deck_label: Label = $VBox/BottomBar/DeckLabel
@onready var _discard_label: Label = $VBox/BottomBar/DiscardLabel
@onready var _end_turn_button: Button = $VBox/BottomBar/EndTurnButton


func _ready() -> void:
	GameState.hand_changed.connect(_refresh_hand)
	GameState.character_hp_changed.connect(_on_character_hp_changed)
	_end_turn_button.pressed.connect(func() -> void: end_turn_pressed.emit())


func refresh_character(character: CharacterData) -> void:
	_char_name_label.text = character.character_name
	_char_hp_label.text = "HP: %d / %d" % [character.current_hp, character.max_hp]


func refresh_enemy(enemy: EnemyCombatData) -> void:
	_enemy_name_label.text = enemy.enemy_name
	_enemy_hp_label.text = "HP: %d / %d" % [enemy.current_hp, enemy.max_hp]
	_enemy_intent_label.text = _intent_text(enemy)


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


func _on_character_hp_changed(character_id: String, _new_hp: int) -> void:
	for character: CharacterData in GameState.party:
		if character.character_id == character_id:
			refresh_character(character)
			return


func _intent_text(enemy: EnemyCombatData) -> String:
	match enemy.intent_type:
		EnemyCombatData.IntentType.ATTACK:
			return "Intent: Attack %d" % enemy.intent_value
		_:
			return "Intent: Unknown"
