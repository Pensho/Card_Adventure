extends Node

signal hand_changed
signal deck_changed
signal character_hp_changed(character_id: String, new_hp: int)

var party: Array[CharacterData] = []
var deck: Array[CardData] = []
var hand: Array[CardData] = []
var discard_pile: Array[CardData] = []
var exhaust_pile: Array[CardData] = []
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var run_seed: int = 0

func start_combat(characters: Array[CharacterData], starting_deck: Array[CardData]) -> void:
	party = characters
	deck = starting_deck.duplicate()
	hand = []
	discard_pile = []
	exhaust_pile = []
	_shuffle_deck()

func draw_cards(count: int) -> void:
	for i in count:
		if deck.is_empty():
			if discard_pile.is_empty():
				break
			shuffle_discard_into_deck()
		if not deck.is_empty():
			hand.append(deck.pop_back())
	hand_changed.emit()

func shuffle_discard_into_deck() -> void:
	deck.append_array(discard_pile)
	discard_pile.clear()
	_shuffle_deck()
	deck_changed.emit()

func can_pay_toll(card: CardData, character: CharacterData) -> bool:
	match card.toll_type:
		CardData.TollType.FREE:
			return true
		CardData.TollType.HP:
			return character.current_hp >= card.toll_value
		CardData.TollType.MOMENTUM:
			return character.momentum >= card.toll_value
		CardData.TollType.DISCARD:
			return hand.size() > card.toll_value
		_:
			return false

func pay_toll(card: CardData, character: CharacterData) -> void:
	match card.toll_type:
		CardData.TollType.FREE:
			pass
		CardData.TollType.HP:
			character.receive_damage(card.toll_value)
			character_hp_changed.emit(character.character_id, character.current_hp)
		CardData.TollType.MOMENTUM:
			character.spend_momentum(card.toll_value)
		CardData.TollType.DISCARD:
			for _i in card.toll_value:
				var candidates: Array[int] = []
				for j in hand.size():
					if hand[j] != card:
						candidates.append(j)
				if candidates.is_empty():
					break
				var pick: int = rng.randi_range(0, candidates.size() - 1)
				discard_pile.append(hand[candidates[pick]])
				hand.remove_at(candidates[pick])

func play_card(card: CardData, character: CharacterData, target: Object) -> void:
	var card_idx: int = hand.find(card)
	if card_idx == -1:
		return
	if not can_pay_toll(card, character):
		return
	pay_toll(card, character)
	hand.remove_at(hand.find(card))
	for effect: CardEffect in card.effects:
		effect.execute(character, target, self)
	discard_pile.append(card)
	hand_changed.emit()

func _shuffle_deck() -> void:
	for i in range(deck.size() - 1, 0, -1):
		var j: int = rng.randi_range(0, i)
		var temp: CardData = deck[i]
		deck[i] = deck[j]
		deck[j] = temp
