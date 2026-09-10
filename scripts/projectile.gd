extends Node2D
class_name Projectile

const RADIUS := 6.0
const SPEED := 900.0
const IMPULSE_STRENGTH := 300.0

var velocity := Vector2.ZERO
var screen_size := Vector2(800, 600)


func _ready() -> void:
	screen_size = get_viewport_rect().size


func _draw() -> void:
	draw_circle(Vector2.ZERO, RADIUS, Color("#4d9fff"))


func _process(delta: float) -> void:
	position += velocity * delta
	if position.x < -RADIUS or position.x > screen_size.x + RADIUS \
			or position.y < -RADIUS or position.y > screen_size.y + RADIUS:
		queue_free()


func get_rect() -> Rect2:
	return Rect2(position - Vector2.ONE * RADIUS, Vector2.ONE * RADIUS * 2.0)
