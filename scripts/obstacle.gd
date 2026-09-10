extends Node2D
class_name Obstacle

const RADIUS := 24.0
const FALL_SPEED := 250.0
const COLOR := Color("#c9342e")
const TRAIL_COUNT := 4
const TRAIL_SPACING := 14.0 # px between trail circles, opposite the fall direction

var screen_size := Vector2(800, 600)


func _ready() -> void:
	screen_size = get_viewport_rect().size


func _draw() -> void:
	for i in range(TRAIL_COUNT, 0, -1):
		var t := float(i)
		var trail_color := Color(COLOR.r, COLOR.g, COLOR.b, 0.5 / t)
		var trail_radius := RADIUS * (1.0 - t * 0.15)
		draw_circle(Vector2(0.0, -t * TRAIL_SPACING), trail_radius, trail_color)
	draw_circle(Vector2.ZERO, RADIUS, COLOR)


func _process(delta: float) -> void:
	position.y += FALL_SPEED * delta
	if position.y - RADIUS > screen_size.y:
		queue_free()


func bounce_ball(ball: Ball) -> void:
	var normal := (ball.position - position).normalized()
	if normal == Vector2.ZERO:
		normal = Vector2.UP
	ball.velocity = ball.velocity.bounce(normal)
	ball.decay_spin()


func get_rect() -> Rect2:
	return Rect2(position - Vector2.ONE * RADIUS, Vector2.ONE * RADIUS * 2.0)
