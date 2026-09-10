extends Node2D
class_name Obstacle

const RADIUS := 24.0
const FALL_SPEED := 250.0

var screen_size := Vector2(800, 600)


func _ready() -> void:
	screen_size = get_viewport_rect().size


func _draw() -> void:
	draw_circle(Vector2.ZERO, RADIUS, Color(0.55, 0.4, 0.75, 1.0))


func _process(delta: float) -> void:
	position.y += FALL_SPEED * delta
	if position.y - RADIUS > screen_size.y:
		queue_free()


func bounce_ball(ball: Ball) -> void:
	var normal := (ball.position - position).normalized()
	if normal == Vector2.ZERO:
		normal = Vector2.UP
	ball.velocity = ball.velocity.bounce(normal)


func get_rect() -> Rect2:
	return Rect2(position - Vector2.ONE * RADIUS, Vector2.ONE * RADIUS * 2.0)
