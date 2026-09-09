extends Node2D

@onready var left_paddle: Paddle = $LeftPaddle
@onready var right_paddle: Paddle = $RightPaddle
@onready var ball: Ball = $Ball
@onready var left_score_label: Label = $UI/LeftScore
@onready var right_score_label: Label = $UI/RightScore

var left_score := 0
var right_score := 0


func _ready() -> void:
	right_paddle.is_ai = not GameState.two_player
	if right_paddle.is_ai:
		right_paddle.ai_target = ball
	ball.scored.connect(_on_scored)
	_update_score_labels()


func _process(_delta: float) -> void:
	if ball.velocity.x < 0.0 and ball.get_rect().intersects(left_paddle.get_rect()):
		ball.bounce_off_paddle(left_paddle.get_rect(), true)
	elif ball.velocity.x > 0.0 and ball.get_rect().intersects(right_paddle.get_rect()):
		ball.bounce_off_paddle(right_paddle.get_rect(), false)


func _on_scored(scorer: int) -> void:
	if scorer == 1:
		left_score += 1
		ball.reset(1)
	else:
		right_score += 1
		ball.reset(-1)
	_update_score_labels()


func _update_score_labels() -> void:
	left_score_label.text = str(left_score)
	right_score_label.text = str(right_score)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://scenes/menu.tscn")
