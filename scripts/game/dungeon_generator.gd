class_name DungeonGenerator

const ROOM_ENCOUNTER := "ENCOUNTER"
const ROOM_RESPITE   := "RESPITE"
const ROOM_EMPTY     := "EMPTY"

# Room weights for depth 1 (indices map to: ENCOUNTER, RESPITE, EMPTY).
const _WEIGHTS_D1 := [60, 25, 15]
const _TYPES      := [ROOM_ENCOUNTER, ROOM_RESPITE, ROOM_EMPTY]

# Atmospheric hint text keyed by the dominant room type in a corridor.
const _HINTS := {
	ROOM_ENCOUNTER: [
		"Something moves in the dark ahead. The air smells of old iron.",
		"Scratching sounds, close. The passage narrows.",
		"The torchlight ahead is wrong — it does not flicker.",
	],
	ROOM_RESPITE: [
		"A stillness here that does not match the rest. The stone is dry.",
		"Faint warmth. The air is less wrong than it has been.",
		"The sound of the dungeon recedes. Not gone — just quieter.",
	],
	ROOM_EMPTY: [
		"Nothing waits here. That should be a relief.",
		"The passage opens into a chamber that offers nothing. Nor takes anything.",
		"Dust undisturbed for longer than it should be.",
	],
}


static func generate_junction(rng: RandomNumberGenerator, _depth: int) -> Array[Dictionary]:
	var passage_count: int = rng.randi_range(2, 3)
	var passages: Array[Dictionary] = []
	for _i in passage_count:
		var rooms := _generate_corridor(rng)
		var hint  := _pick_hint(rng, rooms)
		passages.append({"hint": hint, "rooms": rooms})
	return passages


static func _generate_corridor(rng: RandomNumberGenerator) -> Array[Dictionary]:
	var length: int = rng.randi_range(2, 4)
	var rooms: Array[Dictionary] = []
	for i in length:
		var room_type: String
		if i == length - 1:
			room_type = ROOM_ENCOUNTER
		else:
			room_type = _weighted_pick(rng, _TYPES, _WEIGHTS_D1)
		rooms.append({"type": room_type})
	return rooms


static func _weighted_pick(rng: RandomNumberGenerator, types: Array, weights: Array) -> String:
	var total: int = 0
	for w in weights:
		total += w
	var roll: int = rng.randi_range(0, total - 1)
	var cumulative: int = 0
	for i in types.size():
		cumulative += weights[i]
		if roll < cumulative:
			return types[i]
	return types[types.size() - 1]


static func _pick_hint(rng: RandomNumberGenerator, rooms: Array[Dictionary]) -> String:
	var counts := {ROOM_ENCOUNTER: 0, ROOM_RESPITE: 0, ROOM_EMPTY: 0}
	for room in rooms:
		counts[room["type"]] += 1
	var dominant: String = ROOM_ENCOUNTER
	var max_count: int = 0
	for t in counts:
		if counts[t] > max_count:
			max_count = counts[t]
			dominant = t
	var options: Array = _HINTS[dominant]
	return options[rng.randi_range(0, options.size() - 1)]
