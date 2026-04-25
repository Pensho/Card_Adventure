extends Control

const LANCER_HP: int = 50
const JESTER_HP: int = 50


func _on_descend_button_pressed() -> void:
	var lancer := CharacterData.new()
	lancer.character_id = "lancer"
	lancer.character_name = "Lancer"
	lancer.max_hp = LANCER_HP
	lancer.current_hp = LANCER_HP

	var jester := CharacterData.new()
	jester.character_id = "jester"
	jester.character_name = "Jester"
	jester.max_hp = JESTER_HP
	jester.current_hp = JESTER_HP

	GameState.equip_item(lancer, ItemData.SlotType.WEAPON,
			load("res://data/items/lancer_iron_lance.tres"))
	GameState.equip_item(lancer, ItemData.SlotType.OFF_HAND,
			load("res://data/items/lancer_battered_shield.tres"))
	GameState.equip_item(jester, ItemData.SlotType.WEAPON,
			load("res://data/items/jester_motley_blade.tres"))
	GameState.equip_item(jester, ItemData.SlotType.ACCESSORY,
			load("res://data/items/jester_bells.tres"))
	GameState.start_run([lancer, jester])
	SceneManager.go_to("res://scenes/game/DungeonJunction.tscn")
