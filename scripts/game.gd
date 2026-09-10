extends Node2D

const CHAOS_FIRST_DELAY := 30.0
const CHAOS_INTERVAL := 30.0
const OBSTACLE_SPAWN_INTERVAL := 3.0

@onready var left_paddle: Paddle = $LeftPaddle
@onready var right_paddle: Paddle = $RightPaddle
@onready var left_score_label: Label = $UI/LeftScore
@onready var right_score_label: Label = $UI/RightScore
@onready var debug_timer_label: Label = $UI/DebugTimer

var balls: Array[Ball] = []
var horizontal_paddles: Array[HorizontalPaddle] = []
var projectiles: Array[Projectile] = []
var obstacles: Array[Obstacle] = []
var third_fourth_active := false
var double_points_active := false
var obstructions_active := false
var obstacle_spawn_timer := 0.0

var scores := {1: 0, 2: 0}

var chaos_pool := ["double_speed", "split", "swap", "third_fourth", "projectiles", "double_points", "shrink_paddles", "obstructions"]
var chaos_timer := 0.0
var next_chaos_time := CHAOS_FIRST_DELAY


func _ready() -> void:
	right_paddle.is_ai = not GameState.two_player
	if right_paddle.is_ai:
		right_paddle.ai_target = $Ball
	_register_ball($Ball)
	_update_score_labels()
	debug_timer_label.visible = OS.is_debug_build()


func _process(delta: float) -> void:
	chaos_timer += delta
	if chaos_timer >= next_chaos_time and not chaos_pool.is_empty():
		next_chaos_time += CHAOS_INTERVAL
		_trigger_random_chaos()

	if OS.is_debug_build():
		if chaos_pool.is_empty():
			debug_timer_label.text = "Chaos: all fired (t=%.1fs)" % chaos_timer
		else:
			debug_timer_label.text = "Next chaos in: %.1fs" % max(next_chaos_time - chaos_timer, 0.0)

	for ball in balls:
		if ball.velocity.x < 0.0 and ball.get_rect().intersects(left_paddle.get_rect()):
			ball.bounce_off_paddle(left_paddle.get_rect(), true)
		elif ball.velocity.x > 0.0 and ball.get_rect().intersects(right_paddle.get_rect()):
			ball.bounce_off_paddle(right_paddle.get_rect(), false)

		if third_fourth_active:
			for h_paddle in horizontal_paddles:
				if h_paddle.is_top and ball.velocity.y < 0.0 and ball.get_rect().intersects(h_paddle.get_rect()):
					ball.bounce_off_horizontal_paddle(h_paddle.get_rect(), true)
				elif not h_paddle.is_top and ball.velocity.y > 0.0 and ball.get_rect().intersects(h_paddle.get_rect()):
					ball.bounce_off_horizontal_paddle(h_paddle.get_rect(), false)

	projectiles = projectiles.filter(func(p): return is_instance_valid(p))
	for projectile in projectiles.duplicate():
		for ball in balls:
			if projectile.get_rect().intersects(ball.get_rect()):
				ball.velocity += projectile.velocity.normalized() * Projectile.IMPULSE_STRENGTH
				projectiles.erase(projectile)
				projectile.queue_free()
				break

	if obstructions_active:
		obstacle_spawn_timer += delta
		if obstacle_spawn_timer >= OBSTACLE_SPAWN_INTERVAL:
			obstacle_spawn_timer = 0.0
			_spawn_obstacle()

	obstacles = obstacles.filter(func(o): return is_instance_valid(o))
	for obstacle in obstacles:
		for ball in balls:
			if obstacle.get_rect().intersects(ball.get_rect()):
				var to_ball := ball.position - obstacle.position
				if ball.velocity.dot(to_ball) < 0.0:
					obstacle.bounce_ball(ball)


func _register_ball(ball: Ball) -> void:
	balls.append(ball)
	ball.scored.connect(_on_scored.bind(ball))


func _on_scored(scorer: int, ball: Ball) -> void:
	var scoring_paddle: Paddle = left_paddle if scorer == 1 else right_paddle
	scores[scoring_paddle.player] += 2 if double_points_active else 1

	if ball.is_split_clone:
		balls.erase(ball)
		ball.queue_free()
	elif scorer == 1:
		ball.reset(1)
	else:
		ball.reset(-1)

	_update_score_labels()


func _update_score_labels() -> void:
	left_score_label.text = str(scores[left_paddle.player])
	right_score_label.text = str(scores[right_paddle.player])


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
		"projectiles":
			_apply_projectiles()
		"double_points":
			_apply_double_points()
		"shrink_paddles":
			_apply_shrink_paddles()
		"obstructions":
			_apply_obstructions()


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
			clone.is_accent = ball.is_accent
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
	_update_score_labels()


func _apply_third_fourth() -> void:
	third_fourth_active = true
	var top: HorizontalPaddle = preload("res://scenes/horizontal_paddle.tscn").instantiate()
	top.is_top = true
	add_child(top)
	top.ai_target = balls[0]
	horizontal_paddles.append(top)

	var bottom: HorizontalPaddle = preload("res://scenes/horizontal_paddle.tscn").instantiate()
	bottom.is_top = false
	add_child(bottom)
	bottom.ai_target = balls[0]
	horizontal_paddles.append(bottom)


func _apply_projectiles() -> void:
	left_paddle.can_shoot = true
	right_paddle.can_shoot = true
	left_paddle.shoot_requested.connect(_on_shoot_requested)
	right_paddle.shoot_requested.connect(_on_shoot_requested)


func _on_shoot_requested(paddle: Paddle, direction: float) -> void:
	var projectile: Projectile = preload("res://scenes/projectile.tscn").instantiate()
	add_child(projectile)
	projectile.position = paddle.position
	projectile.velocity = Vector2(direction, 0.0) * Projectile.SPEED
	projectiles.append(projectile)


func _apply_double_points() -> void:
	double_points_active = true
	for ball in balls:
		ball.is_accent = true
		ball.queue_redraw()


func _apply_shrink_paddles() -> void:
	left_paddle.height_scale = 0.5
	right_paddle.height_scale = 0.5
	left_paddle.queue_redraw()
	right_paddle.queue_redraw()


func _apply_obstructions() -> void:
	obstructions_active = true


func _spawn_obstacle() -> void:
	var obstacle: Obstacle = preload("res://scenes/obstacle.tscn").instantiate()
	add_child(obstacle)
	var margin := 100.0
	obstacle.position = Vector2(randf_range(margin, obstacle.screen_size.x - margin), -Obstacle.RADIUS)
	obstacles.append(obstacle)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://scenes/menu.tscn")
