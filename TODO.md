# Chaos Pong - TODO

Brainstormed chaos effects not yet built, saved for later. Not prioritized within each list.

## Global (auto-triggered, affects both sides)
- Fog — a moving blind spot obscures part of the field
- Field rotate — spins the field 90° via a `Camera2D` at the field's center with its `rotation` tweened (no game-logic changes needed; UI stays upright since `CanvasLayer` ignores camera transform)
- Controls invert — up/down flipped for both players briefly
- Field tilt/wind — ball trajectory gradually curves toward one side
- Screen shake — brief earthquake, purely disorienting
- Ball flicker — semi-invisible on a cycle
- Sumo paddles — paddles repel each other if they touch

## Boons (from a pickup, individual benefit)
- Magnet paddle — pulls the ball toward it slightly when close
- One-time shield — absorbs a ball that would've gone past you
- Teleport — paddle instantly snaps to the ball's height once
- Freeze opponent — their paddle can't move for ~1s
- Curveball — your next hit puts unpredictable spin on the ball
- Speed boost — your paddle moves faster for a few seconds
- Clone paddle — a second, smaller paddle appears briefly on your side
- Extra life — your next miss doesn't count as a score against you

## Debuffs (from a pickup, or paired with opponent's boon)
- Reversed controls — your own up/down flips for a few seconds
- Blackout — your half of the screen darkens
- Heavy paddle — delayed/laggy response to input
- Frozen — your paddle can't move for a couple seconds
- Butterfingers — bounces get randomized angle instead of offset-based

## Notes
- Boons/debuffs need a pickup-spawning subsystem that doesn't exist yet (current chaos system is Global-only, on a timer). Building the first boon or debuff also means building that subsystem.
- Godot Web export + GitHub Pages hosting — deferred, not worth the setup cost yet for a prototype this size (see chat history for reasoning).
