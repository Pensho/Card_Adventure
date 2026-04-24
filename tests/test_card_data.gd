extends GutTest


func test_card_data_default_values() -> void:
	var card := CardData.new()
	assert_eq(card.card_name, "")
	assert_eq(card.toll_type, CardData.TollType.FREE)
	assert_eq(card.toll_value, 0)
	assert_false(card.is_curse)
	assert_true(card.effects.is_empty())


func test_damage_effect_reduces_target_hp() -> void:
	var effect := DamageEffect.new()
	effect.value = 6
	var target := EnemyCombatData.new()
	target.current_hp = 20
	effect.execute(null, target, null)
	assert_eq(target.current_hp, 14)


func test_damage_effect_cannot_reduce_below_zero() -> void:
	var effect := DamageEffect.new()
	effect.value = 100
	var target := EnemyCombatData.new()
	target.current_hp = 10
	effect.execute(null, target, null)
	assert_eq(target.current_hp, 0)


func test_damage_effect_on_null_target_does_not_crash() -> void:
	var effect := DamageEffect.new()
	effect.value = 5
	effect.execute(null, null, null)
	pass_test("No crash on null target")


func test_character_state_becomes_wounded_after_damage() -> void:
	var char := CharacterData.new()
	char.current_hp = 50
	char.character_state = CharacterData.CharacterState.COILED
	char.receive_damage(10)
	assert_eq(char.character_state, CharacterData.CharacterState.WOUNDED)


func test_character_state_unchanged_when_damage_downs() -> void:
	var char := CharacterData.new()
	char.current_hp = 5
	char.character_state = CharacterData.CharacterState.COMMITTED
	char.receive_damage(10)
	assert_true(char.is_downed())
	assert_eq(char.character_state, CharacterData.CharacterState.COMMITTED)


func test_character_heal_restores_hp() -> void:
	var char := CharacterData.new()
	char.max_hp = 50
	char.current_hp = 20
	char.heal(15)
	assert_eq(char.current_hp, 35)


func test_character_heal_does_not_exceed_max_hp() -> void:
	var char := CharacterData.new()
	char.max_hp = 50
	char.current_hp = 45
	char.heal(20)
	assert_eq(char.current_hp, 50)


func test_character_not_downed_at_positive_hp() -> void:
	var char := CharacterData.new()
	char.current_hp = 1
	assert_false(char.is_downed())


func test_character_downed_at_zero_hp() -> void:
	var char := CharacterData.new()
	char.current_hp = 0
	assert_true(char.is_downed())


func test_momentum_spend_succeeds_when_sufficient() -> void:
	var char := CharacterData.new()
	char.momentum = 3
	var result := char.spend_momentum(2)
	assert_true(result)
	assert_eq(char.momentum, 1)


func test_momentum_spend_fails_when_insufficient() -> void:
	var char := CharacterData.new()
	char.momentum = 1
	var result := char.spend_momentum(3)
	assert_false(result)
	assert_eq(char.momentum, 1)


func test_momentum_add_increases_momentum() -> void:
	var char := CharacterData.new()
	char.momentum = 2
	char.add_momentum(3)
	assert_eq(char.momentum, 5)


func test_enemy_combat_data_defaults() -> void:
	var enemy := EnemyCombatData.new()
	assert_false(enemy.is_downed())
	assert_eq(enemy.intent_type, EnemyCombatData.IntentType.ATTACK)


func test_enemy_receives_damage() -> void:
	var enemy := EnemyCombatData.new()
	enemy.current_hp = 30
	enemy.receive_damage(12)
	assert_eq(enemy.current_hp, 18)
	assert_false(enemy.is_downed())


func test_enemy_downed_when_hp_reaches_zero() -> void:
	var enemy := EnemyCombatData.new()
	enemy.current_hp = 5
	enemy.receive_damage(5)
	assert_true(enemy.is_downed())
