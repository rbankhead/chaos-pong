extends Node2D

const CHAOS_FIRST_DELAY := 30.0
const CHAOS_INTERVAL := 30.0

@onready var left_paddle: Paddle = $LeftPaddle
@onready var right_paddle: Paddle = $RightPaddle
@onready var left_score_label: Label = $UI/LeftScore
@onready var right_score_label: Label = $UI/RightScore

var balls: Array[Ball] = []
var edge_paddles: Array[EdgePaddle] = []
var third_fourth_active := false

var left_score := 0
var right_score := 0

var chaos_pool := ["double_speed", "split", "swap", "third_fourth"]
var chaos_timer := 0.0
var next_chaos_time := CHAOS_FIRST_DELAY


func _ready() -> void:
	right_paddle.is_ai = not GameState.two_player
	if right_paddle.is_ai:
		right_paddle.ai_target = $Ball
	_register_ball($Ball)
	_update_score_labels()


func _process(delta: float) -> void:
	chaos_timer += delta
	if chaos_timer >= next_chaos_time and not chaos_pool.is_empty():
		next_chaos_time += CHAOS_INTERVAL
		_trigger_random_chaos()

	for ball in balls:
		if ball.velocity.x < 0.0 and ball.get_rect().intersects(left_paddle.get_rect()):
			ball.bounce_off_paddle(left_paddle.get_rect(), true)
		elif ball.velocity.x > 0.0 and ball.get_rect().intersects(right_paddle.get_rect()):
			ball.bounce_off_paddle(right_paddle.get_rect(), false)

		if third_fourth_active:
			for edge in edge_paddles:
				if edge.is_top and ball.velocity.y < 0.0 and ball.get_rect().intersects(edge.get_rect()):
					ball.bounce_off_horizontal_paddle(edge.get_rect(), true)
				elif not edge.is_top and ball.velocity.y > 0.0 and ball.get_rect().intersects(edge.get_rect()):
					ball.bounce_off_horizontal_paddle(edge.get_rect(), false)


func _register_ball(ball: Ball) -> void:
	balls.append(ball)
	ball.scored.connect(_on_scored.bind(ball))


func _on_scored(scorer: int, ball: Ball) -> void:
	if scorer == 1:
		left_score += 1
	else:
		right_score += 1

	if ball.is_split_clone:
		balls.erase(ball)
		ball.queue_free()
	elif scorer == 1:
		ball.reset(1)
	else:
		ball.reset(-1)

	_update_score_labels()


func _update_score_labels() -> void:
	left_score_label.text = str(left_score)
	right_score_label.text = str(right_score)


func _trigger_random_chaos() -> void:
	var effect: String = chaos_pool.pick_random()
	chaos_pool.erase(effect)
	match effect:
		"double_speed":
			_apply_double_speed()
		"split":
			_apply_split()
		"swap":
			_apply_swap()
		"third_fourth":
			_apply_third_fourth()


func _apply_double_speed() -> void:
	for ball in balls:
		ball.speed_scale *= 2.0
		ball.velocity *= 2.0


func _apply_split() -> void:
	var existing := balls.duplicate()
	for ball in existing:
		for i in range(3):
			var clone: Ball = preload("res://scenes/ball.tscn").instantiate()
			add_child(clone)
			clone.speed_scale = ball.speed_scale
			clone.is_split_clone = true
			clone.position = ball.position
			var angle := (i + 1) * (PI / 2.0)
			clone.velocity = ball.velocity.rotated(angle)
			_register_ball(clone)


func _apply_swap() -> void:
	var swap_player := left_paddle.player
	var swap_is_ai := left_paddle.is_ai
	var swap_ai_target := left_paddle.ai_target
	left_paddle.player = right_paddle.player
	left_paddle.is_ai = right_paddle.is_ai
	left_paddle.ai_target = right_paddle.ai_target
	right_paddle.player = swap_player
	right_paddle.is_ai = swap_is_ai
	right_paddle.ai_target = swap_ai_target
	left_paddle.queue_redraw()
	right_paddle.queue_redraw()


func _apply_third_fourth() -> void:
	third_fourth_active = true
	var top: EdgePaddle = preload("res://scenes/edge_paddle.tscn").instantiate()
	top.is_top = true
	add_child(top)
	top.ai_target = balls[0]
	edge_paddles.append(top)

	var bottom: EdgePaddle = preload("res://scenes/edge_paddle.tscn").instantiate()
	bottom.is_top = false
	add_child(bottom)
	bottom.ai_target = balls[0]
	edge_paddles.append(bottom)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://scenes/menu.tscn")
