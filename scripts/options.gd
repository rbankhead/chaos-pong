extends Control

@onready var back_btn: Button = $Center/Buttons/BackButton


func _ready() -> void:
	back_btn.pressed.connect(_go_back)
	back_btn.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_go_back()


func _go_back() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
