extends GutTest

const ItemData := preload("res://scripts/data/item_data.gd")

# --- helpers ---

func _make_card(card_name: String) -> CardData:
	var c := CardData.new()
	c.card_name = card_name
	return c

func _make_item(id: String, slot: ItemData.SlotType, card_names: Array, curse_names: Array = []) -> ItemData:
	var item := ItemData.new()
	item.item_id = id
	item.item_name = id
	item.slot_type = slot
	for n in card_names:
		item.cards.append(_make_card(n))
	for n in curse_names:
		var curse := _make_card(n)
		curse.is_curse = true
		item.curse_cards.append(curse)
	return item

func _make_character() -> CharacterData:
	var character := CharacterData.new()
	character.character_id = "test_char"
	return character

# --- ItemData ---

func test_item_defaults():
	var item := ItemData.new()
	assert_eq(item.item_id, "")
	assert_eq(item.rarity, ItemData.Rarity.STANDARD)
	assert_eq(item.cards.size(), 0)
	assert_eq(item.curse_cards.size(), 0)

func test_item_slot_types_exist():
	assert_true(ItemData.SlotType.has("WEAPON"))
	assert_true(ItemData.SlotType.has("OFF_HAND"))
	assert_true(ItemData.SlotType.has("ARMOUR"))
	assert_true(ItemData.SlotType.has("ACCESSORY"))

# --- CharacterData.get_all_cards() ---

func test_get_all_cards_empty_equipment():
	var character := _make_character()
	assert_eq(character.get_all_cards().size(), 0)

func test_get_all_cards_single_item():
	var character := _make_character()
	var item := _make_item("sword", ItemData.SlotType.WEAPON, ["Strike", "Lunge"])
	character.equipment[ItemData.SlotType.WEAPON] = item
	var cards := character.get_all_cards()
	assert_eq(cards.size(), 2)
	assert_eq(cards[0].card_name, "Strike")
	assert_eq(cards[1].card_name, "Lunge")

func test_get_all_cards_includes_curse_cards():
	var character := _make_character()
	var item := _make_item("cursed_blade", ItemData.SlotType.WEAPON, ["Power Strike"], ["Wound"])
	character.equipment[ItemData.SlotType.WEAPON] = item
	var cards := character.get_all_cards()
	assert_eq(cards.size(), 2)
	var names := cards.map(func(c): return c.card_name)
	assert_true("Power Strike" in names)
	assert_true("Wound" in names)

func test_get_all_cards_multiple_slots():
	var character := _make_character()
	character.equipment[ItemData.SlotType.WEAPON] = _make_item("w", ItemData.SlotType.WEAPON, ["A", "B"])
	character.equipment[ItemData.SlotType.ARMOUR] = _make_item("a", ItemData.SlotType.ARMOUR, ["C"])
	assert_eq(character.get_all_cards().size(), 3)

func test_get_all_cards_skips_null_slots():
	var character := _make_character()
	character.equipment[ItemData.SlotType.WEAPON] = null
	character.equipment[ItemData.SlotType.ARMOUR] = _make_item("shield", ItemData.SlotType.ARMOUR, ["Block"])
	var cards := character.get_all_cards()
	assert_eq(cards.size(), 1)
	assert_eq(cards[0].card_name, "Block")

func test_unequipping_sets_null():
	var character := _make_character()
	var item := _make_item("w", ItemData.SlotType.WEAPON, ["Strike"])
	character.equipment[ItemData.SlotType.WEAPON] = item
	character.equipment[ItemData.SlotType.WEAPON] = null
	assert_eq(character.get_all_cards().size(), 0)
