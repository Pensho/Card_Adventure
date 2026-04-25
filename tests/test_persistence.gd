extends GutTest

const GameStateScript := preload("res://scripts/game/game_state.gd")

var _state: Node


func before_each() -> void:
	_state = GameStateScript.new()
	add_child(_state)
	_state.clear_run()


func after_each() -> void:
	_state.clear_run()
	_state.queue_free()
	_state = null


func _make_character(id: String, hp: int = 50) -> CharacterData:
	var pc := CharacterData.new()
	pc.character_id   = id
	pc.character_name = id
	pc.max_hp         = hp
	pc.current_hp     = hp
	return pc


# --- load_run with no file ---

func test_load_run_returns_false_when_no_save_exists() -> void:
	assert_false(_state.load_run())


# --- basic roundtrip ---

func test_save_and_load_preserves_depth() -> void:
	var chars: Array[CharacterData] = [_make_character("lancer")]
	_state.start_run(chars)
	_state.current_depth = 3
	_state.save_run()
	_state.current_depth = 1
	assert_true(_state.load_run())
	assert_eq(_state.current_depth, 3)


func test_save_and_load_preserves_room_index() -> void:
	var chars: Array[CharacterData] = [_make_character("lancer")]
	_state.start_run(chars)
	_state.corridor_rooms.assign([{"type": "ENCOUNTER"}, {"type": "RESPITE"}])
	_state.room_index = 1
	_state.save_run()
	_state.room_index = 0
	assert_true(_state.load_run())
	assert_eq(_state.room_index, 1)


func test_save_and_load_preserves_party_hp() -> void:
	var pc := _make_character("lancer", 50)
	var chars: Array[CharacterData] = [pc]
	_state.start_run(chars)
	_state.party[0].current_hp = 27
	_state.save_run()
	_state.party[0].current_hp = 50
	assert_true(_state.load_run())
	assert_eq(_state.party[0].current_hp, 27)


func test_save_and_load_preserves_party_size() -> void:
	var chars: Array[CharacterData] = [_make_character("lancer"), _make_character("jester")]
	_state.start_run(chars)
	_state.save_run()
	_state.party.clear()
	assert_true(_state.load_run())
	assert_eq(_state.party.size(), 2)


func test_save_and_load_preserves_corridor_rooms() -> void:
	var chars: Array[CharacterData] = [_make_character("lancer")]
	_state.start_run(chars)
	_state.corridor_rooms.assign([{"type": "ENCOUNTER"}, {"type": "RESPITE"}, {"type": "EMPTY"}])
	_state.save_run()
	_state.corridor_rooms.clear()
	assert_true(_state.load_run())
	assert_eq(_state.corridor_rooms.size(), 3)
	assert_eq(_state.corridor_rooms[1]["type"], "RESPITE")


# --- version mismatch ---

func test_load_run_returns_false_on_version_mismatch() -> void:
	var chars: Array[CharacterData] = [_make_character("lancer")]
	_state.start_run(chars)
	_state.save_run()
	# Overwrite with a different version number.
	var file := FileAccess.open("user://savegame.json", FileAccess.WRITE)
	file.store_string('{"version": 999, "depth": 1}')
	file.close()
	assert_false(_state.load_run())


# --- clear_run ---

func test_clear_run_removes_save_file() -> void:
	var chars: Array[CharacterData] = [_make_character("lancer")]
	_state.start_run(chars)
	_state.save_run()
	assert_true(FileAccess.file_exists("user://savegame.json"))
	_state.clear_run()
	assert_false(FileAccess.file_exists("user://savegame.json"))


func test_clear_run_is_safe_when_no_file() -> void:
	assert_false(FileAccess.file_exists("user://savegame.json"))
	_state.clear_run()  # Should not crash.
	assert_true(true)
