extends Node2D
class_name Paddle

const WIDTH := 32.0
const HEIGHT := 200.0
const SPEED := 800.0

const AI_REACTION_INTERVAL := 0.2 # seconds between AI "looks" at the ball
const AI_AIM_ERROR := 40.0 # pixels of aim noise applied each time it looks
const SHOOT_COOLDOWN_TIME := 1.0 # max one shot per second

signal shoot_requested(paddle: Paddle, direction: float)

@export var player := 1 # 1 = W/S, 2 = Up/Down. Ignored when is_ai is true.
@export var is_ai := false

var can_shoot := false
var ai_target: Ball = null
var screen_height := 600.0
var screen_width := 800.0
var is_left_side := true
var ai_timer := 0.0
var ai_known_target_y := 0.0
var ai_ball_incoming := false
var shoot_cooldown := 0.0
var height_scale := 1.0
var body_style := StyleBoxFlat.new()


func current_height() -> float:
	return HEIGHT * height_scale


func _ready() -> void:
	var viewport_size := get_viewport_rect().size
	screen_height = viewport_size.y
	screen_width = viewport_size.x
	is_left_side = position.x < screen_width / 2.0

	body_style.bg_color = Color("#e8e8ec")
	body_style.set_corner_radius_all(8)


func _draw() -> void:
	var h := current_height()
	draw_style_box(body_style, Rect2(-WIDTH / 2.0, -h / 2.0, WIDTH, h))
	var marker_color := Color("#1a1c22")
	var r := WIDTH * 0.28
	if player == 1:
		draw_arc(Vector2.ZERO, r, 0.0, TAU, 24, marker_color, 3.0)
	else:
		draw_line(Vector2(-r, -r), Vector2(r, r), marker_color, 3.0)
		draw_line(Vector2(-r, r), Vector2(r, -r), marker_color, 3.0)


func _process(delta: float) -> void:
	var dir := 0.0
	var speed := SPEED
	if is_ai:
		if ai_target:
			ai_timer += delta
			if ai_timer >= AI_REACTION_INTERVAL:
				ai_timer = 0.0
				ai_ball_incoming = (is_left_side and ai_target.velocity.x < 0.0) or (not is_left_side and ai_target.velocity.x > 0.0)
				if ai_ball_incoming:
					ai_known_target_y = ai_target.position.y + randf_range(-AI_AIM_ERROR, AI_AIM_ERROR)
				else:
					ai_known_target_y = screen_height / 2.0
			var diff: float = ai_known_target_y - position.y
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

	position.y += dir * speed * delta
	var h := current_height()
	position.y = clamp(position.y, h / 2.0, screen_height - h / 2.0)

	if can_shoot:
		var wants_to_shoot := false
		if is_ai:
			wants_to_shoot = ai_ball_incoming
		elif player == 1:
			wants_to_shoot = Input.is_key_pressed(KEY_SPACE)
		else:
			wants_to_shoot = Input.is_key_pressed(KEY_ENTER)
		_try_shoot(wants_to_shoot, delta)


func _try_shoot(wants_to_shoot: bool, delta: float) -> void:
	shoot_cooldown = max(shoot_cooldown - delta, 0.0)
	if wants_to_shoot and shoot_cooldown <= 0.0:
		shoot_cooldown = SHOOT_COOLDOWN_TIME
		shoot_requested.emit(self, 1.0 if is_left_side else -1.0)


func get_rect() -> Rect2:
	var h := current_height()
	return Rect2(position - Vector2(WIDTH, h) / 2.0, Vector2(WIDTH, h))
