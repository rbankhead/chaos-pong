extends Node2D
class_name HorizontalPaddle

const LENGTH := 220.0
const THICKNESS := 32.0
const WALL_MARGIN := 60.0 # keeps this off the wall so it's a distinct hit, not a duplicate bounce

@export var is_top := true

var screen_width := 800.0
var body_style := StyleBoxFlat.new()


func _ready() -> void:
	var viewport_size := get_viewport_rect().size
	screen_width = viewport_size.x
	position.x = screen_width / 2.0
	position.y = THICKNESS / 2.0 + WALL_MARGIN if is_top else viewport_size.y - THICKNESS / 2.0 - WALL_MARGIN

	body_style.bg_color = Color("#e8e8ec")
	body_style.set_corner_radius_all(8)


func _draw() -> void:
	draw_style_box(body_style, Rect2(-LENGTH / 2.0, -THICKNESS / 2.0, LENGTH, THICKNESS))


func set_position_from_ratio(ratio: float) -> void:
	var min_x := LENGTH / 2.0
	var max_x := screen_width - LENGTH / 2.0
	position.x = lerp(min_x, max_x, clamp(ratio, 0.0, 1.0))


func get_rect() -> Rect2:
	return Rect2(position - Vector2(LENGTH, THICKNESS) / 2.0, Vector2(LENGTH, THICKNESS))
