extends Node2D
class_name Ball

const RADIUS := 16.0
const START_SPEED := 600.0
const SPEED_INCREMENT := 40.0
const SPIN_DECAY := 0.7 # spin multiplier applied on every bounce
const SPIN_STOP_THRESHOLD := 0.05 # below this, spin snaps to exactly 0

signal scored(scorer: int) # 1 = left paddle scores, 2 = right paddle scores

var velocity := Vector2.ZERO
var screen_size := Vector2(800, 600)
var speed_scale := 1.0
var is_split_clone := false
var is_accent := false
var spin := 0.0 # radians/sec; velocity rotates continuously while nonzero
var visual_spin_angle := 0.0 # drives the spin-indicator bar, accumulates at the spin rate


func _ready() -> void:
	screen_size = get_viewport_rect().size
	reset(1 if randf() < 0.5 else -1)


func current_color() -> Color:
	if is_accent:
		return Color("#e8b64d") # gold - double points active
	if is_split_clone:
		return Color("#a374e0") # violet - split clone
	return Color("#e8e8ec") # normal


func _draw() -> void:
	draw_circle(Vector2.ZERO, RADIUS, current_color())
	if spin != 0.0:
		var bar_dir := Vector2(RADIUS, 0.0).rotated(visual_spin_angle)
		draw_line(-bar_dir, bar_dir, Color("#1a1c22"), 3.0)


func decay_spin() -> void:
	spin *= SPIN_DECAY
	if abs(spin) < SPIN_STOP_THRESHOLD:
		spin = 0.0


func reset(direction: int) -> void:
	position = screen_size / 2.0
	var angle := randf_range(-0.3, 0.3)
	velocity = Vector2(direction, 0.0).rotated(angle) * START_SPEED * speed_scale


func _process(delta: float) -> void:
	if spin != 0.0:
		velocity = velocity.rotated(spin * delta)
		visual_spin_angle += spin * delta
		queue_redraw()
	position += velocity * delta

	if position.y - RADIUS <= 0.0 or position.y + RADIUS >= screen_size.y:
		velocity.y = -velocity.y
		position.y = clamp(position.y, RADIUS, screen_size.y - RADIUS)
		decay_spin()

	if position.x < -RADIUS:
		scored.emit(2)
	elif position.x > screen_size.x + RADIUS:
		scored.emit(1)


func bounce_off_paddle(paddle_rect: Rect2, from_left: bool) -> void:
	var paddle_center_y := paddle_rect.position.y + paddle_rect.size.y / 2.0
	var offset := (position.y - paddle_center_y) / (paddle_rect.size.y / 2.0)
	offset = clamp(offset, -1.0, 1.0)
	var speed := velocity.length() + SPEED_INCREMENT
	var dir := 1.0 if from_left else -1.0
	velocity = Vector2(dir, offset).normalized() * speed
	decay_spin()


func bounce_off_horizontal_paddle(paddle_rect: Rect2, from_top: bool) -> void:
	var paddle_center_x := paddle_rect.position.x + paddle_rect.size.x / 2.0
	var offset := (position.x - paddle_center_x) / (paddle_rect.size.x / 2.0)
	offset = clamp(offset, -1.0, 1.0)
	var speed := velocity.length() + SPEED_INCREMENT
	var dir := 1.0 if from_top else -1.0
	velocity = Vector2(offset, dir).normalized() * speed
	decay_spin()


func get_rect() -> Rect2:
	return Rect2(position - Vector2.ONE * RADIUS, Vector2.ONE * RADIUS * 2.0)
