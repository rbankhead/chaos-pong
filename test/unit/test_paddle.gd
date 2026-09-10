extends GutTest

var PaddleScene := preload("res://scenes/paddle.tscn")


func test_try_shoot_respects_half_second_cooldown() -> void:
	var paddle = PaddleScene.instantiate()
	add_child_autofree(paddle)
	paddle.can_shoot = true
	watch_signals(paddle)

	paddle._try_shoot(true, 0.016)
	assert_signal_emit_count(paddle, "shoot_requested", 1)

	paddle._try_shoot(true, 0.016)
	assert_signal_emit_count(paddle, "shoot_requested", 1) # still on cooldown

	paddle._try_shoot(true, 0.5) # cooldown elapses
	assert_signal_emit_count(paddle, "shoot_requested", 2)


func test_try_shoot_does_nothing_when_not_wanted() -> void:
	var paddle = PaddleScene.instantiate()
	add_child_autofree(paddle)
	paddle.can_shoot = true
	watch_signals(paddle)

	paddle._try_shoot(false, 1.0)
	assert_signal_emit_count(paddle, "shoot_requested", 0)


func test_left_paddle_shoots_rightward() -> void:
	var paddle = PaddleScene.instantiate()
	add_child_autofree(paddle)
	paddle.is_left_side = true
	paddle.can_shoot = true
	watch_signals(paddle)

	paddle._try_shoot(true, 1.0)
	var params: Array = get_signal_parameters(paddle, "shoot_requested")
	assert_eq(params[1], 1.0)


func test_right_paddle_shoots_leftward() -> void:
	var paddle = PaddleScene.instantiate()
	add_child_autofree(paddle)
	paddle.is_left_side = false
	paddle.can_shoot = true
	watch_signals(paddle)

	paddle._try_shoot(true, 1.0)
	var params: Array = get_signal_parameters(paddle, "shoot_requested")
	assert_eq(params[1], -1.0)
