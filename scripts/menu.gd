extends Control

@onready var single_player_btn: Button = $Center/Buttons/SinglePlayerButton
@onready var two_player_btn: Button = $Center/Buttons/TwoPlayerButton
@onready var options_btn: Button = $Center/Buttons/OptionsButton


func _ready() -> void:
	single_player_btn.pressed.connect(func(): _start_game(false))
	two_player_btn.pressed.connect(func(): _start_game(true))
	options_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/options.tscn"))
	single_player_btn.grab_focus()


func _start_game(two_player: bool) -> void:
	GameState.two_player = two_player
	get_tree().change_scene_to_file("res://scenes/game.tscn")
