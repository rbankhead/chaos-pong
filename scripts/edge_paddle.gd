extends Node2D
class_name EdgePaddle

const LENGTH := 220.0
const THICKNESS := 32.0
const SPEED := 500.0
const WALL_MARGIN := 60.0 # keeps this off the wall so it's a distinct hit, not a duplicate bounce

const AI_REACTION_INTERVAL := 0.2
const AI_AIM_ERROR := 60.0

@export var is_top := true

var ai_target: Ball = null
var screen_width := 800.0
var ai_timer := 0.0
var ai_known_target_x := 0.0
var body_style := StyleBoxFlat.new()


func _ready() -> void:
	var viewport_size := get_viewport_rect().size
	screen_width = viewport_size.x
	position.x = screen_width / 2.0
	position.y = THICKNESS / 2.0 + WALL_MARGIN if is_top else viewport_size.y - THICKNESS / 2.0 - WALL_MARGIN
	ai_known_target_x = position.x

	body_style.bg_color = Color(0.82, 0.82, 0.84, 1.0)
	body_style.set_corner_radius_all(8)


func _draw() -> void:
	draw_style_box(body_style, Rect2(-LENGTH / 2.0, -THICKNESS / 2.0, LENGTH, THICKNESS))


func _process(delta: float) -> void:
	if ai_target == null:
		return
	ai_timer += delta
	if ai_timer >= AI_REACTION_INTERVAL:
		ai_timer = 0.0
		ai_known_target_x = ai_target.position.x + randf_range(-AI_AIM_ERROR, AI_AIM_ERROR)
	var diff: float = ai_known_target_x - position.x
	if abs(diff) > 4.0:
		position.x += sign(diff) * SPEED * delta
	position.x = clamp(position.x, LENGTH / 2.0, screen_width - LENGTH / 2.0)


func get_rect() -> Rect2:
	return Rect2(position - Vector2(LENGTH, THICKNESS) / 2.0, Vector2(LENGTH, THICKNESS))
