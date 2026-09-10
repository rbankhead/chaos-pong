# Chaos Pong

## Git workflow
This repo is private and solo, so push to `origin` immediately after every local commit — no need to ask first. This overrides the general default of not pushing unless asked; it's specific to this project.

## Architecture doc
`ARCHITECTURE.txt` at the repo root describes the current structure: entity list, what Game.gd owns, the chaos effect system, and known deliberate gaps. Whenever a change alters that structure — a new entity, a new chaos effect, a new top-level system, or a gap getting fixed — update `ARCHITECTURE.txt` in the same commit as the change. It should always reflect the current code, not the original design intent.

## Verify before committing
Before every commit: run the GUT suite (`godot --headless -s addons/gut/gut_cmdln.gd -d --path . -gdir=res://test/unit -gexit`) and load every scene touched by the change headlessly (`godot --headless --path . scenes/<scene>.tscn --quit-after 5`) to catch script/parse errors. A new `class_name` needs a headless editor import pass first (`godot --headless --editor --path . --quit-after 5`) or references to it will fail to resolve. The pre-commit hook already blocks a failing test suite, but it doesn't catch a scene that fails to load — that's still on you to check.
