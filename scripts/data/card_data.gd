class_name CardData
extends Resource

enum TollType {
	FREE,
	HP,
	EXHAUST,
	DISCARD,
	WOUND,
	MOMENTUM,
	PERFORMANCE,
	STATE,
}

@export var card_name: String = ""
@export var description: String = ""
@export var toll_type: TollType = TollType.FREE
@export var toll_value: int = 0
@export var effects: Array[CardEffect] = []
@export var is_curse: bool = false
@export var character_class: String = ""
