extends GutTest

var GameScene := preload("res://scenes/game.tscn")


func before_each() -> void:
	GameState.chaos_interval = GameState.DEFAULT_CHAOS_INTERVAL
	for key in GameState.CHAOS_EFFECT_KEYS:
		GameState.enabled_chaos_effects[key] = true


func test_uses_chaos_interval_from_game_state() -> void:
	GameState.chaos_interval = 15.0
	var game = GameScene.instantiate()
	add_child_autofree(game)
	assert_eq(game.chaos_interval, 15.0)
	assert_eq(game.next_chaos_time, 15.0)


func test_disabled_effect_is_excluded_from_chaos_pool() -> void:
	GameState.enabled_chaos_effects["split"] = false
	var game = GameScene.instantiate()
	add_child_autofree(game)
	assert_eq(game.chaos_pool.size(), 7)
	assert_false(game.chaos_pool.has("split"))


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
	assert_eq(game.scores[1], 1)

	var original = game.balls[0]
	game._on_scored(2, original)
	assert_eq(game.balls.size(), 3) # original stays in play, just resets
	assert_eq(game.scores[2], 1)


func test_score_follows_player_through_swap() -> void:
	var game = GameScene.instantiate()
	add_child_autofree(game)
	game._apply_swap()
	assert_eq(game.left_paddle.player, 2)
	assert_eq(game.right_paddle.player, 1)

	# Right side scores (scorer 2), now credited to player 1 since they swapped onto the right paddle.
	game._on_scored(2, game.balls[0])
	assert_eq(game.scores[1], 1)
	assert_eq(game.scores[2], 0)


func test_apply_third_fourth_spawns_two_horizontal_paddles() -> void:
	var game = GameScene.instantiate()
	add_child_autofree(game)
	game._apply_third_fourth()
	assert_eq(game.horizontal_paddles.size(), 2)
	assert_true(game.third_fourth_active)


func test_top_horizontal_paddle_clears_score_labels() -> void:
	var game = GameScene.instantiate()
	add_child_autofree(game)
	game._apply_third_fourth()
	var top = game.horizontal_paddles.filter(func(p): return p.is_top)[0]
	var score_label_top := 110.0 # UI/LeftScore + UI/RightScore offset_top in game.tscn
	var paddle_bottom_edge: float = top.get_rect().position.y + top.get_rect().size.y
	assert_lt(paddle_bottom_edge, score_label_top)


func test_all_eight_chaos_effects_trigger_exactly_once() -> void:
	var game = GameScene.instantiate()
	add_child_autofree(game)
	for i in range(8):
		game._trigger_random_chaos()
	assert_eq(game.chaos_pool.size(), 0)
	assert_true(game.third_fourth_active)
	assert_eq(game.horizontal_paddles.size(), 2)
	assert_eq(game.balls.size(), 4)
	assert_true(game.left_paddle.can_shoot)
	assert_true(game.right_paddle.can_shoot)
	assert_true(game.double_points_active)
	assert_eq(game.left_paddle.height_scale, 0.5)
	assert_eq(game.right_paddle.height_scale, 0.5)
	assert_true(game.obstructions_active)


func test_apply_double_points_marks_balls_accent() -> void:
	var game = GameScene.instantiate()
	add_child_autofree(game)
	game._apply_double_points()
	assert_true(game.double_points_active)
	assert_true(game.balls[0].is_accent)


func test_double_points_cannot_reactivate_after_pool_exhausted() -> void:
	var game = GameScene.instantiate()
	add_child_autofree(game)
	game.chaos_pool = ["double_points"] # force it to be the one that fires
	game._trigger_random_chaos()
	assert_true(game.double_points_active)
	assert_false(game.chaos_pool.has("double_points")) # removed by the real trigger path

	game._on_scored(1, game.balls[0])
	assert_false(game.double_points_active)
	assert_true(game.chaos_pool.is_empty()) # nothing left that could ever re-fire it

	game._on_scored(1, game.balls[0])
	assert_false(game.double_points_active)
	assert_false(game.balls[0].is_accent)


