# Ken Bus Adventure — M3 Fixes: Architecture Directive
**Author:** Piotr (Architect)
**Date:** 2026-04-18
**Status:** ACTIVE — For Thomas
**Based on:** LEVEL_IMPLEMENTATION_GUIDE.md + POWERUP_ARCHITECTURE.md

---

## Problema

Il codice per M3 è parzialmente scritto nei spawner ma **non è collegato**. `main.gd` non triggera mai `set_level()`. Il risultato: il gioco è bloccato per sempre su "city" con solo SHIELD e TURBO.

---

## Gap Analysis

### ✅ GIA PRESENTE (wiring mancante)

| Componente | Ha `set_level()`? | main.gd lo chiama? |
|---|---|---|
| `kid_spawner.gd` | ✅ Sì (school/city/forest/moon) | ❌ NO |
| `obstacle_spawner.gd` | ✅ Sì (school/city/forest/moon) | ❌ NO |
| `background.gd` | ✅ Sì (school/city/forest/moon) | ❌ NO |

### ❌ INCOMPLETO/MANCANTE

| Componente | Stato | Cosa manca |
|---|---|---|
| `obstacle.gd` | Solo 3 tipi (CAR_GREEN, CAR_RED, TRUCK) | Tipi level-specific (BALL, BACKPACK, TREE, ROCK, CRATER, ASTEROID, etc.) |
| `powerup.gd` | Solo SHIELD, TURBO | DOUBLE_DECK, ROCKETS, FIREWORKS |
| Level progression | Non esiste | Score thresholds → level advance |
| Level complete screen | Non esiste | UI screen con score tally |
| Powerup spawner | Solo SHIELD/TURBO | Tutti e 5 i tipi |

---

## Architettura Level Progression

### Level Order
```
school → city → forest → moon → victory
```

### Score Thresholds per Level Transition

| From | To | Score Required | Note |
|---|---|---|---|
| Start | school | 0 (automatico) | Start with school |
| school | city | 500 pts | Raccogli 10 kids = ~500 pts |
| city | forest | 1500 pts | |
| forest | moon | 3000 pts | |
| moon | victory | 5000 pts | Game complete |

### Level Advance Logic (in main.gd)

```gdscript
# Aggiungere in main.gd

# Level state
var current_level_index: int = 0
var LEVEL_ORDER = ["school", "city", "forest", "moon"]
var LEVEL_SCORES = [0, 500, 1500, 3000]  # score to reach to advance

# Level transition
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
    
    # Clear all entities
    obstacle_spawner.clear_all()
    kid_spawner.clear_all()
    powerup_spawner.clear_all()
    
    # Wire ALL spawners to new level
    obstacle_spawner.set_level(level_name)
    kid_spawner.set_level(level_name)
    background.set_level(level_name)
    
    # Update UI
    ui.show_level_intro(level_name)
    
    # Brief pause during intro
    _pause_game(3.0)

func _pause_game(duration: float):
    current_state = State.LEVEL_TRANSITION
    await get_tree().create_timer(duration).timeout
    current_state = State.PLAYING
```

---

## Estensione obstacle.gd

### Aggiungere Tipi Level-Specific

```gdscript
# obstacle.gd — estendere enum e setup()

enum Type {
    # Base (city)
    CAR_GREEN, CAR_RED, TRUCK,
    # School
    BALL, BACKPACK,
    # Forest
    TREE, ROCK,
    # Moon
    CRATER, ASTEROID
}

func setup(type: Type, speed_mult: float = 1.0):
    obstacle_type = type
    match type:
        Type.CAR_GREEN:
            sprite.texture = load("res://assets/sprites/obstacles/car_green.png")
            speed = 180.0 * speed_mult
            collision.shape.size = Vector2(60, 40)
        Type.CAR_RED:
            sprite.texture = load("res://assets/sprites/obstacles/car_red.png")
            speed = 250.0 * speed_mult
            collision.shape.size = Vector2(60, 40)
        Type.TRUCK:
            sprite.texture = load("res://assets/sprites/obstacles/truck.png")
            speed = 120.0 * speed_mult
            collision.shape.size = Vector2(90, 50)
        Type.BALL:
            sprite.texture = load("res://assets/sprites/obstacles/ball.png")
            speed = 200.0 * speed_mult
            collision.shape.size = Vector2(30, 30)
        Type.BACKPACK:
            sprite.texture = load("res://assets/sprites/obstacles/backpack.png")
            speed = 150.0 * speed_mult
            collision.shape.size = Vector2(35, 35)
        Type.TREE:
            sprite.texture = load("res://assets/sprites/obstacles/tree.png")
            speed = 100.0 * speed_mult
            collision.shape.size = Vector2(50, 80)
        Type.ROCK:
            sprite.texture = load("res://assets/sprites/obstacles/rock.png")
            speed = 140.0 * speed_mult
            collision.shape.size = Vector2(60, 45)
        Type.CRATER:
            sprite.texture = load("res://assets/sprites/obstacles/crater.png")
            speed = 160.0 * speed_mult
            collision.shape.size = Vector2(70, 30)
        Type.ASTEROID:
            sprite.texture = load("res://assets/sprites/obstacles/asteroid.png")
            speed = 220.0 * speed_mult
            collision.shape.size = Vector2(55, 55)
```

---

## Estensione powerup.gd

### Aggiungere Tipi Advanced

