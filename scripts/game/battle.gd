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
var _enemies: Array[EnemyCombatData] = []
var _is_sentinel: bool = false
var _enemies_acted: int = 0
var _selected_card: CardData
var _selected_target: Object
var _last_played_class: String = ""
var _previously_downed: Dictionary = {}

@onready var _hud: HUD = $HUD


func _ready() -> void:
	_hud.end_turn_pressed.connect(_on_end_turn)
	_hud.card_selected.connect(_on_card_selected)
	_hud.target_selected.connect(_on_target_selected)
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
	var enemy_specs: Array = SceneManager.incoming_data.get("enemies", [])
	_is_sentinel = SceneManager.incoming_data.get("is_sentinel", false)

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
		card.is_aggressive = true
		card.character_class = "lancer"
		var effect := DamageEffect.new()
		effect.value = 6
		card.effects.append(effect)
		GameState.start_combat([lancer], [card, card, card, card, card])
	else:
		GameState.rebuild_deck()
		GameState.start_combat(GameState.party, GameState.deck)

	_active_character = GameState.party[0]

	if enemy_specs.is_empty():
		var fallback := EnemyCombatData.new()
		fallback.enemy_name = "Shambling Mass"
		fallback.max_hp = 30
		fallback.current_hp = 30
		fallback.intent_type = EnemyCombatData.IntentType.ATTACK
		fallback.intent_value = 8
		_enemies = [fallback]
	else:
		_enemies = []
		for spec: Dictionary in enemy_specs:
			var enemy := EnemyCombatData.new()
			enemy.enemy_name = spec["name"]
			enemy.max_hp = spec["max_hp"]
			enemy.current_hp = spec["max_hp"]
			enemy.intent_type = spec["intent_type"]
			enemy.intent_value = spec["intent_value"]
			_enemies.append(enemy)

	_hud.refresh_party(GameState.party)
	_hud.refresh_enemies(_enemies)
	_transition(State.ROUND_START)


func _enter_round_start() -> void:
	for character: CharacterData in GameState.party:
		if not character.is_downed():
			character.character_state = CharacterData.CharacterState.COILED
	_transition(State.DRAWING)


func _enter_drawing() -> void:
	var to_draw: int = HAND_SIZE - GameState.hand.size()
	if to_draw > 0:
		GameState.draw_cards(to_draw)
	_transition(State.PLAYER_TURN)


func _enter_player_turn() -> void:
	_hud.set_player_input_enabled(true)


func _enter_targeting() -> void:
	_return_state = State.PLAYER_TURN
	var alive_enemies: Array[EnemyCombatData] = []
	for enemy: EnemyCombatData in _enemies:
		if not enemy.is_downed():
			alive_enemies.append(enemy)
	if alive_enemies.is_empty():
		_transition(State.RESOLVING)
		return
	if _selected_card.is_aggressive and alive_enemies.size() > 1:
		_hud.show_target_selection(alive_enemies)
		# Stay in TARGETING — wait for target_selected signal from HUD.
	else:
		_selected_target = alive_enemies[0]
		_transition(State.RESOLVING)


func _on_target_selected(target: EnemyCombatData) -> void:
	if current_state != State.TARGETING:
		return
	_selected_target = target
	_transition(State.RESOLVING)


func _update_performance_streak(played_card: CardData) -> void:
	var jester: CharacterData = null
	for character: CharacterData in GameState.party:
		if character.character_id == "jester":
			jester = character
			break
	if jester == null:
		return
	if played_card.character_class == "jester":
		if _last_played_class != "jester":
			jester.performance = 0
		jester.add_performance(1)
	else:
		jester.performance = 0
	_last_played_class = played_card.character_class


func _enter_resolving() -> void:
	_hud.set_player_input_enabled(false)
	if _selected_card != null:
		var played := _selected_card
		var can_play := GameState.can_pay_toll(played, _active_character)
		GameState.play_card(_selected_card, _active_character, _selected_target)
		if can_play:
			_update_performance_streak(played)
		_selected_card = null
		_selected_target = null
		_hud.refresh_enemies(_enemies)
		_hud.refresh_party(GameState.party)
	else:
		var enemy: EnemyCombatData = _enemies[_enemies_acted]
		var target: CharacterData = _find_enemy_target()
		if target != null:
			target.receive_damage(enemy.intent_value)
			GameState.character_hp_changed.emit(target.character_id, target.current_hp)
		_enemies_acted += 1
		_hud.refresh_party(GameState.party)
	_check_outcome()


func _find_enemy_target() -> CharacterData:
	for character: CharacterData in GameState.party:
		if not character.is_downed() and character.character_state == CharacterData.CharacterState.COMMITTED:
			return character
	for character: CharacterData in GameState.party:
		if not character.is_downed():
			return character
	return null


func _enter_enemy_turn() -> void:
	_enemies_acted = 0
	_return_state = State.ENEMY_TURN
	_process_next_enemy()


func _process_next_enemy() -> void:
	if _enemies_acted >= _enemies.size():
		_transition(State.ROUND_START)
		return
	if _enemies[_enemies_acted].is_downed():
		_enemies_acted += 1
		_process_next_enemy()
		return
	_transition(State.RESOLVING)


func _enter_combat_over() -> void:
	_hud.set_player_input_enabled(false)
	if _victory:
		if _is_sentinel:
			var completed_depth := GameState.current_depth
			GameState.current_depth += 1
			SceneManager.go_to("res://scenes/ui/GameOver.tscn", {
				"victory": true,
				"completed_depth": completed_depth,
			})
		else:
			_generate_loot()
			SceneManager.go_to("res://scenes/ui/EquipmentScreen.tscn")
	else:
		GameState.clear_run()
		SceneManager.go_to("res://scenes/ui/GameOver.tscn", {"victory": false})


func _check_outcome() -> void:
	for character: CharacterData in GameState.party:
		if character.is_downed() and not _previously_downed.get(character.character_id, false):
			GameState.remove_character_cards_from_combat(character)
			_previously_downed[character.character_id] = true

	var survivors: Array[CharacterData] = []
	for character: CharacterData in GameState.party:
		if not character.is_downed():
			survivors.append(character)
	if survivors.size() == 1 and survivors[0].character_state != CharacterData.CharacterState.SEVERED:
		survivors[0].character_state = CharacterData.CharacterState.SEVERED

	var all_enemies_downed := true
	for enemy: EnemyCombatData in _enemies:
		if not enemy.is_downed():
			all_enemies_downed = false
			break
	if all_enemies_downed:
		_victory = true
		_transition(State.COMBAT_OVER)
		return

	if survivors.is_empty():
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
	_last_played_class = ""
	for character: CharacterData in GameState.party:
		if character.character_id == "jester":
			character.performance = 0
			break
	_transition(State.ENEMY_TURN)


func _on_card_selected(card: CardData) -> void:
	if current_state != State.PLAYER_TURN:
		return
	_active_character = null
	for character: CharacterData in GameState.party:
		if character.character_id == card.character_class and not character.is_downed():
			_active_character = character
			break
	if _active_character == null:
		return
	_selected_card = card
	_transition(State.TARGETING)