func test_double_points_awards_two_points_per_score() -> void:
	var game = GameScene.instantiate()
	add_child_autofree(game)
	game._apply_double_points()
	game._on_scored(1, game.balls[0])
	assert_eq(game.scores[1], 2)


func test_double_points_is_consumed_after_one_score() -> void:
	var game = GameScene.instantiate()
	add_child_autofree(game)
	game._apply_double_points()
	game._on_scored(1, game.balls[0])
	assert_false(game.double_points_active)
	assert_false(game.balls[0].is_accent)

	# The bonus is spent - the next score is worth only 1.
	game._on_scored(1, game.balls[0])
	assert_eq(game.scores[1], 3) # 2 from the first score, 1 from the second


func test_double_points_reverts_all_balls_in_play() -> void:
	var game = GameScene.instantiate()
	add_child_autofree(game)
	game._apply_double_points()
	game._apply_split()
	game._on_scored(1, game.balls[0])
	for ball in game.balls:
		assert_false(ball.is_accent)


func test_split_clone_inherits_accent_status() -> void:
	var game = GameScene.instantiate()
	add_child_autofree(game)
	game._apply_double_points()
	game._apply_split()
	for ball in game.balls:
		assert_true(ball.is_accent)


func test_apply_shrink_paddles_halves_both_paddles() -> void:
	var game = GameScene.instantiate()
	add_child_autofree(game)
	game._apply_shrink_paddles()
	assert_eq(game.left_paddle.height_scale, 0.5)
	assert_eq(game.right_paddle.height_scale, 0.5)
	assert_eq(game.left_paddle.current_height(), Paddle.HEIGHT * 0.5)


func test_apply_obstructions_sets_flag() -> void:
	var game = GameScene.instantiate()
	add_child_autofree(game)
	game._apply_obstructions()
	assert_true(game.obstructions_active)


func test_spawn_obstacle_adds_to_obstacles_array() -> void:
	var game = GameScene.instantiate()
	add_child_autofree(game)
	game._spawn_obstacle()
	assert_eq(game.obstacles.size(), 1)


func test_obstacle_bounces_ball_and_is_not_consumed() -> void:
	var game = GameScene.instantiate()
	add_child_autofree(game)
	var ball = game.balls[0]
	ball.velocity = Vector2(0.0, 100.0)
	game._spawn_obstacle()
	var obstacle = game.obstacles[0]
	obstacle.position = ball.position + Vector2(0, 1) # obstacle just below, ball moving toward it
	game._process(0.0)
	assert_eq(game.obstacles.size(), 1) # still alive, unlike a projectile
	assert_ne(ball.velocity, Vector2(0.0, 100.0))


func test_apply_projectiles_enables_shooting_on_both_paddles() -> void:
	var game = GameScene.instantiate()
	add_child_autofree(game)
	game._apply_projectiles()
	assert_true(game.left_paddle.can_shoot)
	assert_true(game.right_paddle.can_shoot)


func test_shoot_requested_spawns_a_projectile() -> void:
	var game = GameScene.instantiate()
	add_child_autofree(game)
	game._apply_projectiles()
	game._on_shoot_requested(game.left_paddle, 1.0)
	assert_eq(game.projectiles.size(), 1)
	assert_eq(game.projectiles[0].velocity, Vector2(Projectile.SPEED, 0.0))


func test_projectile_redirects_ball_and_is_consumed_on_hit() -> void:
	var game = GameScene.instantiate()
	add_child_autofree(game)
	var ball = game.balls[0]
	ball.velocity = Vector2(100.0, 0.0)
	game._apply_projectiles()
	game._on_shoot_requested(game.left_paddle, 1.0)
	game.projectiles[0].position = ball.position # force an overlap
	game._process(0.0)
	assert_eq(game.projectiles.size(), 0)
	assert_ne(ball.velocity, Vector2(100.0, 0.0))


func test_projectile_does_not_collide_with_paddles() -> void:
	var game = GameScene.instantiate()
	add_child_autofree(game)
	game._apply_projectiles()
	game._on_shoot_requested(game.left_paddle, 1.0)
	game.projectiles[0].position = game.right_paddle.position # force an overlap with a paddle
	game._process(0.0)
	assert_eq(game.projectiles.size(), 1) # still alive - projectiles only collide with balls
