class_name ItemData
extends Resource

enum SlotType {
	WEAPON,
	OFF_HAND,
	ARMOUR,
	ACCESSORY,
}

enum Rarity {
	STANDARD,
	CURSED,
	ELDRITCH,
}

@export var item_id: String = ""
@export var item_name: String = ""
@export var description: String = ""
@export var slot_type: SlotType = SlotType.WEAPON
@export var rarity: Rarity = Rarity.STANDARD
@export var cards: Array[CardData] = []
@export var curse_cards: Array[CardData] = []
