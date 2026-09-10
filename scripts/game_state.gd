extends Node

const DEFAULT_CHAOS_INTERVAL := 30.0
const MIN_CHAOS_INTERVAL := 10.0
const MAX_CHAOS_INTERVAL := 60.0

const CHAOS_EFFECT_KEYS := [
	"double_speed", "split", "swap", "third_fourth",
	"projectiles", "double_points", "shrink_paddles", "obstructions", "spin",
]

var two_player := false
var chaos_interval := DEFAULT_CHAOS_INTERVAL
var enabled_chaos_effects := {
	"double_speed": true,
	"split": true,
	"swap": true,
	"third_fourth": true,
	"projectiles": true,
	"double_points": true,
	"shrink_paddles": true,
	"obstructions": true,
	"spin": true,
}
