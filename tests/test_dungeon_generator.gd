extends GutTest

const DungeonGenerator := preload("res://scripts/game/dungeon_generator.gd")

func _make_rng(seed_val: int) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_val
	return rng


# --- passage count ---

func test_junction_returns_three_or_four_passages():
	for trial in 20:
		var rng := _make_rng(trial * 1337)
		var passages := DungeonGenerator.generate_junction(rng, 1)
		assert_true(passages.size() >= 3 and passages.size() <= 4,
			"Expected 3-4 passages (2-3 normal + 1 sentinel), got %d" % passages.size())


# --- corridor length ---

func test_corridor_length_is_between_two_and_four():
	for trial in 20:
		var rng := _make_rng(trial * 999)
		var passages := DungeonGenerator.generate_junction(rng, 1)
		for passage in passages:
			var rooms: Array = passage["rooms"]
			# Sentinel passage has exactly 1 room — skip the length check for it.
			if rooms.size() == 1 and rooms[0].get("is_sentinel", false):
				continue
			assert_true(rooms.size() >= 2 and rooms.size() <= 4,
				"Expected corridor length 2-4, got %d" % rooms.size())


# --- last room always ENCOUNTER ---

func test_last_room_in_corridor_is_always_encounter():
	for trial in 30:
		var rng := _make_rng(trial * 42)
		var passages := DungeonGenerator.generate_junction(rng, 1)
		for passage in passages:
			var rooms: Array = passage["rooms"]
			assert_eq(rooms[rooms.size() - 1]["type"], DungeonGenerator.ROOM_ENCOUNTER,
				"Last room must be ENCOUNTER")


# --- determinism ---

func test_same_seed_produces_same_junction():
	var rng_a := _make_rng(12345)
	var rng_b := _make_rng(12345)
	var passages_a := DungeonGenerator.generate_junction(rng_a, 1)
	var passages_b := DungeonGenerator.generate_junction(rng_b, 1)
	assert_eq(passages_a.size(), passages_b.size())
	for i in passages_a.size():
		var rooms_a: Array = passages_a[i]["rooms"]
		var rooms_b: Array = passages_b[i]["rooms"]
		assert_eq(rooms_a.size(), rooms_b.size())
		for j in rooms_a.size():
			assert_eq(rooms_a[j]["type"], rooms_b[j]["type"])


# --- hint text ---

func test_each_passage_has_non_empty_hint():
	var rng := _make_rng(777)
	var passages := DungeonGenerator.generate_junction(rng, 1)
	for passage in passages:
		assert_true(passage["hint"].length() > 0)


# --- sentinel passage ---

func test_junction_includes_exactly_one_sentinel_passage():
	for trial in 10:
		var rng := _make_rng(trial * 77)
		var passages := DungeonGenerator.generate_junction(rng, 1)
		var sentinel_count := 0
		for passage in passages:
			for room in passage["rooms"]:
				if room.get("is_sentinel", false):
					sentinel_count += 1
		assert_eq(sentinel_count, 1, "Expected exactly 1 sentinel room")


func test_sentinel_passage_has_single_room():
	var rng := _make_rng(12345)
	var passages := DungeonGenerator.generate_junction(rng, 1)
	for passage in passages:
		var rooms: Array = passage["rooms"]
		if rooms.size() == 1 and rooms[0].get("is_sentinel", false):
			assert_eq(rooms.size(), 1)
			return
	fail_test("No sentinel passage found")


func test_standard_encounter_rooms_have_enemies_array():
	var rng := _make_rng(42)
	var passages := DungeonGenerator.generate_junction(rng, 1)
	for passage in passages:
		for room in passage["rooms"]:
			if room["type"] == DungeonGenerator.ROOM_ENCOUNTER:
				assert_true(room.has("enemies"), "ENCOUNTER room missing enemies key")
				assert_false((room["enemies"] as Array).is_empty(), "ENCOUNTER room has no enemies")


# --- room types are valid ---

func test_all_room_types_are_valid():
	var valid := [DungeonGenerator.ROOM_ENCOUNTER, DungeonGenerator.ROOM_RESPITE, DungeonGenerator.ROOM_EMPTY]
	for trial in 10:
		var rng := _make_rng(trial * 555)
		var passages := DungeonGenerator.generate_junction(rng, 1)
		for passage in passages:
			for room in passage["rooms"]:
				assert_true(room["type"] in valid, "Unknown room type: %s" % room["type"])
