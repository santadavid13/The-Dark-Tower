# The Dark Tower Remake

A **Godot 4.7** 2D dungeon: **22 levels** (0–21) on an **11×11 grid**. You move one tile at a time, only up, down, left, or right.

## How to run

1. Open **Godot 4.7**, import this folder, open `project.godot`.
2. Press **F5**.

**WASD** or **arrow keys** step one tile. Dark cells are walls (you stay put). Gold tiles go **up** one level. Blue tiles go **down** one level. Level 0 has no down stairs; level 21 has no up stairs.

You arrive on the matching stair of the next floor and do not bounce back until you walk off that tile.

## What’s in the folder

| Path | Role |
| --- | --- |
| `project.godot` | Window size, input keys, main scene |
| `scenes/main.tscn` | Grid view + HUD |
| `scripts/game.gd` | Movement, walls, stairs, drawing the grid |
| `scripts/dungeon.gd` | Builds 22 maze floors |
| `icon.svg` | Project icon |

## Best first change

Open `scripts/dungeon.gd` and change `rng.seed` in `_make_level` so every floor gets a new maze. Or in `scripts/game.gd`, change the gold/blue colors in `_tile_color`.
