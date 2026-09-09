extends Node2D
class_name Paddle

const WIDTH := 16.0
const HEIGHT := 100.0
const SPEED := 400.0

@export var player := 1 # 1 = W/S, 2 = Up/Down. Ignored when is_ai is true.
@export var is_ai := false

var ai_target: Node2D = null
var screen_height := 600.0


func _ready() -> void:
	screen_height = get_viewport_rect().size.y


func _draw() -> void:
	draw_rect(Rect2(-WIDTH / 2.0, -HEIGHT / 2.0, WIDTH, HEIGHT), Color.WHITE)


func _physics_process(delta: float) -> void:
	var dir := 0.0
	if is_ai:
		if ai_target:
			var diff: float = ai_target.position.y - position.y
			if abs(diff) > 4.0:
				dir = sign(diff)
	elif player == 1:
		if Input.is_key_pressed(KEY_W):
			dir -= 1.0
		if Input.is_key_pressed(KEY_S):
			dir += 1.0
	else:
		if Input.is_key_pressed(KEY_UP):
			dir -= 1.0
		if Input.is_key_pressed(KEY_DOWN):
			dir += 1.0

	position.y += dir * SPEED * delta
	position.y = clamp(position.y, HEIGHT / 2.0, screen_height - HEIGHT / 2.0)


func get_rect() -> Rect2:
	return Rect2(position - Vector2(WIDTH, HEIGHT) / 2.0, Vector2(WIDTH, HEIGHT))
