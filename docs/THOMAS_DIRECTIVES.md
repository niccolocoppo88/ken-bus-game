# Thomas — M3 Fixes Implementation Directives
**From:** Piotr (Architect)
**Date:** 2026-04-18 16:53
**Status:** READY FOR THOMAS

---

## Context

Nico ha dato ownership a Piotr. Il gioco è broken in produzione — manca il level progression wiring.

Doc principale: `docs/M3_FIXES_ARCHITECTURE.md`

---

## Problem Summary

- `kid_spawner.gd`, `obstacle_spawner.gd`, `background.gd` hanno già `set_level("school/city/forest/moon")` configurato ✅
- MA `main.gd` NON chiama mai `set_level()` — il gioco è bloccato su "city" per sempre ❌
- `obstacle.gd` ha solo 3 tipi (CAR_GREEN, CAR_RED, TRUCK) — servono 9 tipi ❌
- `powerup.gd` ha solo SHIELD e TURBO — servono DOUBLE_DECK, ROCKETS, FIREWORKS ❌
- Level progression system non esiste ❌

---

## Implementation Order

### FASE 1 — Core Wiring (P0, blocking)

**1.1 main.gd — Initial level setup**
In `start_game()`, dopo `bus.reset()`:
```gdscript
current_level_index = 0
obstacle_spawner.set_level("school")
kid_spawner.set_level("school")
background.set_level("school")
ui.show_level_intro("school")
```

**1.2 main.gd — Level state variables**
```gdscript
var current_level_index: int = 0
var LEVEL_ORDER = ["school", "city", "forest", "moon"]
var LEVEL_SCORES = [0, 500, 1500, 3000]
```

**1.3 main.gd — Level advancement check**
```gdscript
func _check_level_advancement():
    var next_idx = current_level_index + 1
    if next_idx >= LEVEL_ORDER.size():
        _trigger_victory()
        return
    if score >= LEVEL_SCORES[next_idx]:
        _advance_to_level(next_idx)

func _advance_to_level(idx: int):
    current_level_index = idx
    var level_name = LEVEL_ORDER[idx]
    obstacle_spawner.clear_all()
    kid_spawner.clear_all()
    powerup_spawner.clear_all()
    obstacle_spawner.set_level(level_name)
    kid_spawner.set_level(level_name)
    background.set_level(level_name)
    ui.show_level_intro(level_name)

func _trigger_victory():
    current_state = State.VICTORY
    obstacle_timer.stop(); kid_timer.stop(); powerup_timer.stop(); difficulty_timer.stop()
    ui.show_victory_screen(score)
```

**1.4 main.gd — Call _check_level_advancement()**
In `_on_bus_kid_collected()`, dopo `score += 50`:
```gdscript
_check_level_advancement()
```

---

### FASE 2 — Entity Type Extension (P0)

**2.1 obstacle.gd — Extend enum:**
```gdscript
enum Type {
    CAR_GREEN, CAR_RED, TRUCK,
    BALL, BACKPACK,
    TREE, ROCK,
    CRATER, ASTEROID
}
```

**2.2 obstacle.gd — Extend setup() match:**
Aggiungere casi per BALL, BACKPACK, TREE, ROCK, CRATER, ASTEROID con texture path e collision size appropriati.

**2.3 powerup.gd — Extend enum:**
```gdscript
enum Type {
    SHIELD, TURBO,
    DOUBLE_DECK, ROCKETS, FIREWORKS
}
```

**2.4 powerup.gd — Extend setup() match:**
Aggiungere casi per DOUBLE_DECK (blue), ROCKETS (orange-red), FIREWORKS (pink) con colori distintivi.

**2.5 powerup_spawner.gd — Update _random_type():**
```gdscript
func _random_type() -> PowerUp.Type:
    var r = randf()
    if r < 0.20: return PowerUp.Type.SHIELD
    elif r < 0.40: return PowerUp.Type.TURBO
    elif r < 0.60: return PowerUp.Type.DOUBLE_DECK
    elif r < 0.80: return PowerUp.Type.ROCKETS
    else: return PowerUp.Type.FIREWORKS
```

---

### FASE 3 — Level Complete Screen (P1)

**3.1 scenes/level_complete.tscn**
CanvasLayer con:
- Background semi-trasparente
- "LEVEL COMPLETE!" label (grandi, giallo)
- Level name label ("SCUOLA", "CITTÀ", etc.)
- Score display
- Auto-advance timer (3s)

**3.2 scripts/level_complete.gd**
```gdscript
extends CanvasLayer

signal completed

var level_name: String = ""

func show_complete(level: String, score: int):
    level_name = level
    $LevelLabel.text = level.to_upper()
    $ScoreLabel.text = "Score: %d" % score
    visible = true
    await get_tree().create_timer(3.0).timeout
    completed.emit()
    visible = false

func _ready():
    visible = false
```

**3.3 main.gd — Wire level_complete**
In `_advance_to_level()`:
```gdscript
$LevelComplete.show_complete(level_name, score)
```

---

### FASE 4 — Victory Screen (P2)

**4.1 ui.gd** — gia ha `$VictoryScreen` nel tree (vedi main.tscn). Serve solo wiring in `_trigger_victory()`.

---

## Assets Necessari

Se le texture per i nuovi obstacle types non esistono, usa placeholder:
- `res://assets/sprites/obstacles/ball.png` → placeholder (cerchio colorato)
- `res://assets/sprites/obstacles/backpack.png` → placeholder
- `res://assets/sprites/obstacles/tree.png` → placeholder
- `res://assets/sprites/obstacles/rock.png` → placeholder
- `res://assets/sprites/obstacles/crater.png` → placeholder
- `res://assets/sprites/obstacles/asteroid.png` → placeholder

---

## Commit Strategy

1. Commit FASE 1 separato (core wiring) — **PR for architecture review**
2. Commit FASE 2 separato (entity types) — **PR for architecture review**
3. Commit FASE 3+4 insieme — **PR for architecture review**

Io (Piotr) review ogni PR prima merge. Non fare merge senza mio sign-off. 🔒

---

## Test Plan (per Goksu QA)

1. Start game → verify "SCUOLA" level intro shows
2. Collect kids → verify score increases
3. Reach 500 pts → verify transition to "CITTÀ"
4. Verify background palette changes (grigio invece di giallo/blu)
5. Reach 1500 pts → verify transition to "BOSCO"
6. Verify green palette
7. Reach 3000 pts → verify transition to "LUNA"
8. Verify dark/purple palette
9. Reach 5000 pts → verify victory screen
10. Test all 5 power-up types collectible
11. Test double_deck hitbox wider
12. Test rockets auto-destroy obstacles
13. Test fireworks clear screen

---

_Aggiornato: 2026-04-18 16:53 — Piotr_
