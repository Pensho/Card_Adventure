extends GutTest

const GameStateScript := preload("res://scripts/game/game_state.gd")

var _state: Node


func before_each() -> void:
	_state = GameStateScript.new()
	add_child(_state)


func after_each() -> void:
	_state.queue_free()
	_state = null


func _make_card(card_name: String, toll: CardData.TollType = CardData.TollType.FREE) -> CardData:
	var card := CardData.new()
	card.card_name = card_name
	card.toll_type = toll
	return card


func _make_character(hp: int = 50) -> CharacterData:
	var char := CharacterData.new()
	char.character_id = "test_char"
	char.max_hp = hp
	char.current_hp = hp
	return char


# --- deck management ---

func test_start_combat_populates_deck() -> void:
	var chars: Array[CharacterData] = [_make_character()]
	var cards: Array[CardData] = [_make_card("A"), _make_card("B"), _make_card("C")]
	_state.start_combat(chars, cards)
	assert_eq(_state.deck.size(), 3)
	assert_true(_state.hand.is_empty())
	assert_true(_state.discard_pile.is_empty())


func test_draw_cards_moves_cards_to_hand() -> void:
	var chars: Array[CharacterData] = [_make_character()]
	var cards: Array[CardData] = [_make_card("A"), _make_card("B"), _make_card("C")]
	_state.start_combat(chars, cards)
	_state.draw_cards(2)
	assert_eq(_state.hand.size(), 2)
	assert_eq(_state.deck.size(), 1)


func test_draw_does_not_exceed_deck_size() -> void:
	var chars: Array[CharacterData] = [_make_character()]
	var cards: Array[CardData] = [_make_card("A")]
	_state.start_combat(chars, cards)
	_state.draw_cards(5)
	assert_eq(_state.hand.size(), 1)
	assert_eq(_state.deck.size(), 0)


func test_shuffle_discard_into_deck() -> void:
	var chars: Array[CharacterData] = [_make_character()]
	var empty: Array[CardData] = []
	_state.start_combat(chars, empty)
	var discards: Array[CardData] = [_make_card("X"), _make_card("Y")]
	_state.discard_pile = discards
	_state.shuffle_discard_into_deck()
	assert_eq(_state.deck.size(), 2)
	assert_true(_state.discard_pile.is_empty())


func test_draw_triggers_reshuffle_when_deck_empty() -> void:
	var chars: Array[CharacterData] = [_make_character()]
	var cards: Array[CardData] = [_make_card("A")]
	_state.start_combat(chars, cards)
	_state.draw_cards(1)
	_state.discard_pile.append_array(_state.hand)
	_state.hand.clear()
	_state.draw_cards(1)
	assert_eq(_state.hand.size(), 1)


# --- toll checks ---

func test_can_pay_free_toll() -> void:
	var card := _make_card("A", CardData.TollType.FREE)
	assert_true(_state.can_pay_toll(card, _make_character()))


func test_can_pay_momentum_toll_when_sufficient() -> void:
	var card := _make_card("A", CardData.TollType.MOMENTUM)
	card.toll_value = 2
	var char := _make_character()
	char.momentum = 3
	assert_true(_state.can_pay_toll(card, char))


func test_cannot_pay_momentum_toll_when_insufficient() -> void:
	var card := _make_card("A", CardData.TollType.MOMENTUM)
	card.toll_value = 3
	var char := _make_character()
	char.momentum = 1
	assert_false(_state.can_pay_toll(card, char))


func test_can_pay_hp_toll_when_sufficient() -> void:
	var card := _make_card("A", CardData.TollType.HP)
	card.toll_value = 10
	assert_true(_state.can_pay_toll(card, _make_character(30)))


func test_cannot_pay_hp_toll_when_insufficient() -> void:
	var card := _make_card("A", CardData.TollType.HP)
	card.toll_value = 40
	assert_false(_state.can_pay_toll(card, _make_character(30)))


# --- play card ---

func test_play_free_card_moves_to_discard() -> void:
	var card := _make_card("A", CardData.TollType.FREE)
	var char := _make_character()
	var chars: Array[CharacterData] = [char]
	var empty: Array[CardData] = []
	_state.start_combat(chars, empty)
	_state.hand.append(card)
	_state.play_card(card, char, null)
	assert_true(_state.hand.is_empty())
	assert_eq(_state.discard_pile.size(), 1)


func test_play_card_not_in_hand_does_nothing() -> void:
	var card := _make_card("A")
	var char := _make_character()
	var chars: Array[CharacterData] = [char]
	var empty: Array[CardData] = []
	_state.start_combat(chars, empty)
	_state.play_card(card, char, null)
	assert_true(_state.discard_pile.is_empty())


func test_play_card_executes_damage_effect() -> void:
	var effect := DamageEffect.new()
	effect.value = 10
	var card := _make_card("Strike")
	card.effects.append(effect)
	var char := _make_character()
	var target := EnemyCombatData.new()
	target.current_hp = 30
	var chars: Array[CharacterData] = [char]
	var empty: Array[CardData] = []
	_state.start_combat(chars, empty)
	_state.hand.append(card)
	_state.play_card(card, char, target)
	assert_eq(target.current_hp, 20)


func test_play_card_with_hp_toll_costs_hp() -> void:
	var card := _make_card("Blood Strike", CardData.TollType.HP)
	card.toll_value = 5
	var char := _make_character(30)
	var chars: Array[CharacterData] = [char]
	var empty: Array[CardData] = []
	_state.start_combat(chars, empty)
	_state.hand.append(card)
	_state.play_card(card, char, null)
	assert_eq(char.current_hp, 25)


func test_play_card_with_momentum_toll_costs_momentum() -> void:
	var card := _make_card("Charge", CardData.TollType.MOMENTUM)
	card.toll_value = 2
	var char := _make_character()
	char.momentum = 4
	var chars: Array[CharacterData] = [char]
	var empty: Array[CardData] = []
	_state.start_combat(chars, empty)
	_state.hand.append(card)
	_state.play_card(card, char, null)
	assert_eq(char.momentum, 2)


func test_play_card_blocked_when_toll_cannot_be_paid() -> void:
	var card := _make_card("Big Move", CardData.TollType.MOMENTUM)
	card.toll_value = 5
	var char := _make_character()
	char.momentum = 0
	var chars: Array[CharacterData] = [char]
	var empty: Array[CardData] = []
	_state.start_combat(chars, empty)
	_state.hand.append(card)
	_state.play_card(card, char, null)
	assert_eq(_state.hand.size(), 1)
	assert_true(_state.discard_pile.is_empty())
