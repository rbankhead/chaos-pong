extends GutTest

var HorizontalPaddleScene := preload("res://scenes/horizontal_paddle.tscn")


func test_set_position_from_ratio_at_zero_is_left_edge() -> void:
	var hp = HorizontalPaddleScene.instantiate()
	add_child_autofree(hp)
	hp.screen_width = 2080.0
	hp.set_position_from_ratio(0.0)
	assert_almost_eq(hp.position.x, HorizontalPaddle.LENGTH / 2.0, 0.001)


func test_set_position_from_ratio_at_one_is_right_edge() -> void:
	var hp = HorizontalPaddleScene.instantiate()
	add_child_autofree(hp)
	hp.screen_width = 2080.0
	hp.set_position_from_ratio(1.0)
	assert_almost_eq(hp.position.x, 2080.0 - HorizontalPaddle.LENGTH / 2.0, 0.001)


func test_set_position_from_ratio_at_half_is_center() -> void:
	var hp = HorizontalPaddleScene.instantiate()
	add_child_autofree(hp)
	hp.screen_width = 2080.0
	hp.set_position_from_ratio(0.5)
	assert_almost_eq(hp.position.x, 1040.0, 0.001)


func test_set_position_from_ratio_clamps_out_of_range_input() -> void:
	var hp = HorizontalPaddleScene.instantiate()
	add_child_autofree(hp)
	hp.screen_width = 2080.0
	hp.set_position_from_ratio(1.5)
	assert_almost_eq(hp.position.x, 2080.0 - HorizontalPaddle.LENGTH / 2.0, 0.001)