```gdscript
# powerup.gd — estendere enum

enum Type {
    SHIELD, TURBO,
    DOUBLE_DECK, ROCKETS, FIREWORKS  # ← AGGIUNGERE
}

func setup(type: Type, speed_mult: float = 1.0):
    powerup_type = type
    speed *= speed_mult
    velocity = Vector2(-speed, 0)
    
    match type:
        Type.SHIELD:
            sprite.modulate = Color(1.0, 0.9, 0.2)
            glow.modulate = Color(1.0, 0.9, 0.2, 0.6)
        Type.TURBO:
            sprite.modulate = Color(0.3, 1.0, 0.5)
            glow.modulate = Color(0.3, 1.0, 0.5, 0.6)
        Type.DOUBLE_DECK:   # ← AGGIUNGERE
            sprite.modulate = Color(0.2, 0.6, 1.0)
            glow.modulate = Color(0.2, 0.6, 1.0, 0.6)
        Type.ROCKETS:       # ← AGGIUNGERE
            sprite.modulate = Color(1.0, 0.3, 0.0)
            glow.modulate = Color(1.0, 0.3, 0.0, 0.6)
        Type.FIREWORKS:     # ← AGGIUNGERE
            sprite.modulate = Color(1.0, 0.4, 0.8)
            glow.modulate = Color(1.0, 0.4, 0.8, 0.6)
```

### Aggiornare powerup_spawner.gd

```gdscript
# powerup_spawner.gd — sostituire _random_type()

func _random_type() -> PowerUp.Type:
    var r = randf()
    if r < 0.20:
        return PowerUp.Type.SHIELD
    elif r < 0.40:
        return PowerUp.Type.TURBO
    elif r < 0.60:
        return PowerUp.Type.DOUBLE_DECK
    elif r < 0.80:
        return PowerUp.Type.ROCKETS
    else:
        return PowerUp.Type.FIREWORKS
```

---

## Level Complete Screen (scenes/level_complete.tscn)

### UI Flow
```
Level Complete → 3s tally → fade → next level intro → 2s → PLAYING
```

### Elements
- "LEVEL COMPLETE!" text (grandi, colorato per level)
- Score breakdown: kids collected, obstacles destroyed, bonus
- Star rating (1-3 stars based on performance)
- Auto-advance dopo 3 secondi

### Implementation

```gdscript
# level_complete.gd (script for level_complete.tscn)
extends CanvasLayer

signal completed

var level_name: String = ""

func show_level_complete(level: String, score: int, kids: int):
    level_name = level
    $LevelLabel.text = LEVEL_NAMES[level]
    $ScoreLabel.text = "Score: %d" % score
    $KidsLabel.text = "Kids: %d" % kids
    visible = true
    
    # Auto-advance after 3s
    await get_tree().create_timer(3.0).timeout
    completed.emit()
```

---

## Wiring Livello Transition in main.gd

### Aggiungere in start_game()

```gdscript
func start_game():
    current_state = State.PLAYING
    score = 0
    lives = 3
    kids_collected = 0
    kids_target = 10
    speed_multiplier = 1.0
    spawn_rate_multiplier = 1.0
    current_level_index = 0  # ← AGGIUNGERE
    
    bus.reset()
    obstacle_spawner.clear_all()
    kid_spawner.clear_all()
    powerup_spawner.clear_all()
    
    # Wire initial level
    obstacle_spawner.set_level("school")   # ← AGGIUNGERE
    kid_spawner.set_level("school")        # ← AGGIUNGERE
    background.set_level("school")          # ← AGGIUNGERE
    
    ui.show_level_intro("school")          # ← AGGIUNGERE
    
    obstacle_timer.start()
    kid_timer.start()
    powerup_timer.start()
    difficulty_timer.start()
```

### Chiamare _check_level_advancement()

In `_on_kid_collected()` e nel difficulty timer:

```gdscript
func _on_bus_kid_collected():
    kids_collected += 1
    score += 50
    ui.update_kids(kids_collected, kids_target)
    _check_level_advancement()  # ← AGGIUNGERE
    if kids_collected >= kids_target:
        kids_target += 10
        speed_multiplier += 0.1
```

---

## Priority Order (Thomas)

**FASE 1 — Core Wiring (bloccante)**
1. `main.gd` → chiama `set_level()` in `start_game()` per initial level
2. `main.gd` → aggiungere `_check_level_advancement()` + `_advance_to_level()`
3. Test: livello school si carica correttamente

**FASE 2 — Entity Types**
4. `obstacle.gd` → estendere enum con tipi level-specific
5. `powerup.gd` → estendere enum con DOUBLE_DECK, ROCKETS, FIREWORKS
6. `powerup_spawner.gd` → aggiornare `_random_type()`

**FASE 3 — Level Transitions**
7. `level_complete.tscn` + `level_complete.gd`
8. Wiring in `main.gd` → `_advance_to_level()`

**FASE 4 — Polish**
9. Level intro screen in `ui.gd`
10. Victory screen

---

## File da Modificare

| File | Azione |
|---|---|
| `scripts/main.gd` | Aggiungere level state, `_check_level_advancement()`, `_advance_to_level()`, wiring in `start_game()` |
| `scripts/obstacle.gd` | Estendere `Type` enum + `setup()` match |
| `scripts/powerup.gd` | Estendere `Type` enum + `setup()` match |
| `scripts/powerup_spawner.gd` | Aggiornare `_random_type()` per 5 tipi |
| `scenes/level_complete.tscn` | **CREARE** — screen UI |
| `scripts/level_complete.gd` | **CREARE** — logic per level complete |
| `scenes/main.tscn` | Aggiungere nodo LevelComplete |

---

_Aggiornato: 2026-04-18 16:53 — Piotr_
