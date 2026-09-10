extends GutTest

var OptionsScene := preload("res://scenes/options.tscn")


func before_each() -> void:
	GameState.chaos_interval = GameState.DEFAULT_CHAOS_INTERVAL
	for key in GameState.CHAOS_EFFECT_KEYS:
		GameState.enabled_chaos_effects[key] = true


func test_chaos_timer_spinbox_defaults_to_game_state_value() -> void:
	GameState.chaos_interval = 45.0
	var options = OptionsScene.instantiate()
	add_child_autofree(options)
	var spinbox: SpinBox = options.settings_list.get_child(0).get_child(1)
	assert_eq(spinbox.value, 45.0)


func test_spinbox_min_max_match_game_state_bounds() -> void:
	var options = OptionsScene.instantiate()
	add_child_autofree(options)
	var spinbox: SpinBox = options.settings_list.get_child(0).get_child(1)
	assert_eq(spinbox.min_value, GameState.MIN_CHAOS_INTERVAL)
	assert_eq(spinbox.max_value, GameState.MAX_CHAOS_INTERVAL)


func test_on_chaos_timer_changed_updates_game_state() -> void:
	var options = OptionsScene.instantiate()
	add_child_autofree(options)
	options._on_chaos_timer_changed(50.0)
	assert_eq(GameState.chaos_interval, 50.0)


func test_effect_rows_default_to_game_state_enabled_flags() -> void:
	GameState.enabled_chaos_effects["split"] = false
	var options = OptionsScene.instantiate()
	add_child_autofree(options)
	# Row 0 is the chaos timer; effect rows follow in GameState.CHAOS_EFFECT_KEYS order.
	var split_index := GameState.CHAOS_EFFECT_KEYS.find("split") + 1
	var toggle: CheckButton = options.settings_list.get_child(split_index).get_child(1)
	assert_false(toggle.button_pressed)


func test_on_effect_toggled_updates_game_state() -> void:
	var options = OptionsScene.instantiate()
	add_child_autofree(options)
	options._on_effect_toggled(false, "swap")
	assert_false(GameState.enabled_chaos_effects["swap"])
	options._on_effect_toggled(true, "swap")
	assert_true(GameState.enabled_chaos_effects["swap"])
