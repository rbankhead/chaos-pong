extends GutTest

var BallScene := preload("res://scenes/ball.tscn")


func test_reset_uses_speed_scale() -> void:
	var ball = BallScene.instantiate()
	add_child_autofree(ball)
	ball.speed_scale = 2.0
	ball.reset(1)
	assert_almost_eq(ball.velocity.length(), ball.START_SPEED * 2.0, 1.0)


func test_bounce_off_paddle_center_hit_goes_straight() -> void:
	var ball = BallScene.instantiate()
	add_child_autofree(ball)
	ball.velocity = Vector2(-500.0, 0.0)
	var paddle_rect := Rect2(0.0, 0.0, 32.0, 200.0)
	ball.position = Vector2(0.0, 100.0) # vertical center of paddle_rect
	ball.bounce_off_paddle(paddle_rect, true)
	assert_almost_eq(ball.velocity.x, 540.0, 1.0)
	assert_eq(ball.velocity.y, 0.0)


func test_bounce_off_paddle_edge_hit_deflects() -> void:
	var ball = BallScene.instantiate()
	add_child_autofree(ball)
	ball.velocity = Vector2(500.0, 0.0)
	var paddle_rect := Rect2(0.0, 0.0, 32.0, 200.0)
	ball.position = Vector2(0.0, 0.0) # top edge of paddle_rect
	ball.bounce_off_paddle(paddle_rect, false)
	assert_lt(ball.velocity.x, 0.0)
	assert_lt(ball.velocity.y, 0.0)


func test_hit_by_projectile_redirects_toward_projectile_direction() -> void:
	var ball = BallScene.instantiate()
	add_child_autofree(ball)
	ball.velocity = Vector2(500.0, 0.0)
	ball.hit_by_projectile(Vector2(0.0, 1.0))
	assert_almost_eq(ball.velocity.angle(), Vector2(0.0, 1.0).angle(), 0.01)
	assert_almost_eq(ball.velocity.length(), 540.0, 1.0) # speed + SPEED_INCREMENT, like a paddle bounce


func test_hit_by_projectile_decays_spin() -> void:
	var ball = BallScene.instantiate()
	add_child_autofree(ball)
	ball.velocity = Vector2(500.0, 0.0)
	ball.spin = 1.0
	ball.hit_by_projectile(Vector2(0.0, 1.0))
	assert_almost_eq(ball.spin, 0.7, 0.001)


func test_bounce_off_horizontal_paddle_mirrors_vertical_bounce() -> void:
	var ball = BallScene.instantiate()
	add_child_autofree(ball)
	ball.velocity = Vector2(0.0, -500.0)
	var paddle_rect := Rect2(0.0, 0.0, 200.0, 32.0)
	ball.position = Vector2(100.0, 0.0) # horizontal center of paddle_rect
	ball.bounce_off_horizontal_paddle(paddle_rect, true)
	assert_almost_eq(ball.velocity.y, 540.0, 1.0)
	assert_eq(ball.velocity.x, 0.0)


func test_normal_ball_color() -> void:
	var ball = BallScene.instantiate()
	add_child_autofree(ball)
	assert_eq(ball.current_color(), Color("#e8e8ec"))


func test_split_clone_color_differs_from_normal() -> void:
	var ball = BallScene.instantiate()
	add_child_autofree(ball)
	ball.is_split_clone = true
	assert_eq(ball.current_color(), Color("#a374e0"))
	assert_ne(ball.current_color(), Color("#e8e8ec"))


func test_accent_color_is_gold_and_takes_priority_over_split_clone() -> void:
	var ball = BallScene.instantiate()
	add_child_autofree(ball)
	ball.is_split_clone = true
	ball.is_accent = true
	assert_eq(ball.current_color(), Color("#e8b64d"))


func test_spin_curves_velocity_while_preserving_speed() -> void:
	var ball = BallScene.instantiate()
	add_child_autofree(ball)
	ball.velocity = Vector2(500.0, 0.0)
	ball.spin = 1.0 # 1 radian/sec
	var speed_before: float = ball.velocity.length()
	ball._process(0.5) # half a second of curve
	# Godot's rotated() is Y-down, so a positive angle reads as negative on .angle().
	assert_almost_eq(ball.velocity.angle(), -0.5, 0.01) # rotated by spin * delta
	assert_almost_eq(ball.velocity.length(), speed_before, 0.5) # speed preserved
	assert_almost_eq(ball.visual_spin_angle, 0.5, 0.01) # indicator bar tracks the same rate


func test_no_spin_indicator_bar_when_spin_is_zero() -> void:
	var ball = BallScene.instantiate()
	add_child_autofree(ball)
	ball.spin = 0.0
	ball._process(1.0)
	assert_eq(ball.visual_spin_angle, 0.0)


func test_zero_spin_does_not_alter_velocity_direction() -> void:
	var ball = BallScene.instantiate()
	add_child_autofree(ball)
	ball.velocity = Vector2(500.0, 0.0)
	ball.spin = 0.0
	ball._process(0.5)
	assert_almost_eq(ball.velocity.angle(), 0.0, 0.001)


func test_decay_spin_multiplies_by_decay_factor() -> void:
	var ball = BallScene.instantiate()
	add_child_autofree(ball)
	ball.spin = 1.0
	ball.decay_spin()
	assert_almost_eq(ball.spin, 0.7, 0.001)


func test_decay_spin_snaps_to_zero_below_threshold() -> void:
	var ball = BallScene.instantiate()
	add_child_autofree(ball)
	ball.spin = 0.06
	ball.decay_spin() # 0.06 * 0.7 = 0.042, below the 0.05 threshold
	assert_eq(ball.spin, 0.0)


func test_bounce_off_paddle_decays_spin() -> void:
	var ball = BallScene.instantiate()
	add_child_autofree(ball)
	ball.velocity = Vector2(-500.0, 0.0)
	ball.spin = 1.0
	var paddle_rect := Rect2(0.0, 0.0, 32.0, 200.0)
	ball.position = Vector2(0.0, 100.0)
	ball.bounce_off_paddle(paddle_rect, true)
	assert_almost_eq(ball.spin, 0.7, 0.001)


func test_bounce_off_horizontal_paddle_decays_spin() -> void:
	var ball = BallScene.instantiate()
	add_child_autofree(ball)
	ball.velocity = Vector2(0.0, -500.0)
	ball.spin = 1.0
	var paddle_rect := Rect2(0.0, 0.0, 200.0, 32.0)
	ball.position = Vector2(100.0, 0.0)
	ball.bounce_off_horizontal_paddle(paddle_rect, true)
	assert_almost_eq(ball.spin, 0.7, 0.001)


func test_wall_bounce_decays_spin() -> void:
	var ball = BallScene.instantiate()
	add_child_autofree(ball)
	ball.spin = 1.0
	ball.velocity = Vector2(100.0, -50.0)
	ball.position = Vector2(500.0, ball.RADIUS) # sitting right at the top wall
	ball._process(0.0)
	assert_almost_eq(ball.spin, 0.7, 0.001)
