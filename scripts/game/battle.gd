extends Node

enum State {
	INITIALIZING,
	ROUND_START,
	DRAWING,
	PLAYER_TURN,
	TARGETING,
	RESOLVING,
	ENEMY_TURN,
	COMBAT_OVER,
}

const HAND_SIZE: int = 5

# Item paths available as post-combat loot drops.
const _LOOT_POOL: Array[String] = [
	"res://data/items/lancer_iron_lance.tres",
	"res://data/items/lancer_battered_shield.tres",
	"res://data/items/jester_motley_blade.tres",
	"res://data/items/jester_bells.tres",
]

var current_state: State = State.INITIALIZING
var _return_state: State = State.PLAYER_TURN
var _victory: bool = false
var _active_character: CharacterData
var _enemy: EnemyCombatData
var _enemies_acted: int = 0
var _selected_card: CardData
var _selected_target: Object

@onready var _hud: HUD = $HUD


func _ready() -> void:
	_hud.end_turn_pressed.connect(_on_end_turn)
	_hud.card_selected.connect(_on_card_selected)
	_transition(State.INITIALIZING)


func _transition(new_state: State) -> void:
	current_state = new_state
	match new_state:
		State.INITIALIZING: _enter_initializing()
		State.ROUND_START:  _enter_round_start()
		State.DRAWING:      _enter_drawing()
		State.PLAYER_TURN:  _enter_player_turn()
		State.TARGETING:    _enter_targeting()
		State.RESOLVING:    _enter_resolving()
		State.ENEMY_TURN:   _enter_enemy_turn()
		State.COMBAT_OVER:  _enter_combat_over()


func _enter_initializing() -> void:
	if GameState.party.is_empty():
		# Fallback for direct scene launch during development.
		var lancer := CharacterData.new()
		lancer.character_id = "lancer"
		lancer.character_name = "Lancer"
		lancer.max_hp = 50
		lancer.current_hp = 50
		var card := CardData.new()
		card.card_name = "Lance Strike"
		card.description = "Deal 6 damage."
		card.toll_type = CardData.TollType.FREE
		var effect := DamageEffect.new()
		effect.value = 6
		card.effects.append(effect)
		GameState.start_combat([lancer], [card, card, card, card, card])
	else:
		GameState.start_combat(GameState.party, GameState.deck)

	_active_character = GameState.party[0]

	_enemy = EnemyCombatData.new()
	_enemy.enemy_name = "Shambling Mass"
	_enemy.max_hp = 30
	_enemy.current_hp = 30
	_enemy.intent_type = EnemyCombatData.IntentType.ATTACK
	_enemy.intent_value = 8

	_hud.refresh_character(_active_character)
	_hud.refresh_enemy(_enemy)
	_transition(State.ROUND_START)


func _enter_round_start() -> void:
	_active_character.character_state = CharacterData.CharacterState.COILED
	_transition(State.DRAWING)


func _enter_drawing() -> void:
	var to_draw: int = HAND_SIZE - GameState.hand.size()
	if to_draw > 0:
		GameState.draw_cards(to_draw)
	_transition(State.PLAYER_TURN)


func _enter_player_turn() -> void:
	_hud.set_player_input_enabled(true)


func _enter_targeting() -> void:
	_selected_target = _enemy
	_return_state = State.PLAYER_TURN
	_transition(State.RESOLVING)


func _enter_resolving() -> void:
	_hud.set_player_input_enabled(false)
	if _selected_card != null:
		GameState.play_card(_selected_card, _active_character, _selected_target)
		_selected_card = null
		_selected_target = null
		_hud.refresh_enemy(_enemy)
		_hud.refresh_character(_active_character)
	else:
		_active_character.receive_damage(_enemy.intent_value)
		_enemies_acted += 1
		_hud.refresh_character(_active_character)
	_check_outcome()


func _enter_enemy_turn() -> void:
	_enemies_acted = 0
	_return_state = State.ENEMY_TURN
	_process_next_enemy()


func _process_next_enemy() -> void:
	if _enemies_acted >= 1:
		_transition(State.ROUND_START)
		return
	_transition(State.RESOLVING)


func _enter_combat_over() -> void:
	_hud.set_player_input_enabled(false)
	if _victory:
		_generate_loot()
		SceneManager.go_to("res://scenes/ui/EquipmentScreen.tscn")
	else:
		SceneManager.go_to("res://scenes/ui/GameOver.tscn", {"victory": false})


func _check_outcome() -> void:
	if _enemy.is_downed():
		_victory = true
		_transition(State.COMBAT_OVER)
		return
	var all_downed := true
	for character: CharacterData in GameState.party:
		if not character.is_downed():
			all_downed = false
			break
	if all_downed:
		_victory = false
		_transition(State.COMBAT_OVER)
		return
	match _return_state:
		State.PLAYER_TURN:
			_transition(State.PLAYER_TURN)
		State.ENEMY_TURN:
			_process_next_enemy()


func _generate_loot() -> void:
	GameState.pending_loot = []
	var count: int = GameState.rng.randi_range(1, 2)
	var available: Array[String] = _LOOT_POOL.duplicate()
	for _i in count:
		if available.is_empty():
			break
		var idx: int = GameState.rng.randi_range(0, available.size() - 1)
		var path: String = available.pop_at(idx)
		if ResourceLoader.exists(path):
			GameState.pending_loot.append(load(path))


func _on_end_turn() -> void:
	if current_state != State.PLAYER_TURN:
		return
	_transition(State.ENEMY_TURN)


func _on_card_selected(card: CardData) -> void:
	if current_state != State.PLAYER_TURN:
		return
	_selected_card = card
	_transition(State.TARGETING)
