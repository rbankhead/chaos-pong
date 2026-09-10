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


func test_bounce_off_horizontal_paddle_mirrors_vertical_bounce() -> void:
	var ball = BallScene.instantiate()
	add_child_autofree(ball)
	ball.velocity = Vector2(0.0, -500.0)
	var paddle_rect := Rect2(0.0, 0.0, 200.0, 32.0)
	ball.position = Vector2(100.0, 0.0) # horizontal center of paddle_rect
	ball.bounce_off_horizontal_paddle(paddle_rect, true)
	assert_almost_eq(ball.velocity.y, 540.0, 1.0)
	assert_eq(ball.velocity.x, 0.0)
