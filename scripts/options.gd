extends Control

const CHAOS_TIMER_STEP := 5.0

const EFFECT_LABELS := {
	"double_speed": "Double Speed",
	"split": "Ball Split",
	"swap": "Paddle Swap",
	"third_fourth": "3rd/4th Paddles",
	"projectiles": "Projectiles",
	"double_points": "Double Points",
	"shrink_paddles": "Shrink Paddles",
	"obstructions": "Falling Obstructions",
	"spin": "Ball Spin",
}

@onready var settings_list: VBoxContainer = $Center/SettingsList
@onready var back_btn: Button = $Center/Buttons/BackButton


func _ready() -> void:
	_add_chaos_timer_row()
	for key in GameState.CHAOS_EFFECT_KEYS:
		_add_effect_row(key)

	back_btn.pressed.connect(_go_back)
	back_btn.grab_focus()


func _add_chaos_timer_row() -> void:
	var row := HBoxContainer.new()

	var label := Label.new()
	label.text = "Chaos Timer (s)"
	label.custom_minimum_size = Vector2(350, 0)

	var spinbox := SpinBox.new()
	spinbox.min_value = GameState.MIN_CHAOS_INTERVAL
	spinbox.max_value = GameState.MAX_CHAOS_INTERVAL
	spinbox.step = CHAOS_TIMER_STEP
	spinbox.value = GameState.chaos_interval
	spinbox.custom_minimum_size = Vector2(150, 0)
	spinbox.value_changed.connect(_on_chaos_timer_changed)

	row.add_child(label)
	row.add_child(spinbox)
	settings_list.add_child(row)


func _add_effect_row(key: String) -> void:
	var row := HBoxContainer.new()

	var label := Label.new()
	label.text = EFFECT_LABELS.get(key, key)
	label.custom_minimum_size = Vector2(350, 0)

	var toggle := CheckButton.new()
	toggle.button_pressed = GameState.enabled_chaos_effects.get(key, true)
	toggle.toggled.connect(_on_effect_toggled.bind(key))

	row.add_child(label)
	row.add_child(toggle)
	settings_list.add_child(row)


func _on_chaos_timer_changed(value: float) -> void:
	GameState.chaos_interval = value


func _on_effect_toggled(pressed: bool, key: String) -> void:
	GameState.enabled_chaos_effects[key] = pressed


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_go_back()


func _go_back() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
