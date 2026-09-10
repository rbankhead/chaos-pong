extends GutTest

var GameScene := preload("res://scenes/game.tscn")


func test_apply_double_speed_scales_all_balls() -> void:
	var game = GameScene.instantiate()
	add_child_autofree(game)
	var ball = game.balls[0]
	var before: float = ball.velocity.length()
	game._apply_double_speed()
	assert_almost_eq(ball.velocity.length(), before * 2.0, 1.0)
	assert_eq(ball.speed_scale, 2.0)


func test_apply_swap_flips_paddle_assignment() -> void:
	var game = GameScene.instantiate()
	add_child_autofree(game)
	var left_player_before = game.left_paddle.player
	var right_player_before = game.right_paddle.player
	game._apply_swap()
	assert_eq(game.left_paddle.player, right_player_before)
	assert_eq(game.right_paddle.player, left_player_before)


func test_apply_split_quadruples_balls_and_marks_clones() -> void:
	var game = GameScene.instantiate()
	add_child_autofree(game)
	game._apply_split()
	assert_eq(game.balls.size(), 4)
	assert_false(game.balls[0].is_split_clone)
	assert_true(game.balls[1].is_split_clone)
	assert_true(game.balls[2].is_split_clone)
	assert_true(game.balls[3].is_split_clone)


func test_split_clone_disappears_on_score_but_original_resets() -> void:
	var game = GameScene.instantiate()
	add_child_autofree(game)
	game._apply_split()
	var clone = game.balls[1]
	game._on_scored(1, clone)
	assert_eq(game.balls.size(), 3)
	assert_eq(game.left_score, 1)

	var original = game.balls[0]
	game._on_scored(2, original)
	assert_eq(game.balls.size(), 3) # original stays in play, just resets
	assert_eq(game.right_score, 1)


func test_apply_third_fourth_spawns_two_edge_paddles() -> void:
	var game = GameScene.instantiate()
	add_child_autofree(game)
	game._apply_third_fourth()
	assert_eq(game.edge_paddles.size(), 2)
	assert_true(game.third_fourth_active)


func test_all_four_chaos_effects_trigger_exactly_once() -> void:
	var game = GameScene.instantiate()
	add_child_autofree(game)
	for i in range(4):
		game._trigger_random_chaos()
	assert_eq(game.chaos_pool.size(), 0)
	assert_true(game.third_fourth_active)
	assert_eq(game.edge_paddles.size(), 2)
	assert_eq(game.balls.size(), 4)
