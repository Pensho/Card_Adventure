extends Node

const SAVE_VERSION    := 1
const SAVE_PATH       := "user://savegame.json"
const PERSISTENT_PATH := "user://persistent.json"

signal hand_changed
signal deck_changed
signal character_hp_changed(character_id: String, new_hp: int)
signal equipment_changed(character_id: String)

var party: Array[CharacterData] = []
var deck: Array[CardData] = []
var hand: Array[CardData] = []
var discard_pile: Array[CardData] = []
var exhaust_pile: Array[CardData] = []
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var run_seed: int = 0

# Dungeon state
var current_depth: int = 1
var corridor_rooms: Array[Dictionary] = []
var room_index: int = 0
var pending_loot: Array = []  # Array[ItemData]

# Persistent cross-run state
var unlocked_characters: Array[String] = ["lancer", "jester"]

func start_run(characters: Array[CharacterData]) -> void:
	party = characters
	run_seed = rng.randi()
	rng.seed = run_seed
	current_depth = 1
	corridor_rooms = []
	room_index = 0
	pending_loot = []
	hand = []
	discard_pile = []
	exhaust_pile = []
	_rebuild_deck()

func start_combat(characters: Array[CharacterData], starting_deck: Array[CardData]) -> void:
	party = characters
	deck = starting_deck.duplicate()
	hand = []
	discard_pile = []
	exhaust_pile = []
	_shuffle_deck()

func equip_item(character: CharacterData, slot: int, item) -> void:
	character.equipment[slot] = item
	_rebuild_deck()
	equipment_changed.emit(character.character_id)

func unequip_item(character: CharacterData, slot: int) -> void:
	character.equipment[slot] = null
	_rebuild_deck()
	equipment_changed.emit(character.character_id)

func rebuild_deck() -> void:
	_rebuild_deck()


func remove_character_cards_from_combat(character: CharacterData) -> void:
	deck = deck.filter(func(c: CardData) -> bool: return c.character_class != character.character_id)
	hand = hand.filter(func(c: CardData) -> bool: return c.character_class != character.character_id)
	discard_pile = discard_pile.filter(func(c: CardData) -> bool: return c.character_class != character.character_id)
	hand_changed.emit()
	deck_changed.emit()


func _rebuild_deck() -> void:
	var all_cards: Array[CardData] = []
	for character in party:
		all_cards.append_array(character.get_all_cards())
	deck = all_cards
	_shuffle_deck()
	deck_changed.emit()

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

func _coiled_toll(card: CardData, character: CharacterData) -> int:
	if character.character_state == CharacterData.CharacterState.COILED:
		match card.toll_type:
			CardData.TollType.HP, CardData.TollType.MOMENTUM:
				return max(0, card.toll_value - 1)
	return card.toll_value

func can_pay_toll(card: CardData, character: CharacterData) -> bool:
	var toll: int = _coiled_toll(card, character)
	match card.toll_type:
		CardData.TollType.FREE:
			return true
		CardData.TollType.HP:
			return character.current_hp >= toll
		CardData.TollType.MOMENTUM:
			return character.momentum >= toll
		CardData.TollType.PERFORMANCE:
			return character.performance >= toll
		CardData.TollType.DISCARD:
			return hand.size() > card.toll_value
		_:
			return false

func pay_toll(card: CardData, character: CharacterData) -> void:
	var toll: int = _coiled_toll(card, character)
	match card.toll_type:
		CardData.TollType.FREE:
			pass
		CardData.TollType.HP:
			character.receive_damage(toll)
			character_hp_changed.emit(character.character_id, character.current_hp)
		CardData.TollType.MOMENTUM:
			character.spend_momentum(toll)
		CardData.TollType.PERFORMANCE:
			character.spend_performance(toll)
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
	if character.character_state == CharacterData.CharacterState.COILED:
		character.character_state = CharacterData.CharacterState.NONE
	hand.remove_at(hand.find(card))
	for effect: CardEffect in card.effects:
		effect.execute(character, target, self)
	if card.is_aggressive:
		character.character_state = CharacterData.CharacterState.COMMITTED
	elif card.is_defensive:
		character.character_state = CharacterData.CharacterState.BRACED
	discard_pile.append(card)
	hand_changed.emit()

func _shuffle_deck() -> void:
	for i in range(deck.size() - 1, 0, -1):
		var j: int = rng.randi_range(0, i)
		var temp: CardData = deck[i]
		deck[i] = deck[j]
		deck[j] = temp


# --- persistence ---

func save_run() -> void:
	var data := {
		"version":        SAVE_VERSION,
		"rng_seed":       rng.seed,
		"rng_state":      rng.state,
		"depth":          current_depth,
		"corridor_rooms": corridor_rooms,
		"room_index":     room_index,
		"pending_loot":   _serialize_item_array(pending_loot),
		"party":          _serialize_party(),
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t"))
	file.close()


func load_run() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var text := file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(text)
	if parsed == null:
		return false
	if not parsed.has("version") or parsed["version"] != SAVE_VERSION:
		return false
	rng.seed  = parsed["rng_seed"]
	rng.state = parsed["rng_state"]
	current_depth   = parsed["depth"]
	corridor_rooms.assign(parsed["corridor_rooms"])
	room_index      = parsed["room_index"]
	pending_loot    = _deserialize_item_array(parsed["pending_loot"])
	_deserialize_party(parsed["party"])
	_rebuild_deck()
	return true


func clear_run() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var dir := DirAccess.open("user://")
		dir.remove("savegame.json")


func save_persistent() -> void:
	var data := {
		"version":              SAVE_VERSION,
		"unlocked_characters":  unlocked_characters,
	}
	var file := FileAccess.open(PERSISTENT_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t"))
	file.close()


func load_persistent() -> void:
	if not FileAccess.file_exists(PERSISTENT_PATH):
		return
	var file := FileAccess.open(PERSISTENT_PATH, FileAccess.READ)
	var text := file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(text)
	if parsed == null or not parsed.has("version") or parsed["version"] != SAVE_VERSION:
		return
	unlocked_characters.assign(parsed["unlocked_characters"])


func _serialize_party() -> Array:
	var result := []
	for pc: CharacterData in party:
		var equip_data := {}
		for slot in pc.equipment:
			var item = pc.equipment[slot]
			equip_data[str(slot)] = item.resource_path if item != null else ""
		result.append({
			"id":      pc.character_id,
			"name":    pc.character_name,
			"max_hp":  pc.max_hp,
			"hp":      pc.current_hp,
			"equipment": equip_data,
		})
	return result


func _deserialize_party(data: Array) -> void:
	party.clear()
	for pc_data in data:
		var pc := CharacterData.new()
		pc.character_id   = pc_data["id"]
		pc.character_name = pc_data["name"]
		pc.max_hp         = pc_data["max_hp"]
		pc.current_hp     = pc_data["hp"]
		var equip: Dictionary = pc_data["equipment"]
		for slot_str in equip:
			var path: String = equip[slot_str]
			pc.equipment[int(slot_str)] = load(path) if path != "" else null
		party.append(pc)


func _serialize_item_array(items: Array) -> Array:
	var result := []
	for item in items:
		if item != null and item.resource_path != "":
			result.append(item.resource_path)
	return result


func _deserialize_item_array(paths: Array) -> Array:
	var result := []
	for path in paths:
		if path != null and path != "":
			result.append(load(path))
	return result
