extends GutTest

var ObstacleScene := preload("res://scenes/obstacle.tscn")
var BallScene := preload("res://scenes/ball.tscn")


func test_bounce_ball_reflects_velocity() -> void:
	var obstacle = ObstacleScene.instantiate()
	add_child_autofree(obstacle)
	obstacle.position = Vector2(500.0, 500.0)

	var ball = BallScene.instantiate()
	add_child_autofree(ball)
	ball.position = Vector2(500.0, 400.0) # directly above the obstacle
	ball.velocity = Vector2(0.0, 300.0) # moving down, into it

	obstacle.bounce_ball(ball)
	assert_lt(ball.velocity.y, 0.0) # reflected back upward


func test_bounce_ball_decays_spin() -> void:
	var obstacle = ObstacleScene.instantiate()
	add_child_autofree(obstacle)
	obstacle.position = Vector2(500.0, 500.0)

	var ball = BallScene.instantiate()
	add_child_autofree(ball)
	ball.position = Vector2(500.0, 400.0)
	ball.velocity = Vector2(0.0, 300.0)
	ball.spin = 1.0

	obstacle.bounce_ball(ball)
	assert_almost_eq(ball.spin, 0.7, 0.001)
