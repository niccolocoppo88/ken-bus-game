# Ken Bus Adventure — Power-Up Architecture Guide
**Author:** Piotr (Architect)
**Date:** 2026-04-18
**Status:** ACTIVE — For Thomas
**Based on:** DESIGN_SPEC.md v1.0 + LEVEL_IMPLEMENTATION_GUIDE.md

---

## Overview

Questa guida dettaglia l'architettura tecnica per i 3 power-up mancanti nel full game. Ogni power-up modifica lo stato del bus in modo specifico — serve un pattern pulito per gestirli senza incasinare `bus.gd`.

---

## Power-Up Architecture

### Design Principle

**State Modifier Pattern** — i power-up NON creano entity separate, modificano il comportamento del bus esistente. Il bus ha uno stato base che viene alterato temporaneamente.

```
PowerUpManager (Node)
├── activate(powerup_type: String)
├── deactivate(powerup_type: String)
└── is_active(powerup_type: String) -> bool
```

Il `PowerUpManager` è un child di `bus.tscn` e gestisce tutti i modifier.

### Bus State Interface

```gdscript
# bus.gd — stato base
var base_speed: float = 150.0
var speed_multiplier: float = 1.0
var is_invulnerable: bool = false
var hitbox_width_modifier: float = 1.0

# State modifier methods (chiamate da PowerUpManager)
func apply_speed_boost(multiplier: float, duration: float) -> void:
    speed_multiplier = multiplier
    $BoostTimer.wait_time = duration
    $BoostTimer.start()

func apply_invulnerability(duration: float) -> void:
    is_invulnerable = true
    $InvulnTimer.wait_time = duration
    $InvulnTimer.start()

func apply_hitbox_wider(multiplier: float, duration: float) -> void:
    hitbox_width_modifier = multiplier
    $HitboxTimer.wait_time = duration
    $HitboxTimer.start()

# Called when timer expires
func _on_speed_boost_expired():
    speed_multiplier = 1.0
    # Remove green aura effect

func _on_invuln_expired():
    is_invulnerable = false
    # Remove shield visual

func _on_hitbox_expired():
    hitbox_width_modifier = 1.0
    # Remove double-deck visual
```

---

## Power-Up 1: Bus 2 Piani (Double Deck)

### Effect
- Hitbox diventa 2x più largo (più facile raccogliere kids)
- Visual: bus sprite cambia in versione 2 piani
- Durata: 12 secondi

### Implementation

```gdscript
# powerup_manager.gd
func activate_double_deck():
    var bus = get_parent()
    bus.apply_hitbox_wider(2.0, 12.0)
    
    # Visual: swap sprite
    $Sprite2D.texture = preload("res://assets/bus_double_deck.png")
    $Sprite2D.scale = Vector2(1.0, 2.0)  # Stretches vertically
    
    # Emit signal for audio
    emit_signal("powerup_activated", "double_deck")
    
    is_active_map["double_deck"] = true

func _on_double_deck_expired():
    var bus = get_parent()
    bus.hitbox_width_modifier = 1.0
    
    # Restore sprite
    $Sprite2D.texture = preload("res://assets/bus.png")
    $Sprite2D.scale = Vector2(1.0, 1.0)
    
    is_active_map["double_deck"] = false
```

### Collision Shape Update

```gdscript
# Quando hitbox_width_modifier cambia, aggiorna la collision shape
func _update_hitbox_width():
    var base_w = 80.0  # Base hitbox width
    $HitboxCollision.shape.size.x = base_w * hitbox_width_modifier
```

---

## Power-Up 2: Razzi (Rockets)

### Effect
- Fiamme visuali escono dal retro del bus
- Tutti gli ostacoli sullo schermo vengono distrutti automaticamente al contatto
- Durata: 10 secondi
- Razzi NON bloccano damage — solo distruggono ostacoli che toccano il bus

### Implementation

```gdscript
# powerup_manager.gd
func activate_rockets():
    var bus = get_parent()
    bus.apply_speed_boost(2.0, 10.0)
    
    # Visual: mostra fiamme
    $RocketFlames.visible = true
    $RocketFlames.play("burning")
    
    # Add speed trail effect
    $SpeedTrail.visible = true
    
    emit_signal("powerup_activated", "rockets")
    is_active_map["rockets"] = true

func _on_rockets_expired():
    $RocketFlames.visible = false
    $SpeedTrail.visible = false
    is_active_map["rockets"] = false

# In bus.gd — obstacles hit during rockets are auto-destroyed
func _on_obstacle_hit(obs: Area2D):
    if powerup_manager.is_active("rockets"):
        obs.destroy()  # Instant destroy, no punch cooldown
        spawn_explosion(obs.global_position)
        add_score(50)  # Bonus points for auto-destroy
```

### Rocket Flame Visual

- `rocket_flame.tscn`: Sprite animato con 4 frame loop
- Position: offset -60px dal centro del bus (dietro)
- Colors: orange (#FF6B00) → yellow (#FFD700) gradient
- Particles: CPUParticles2D per sparks

---

## Power-Up 3: Fuochi d'Artificio (Fireworks)

### Effect
- Esplode TUTTI gli ostacoli sullo schermo istantaneamente
- One-shot: si consuma al momento dell'attivazione
- Effetto visivo: esplosione colorata multi-punto

### Implementation

```gdscript
# powerup_manager.gd
func activate_fireworks():
    var bus = get_parent()
    
    # Find all visible obstacles
    var obstacles = get_tree().get_nodes_in_group("obstacles")
    
    for obs in obstacles:
        if obs.visible:
            # Staggered explosion for visual effect
            create_explosion_at(obs.global_position, i * 0.1)
            obs.queue_free()
    
    # Big central flash
    create_firework_burst(bus.global_position)
    
    emit_signal("powerup_activated", "fireworks")
    is_active_map["fireworks"] = false  # Consumed immediately

func create_explosion_at(pos: Vector2, delay: float):
    await get_tree().create_timer(delay).timeout
    var explosion = explosion_scene.instantiate()
    explosion.global_position = pos
    get_parent().get_parent().add_child(explosion)
    
    # Random color for each explosion
    var colors = [Color("#FF4444"), Color("#FFD700"), Color("#00FF00"), Color("#FF69B4")]
    explosion.modulate = colors[randi() % colors.size()]

func create_firework_burst(pos: Vector2):
    # Central big explosion
    var burst = firework_burst_scene.instantiate()
    burst.global_position = pos
    get_parent().get_parent().add_child(burst)
```

### Firework Burst Scene

- 12 explosion points in circle pattern
- Each point: particle burst with random color
- Sound: layered explosion (low + high freq for "firework" feel)
- Duration: 0.8s total animation

---

## Power-Up Spawn System

### Spawn Logic

```gdscript
# main.gd — powerup spawning
const POWERUP_SPAWN_INTERVAL_BASE = 20.0  # seconds
const POWERUP_SCENES = {
    "shield": "res://scenes/powerup/shield.tscn",
    "turbo": "res://scenes/powerup/turbo.tscn",
    "double_deck": "res://scenes/powerup/double_deck.tscn",
    "rockets": "res://scenes/powerup/rockets.tscn",
    "fireworks": "res://scenes/powerup/fireworks.tscn"
}

var powerup_spawn_timer: float = POWERUP_SPAWN_INTERVAL_BASE

func _process(delta: float):
    if state != STATE.PLAYING:
        return
    
    powerup_spawn_timer -= delta
    if powerup_spawn_timer <= 0:
        spawn_powerup_random()
        powerup_spawn_timer = POWERUP_SPAWN_INTERVAL_BASE

func spawn_powerup_random():
    var types = POWERUP_SCENES.keys()
    var chosen = types[randi() % types.size()]
    var scene = load(POWERUP_SCENES[chosen])
    
    var pu = scene.instantiate()
    pu.type = chosen
    pu.position = Vector2(1400, randf_range(200, 500))  # Spawn right, random Y
    $PowerUps.add_child(pu)
```

### Power-Up Frequency by Level

| Level | Spawn Interval | Notes |
|---|---|---|
| Scuola | 20s | Normal |
| Città | 18s | Slightly more frequent |
| Bosco | 12s | High (kids more frequent) |
| Luna | 30s | Low (challenging) |

---

## Power-Up Icon Design

Each power-up has a distinct SVG icon:

| Power-Up | Icon Description | Glow Color |
|---|---|---|
| Shield | Scudo blu/bianco con croce | #4488FF |
| Turbo | Fulmine giallo | #FFD700 |
| Double Deck | Bus a 2 piani stilizzato | #00AAFF |
| Rockets | Due razzi incrociati | #FF4400 |
| Fireworks | Stella multicolore esplosa | #FF69B4 |

Icons should be 64x64px, stored in `assets/powerup_icons/`.

---

## State Machine: Power-Up Active

```
┌─────────────────────────────────────────────────────┐
│                    BUS STATE                        │
├─────────────────────────────────────────────────────┤
│ Speed:    150 px/s * speed_multiplier              │
│ Invuln:   is_invulnerable                          │
│ Hitbox:   base_width * hitbox_width_modifier       │
│ Flame:    rocket_flames.visible                    │
└─────────────────────────────────────────────────────┘
         ↑ apply_        ↑ apply_        ↑ apply_
         │ speed_boost  │ invuln       │ hitbox_wider
         │              │              │
    ┌────┴───┐    ┌────┴───┐    ┌────┴───┐
    │ ROCKET │    │ SHIELD │    │ DOUBLE │
    │ ACTIVE │    │ ACTIVE │    │  DECK  │
    │ +2.0x  │    │ INVULN │    │ 2x WIDE│
    └────┬───┘    └────┬───┘    └────┬───┘
         │ Timer      │ Timer       │ Timer
         ↓ expires    ↓ expires     ↓ expires
    speed_mult       is_invuln      hitbox_mod
    = 1.0            = false        = 1.0
```

---

## Collision Handling with Power-Ups

```gdscript
# bus.gd — _on_body_entered(body: Node)
func _on_body_entered(body: Node):
    if body.is_in_group("obstacle"):
        if is_invulnerable:
            # Shield/rocket active — destroy without damage
            body.destroy()
            spawn_explosion(body.global_position)
        else:
            # Normal hit — lose life
            take_damage()
    
    elif body.is_in_group("kid"):
        collect_kid(body)
    
    elif body.is_in_group("powerup"):
        activate_powerup(body.type)
        body.collect()
```

---

## Audio for Power-Ups

| Event | Sound | Duration |
|---|---|---|
| Collect power-up | Coin-like chime + type-specific | 0.3s |
| Double deck activate | Bus engine + ascend | 0.5s |
| Rockets activate | Whoosh + ignition | 0.4s |
| Fireworks activate | Multi-pop firework burst | 0.8s |
| Shield expire | Shield dissolve shimmer | 0.3s |
| Rockets expire | Flame dying | 0.4s |

---

## Files to Create

| File | Purpose |
|---|---|
| `scripts/powerup_manager.gd` | Central power-up state management |
| `scenes/powerup/double_deck.tscn` | Double deck bus power-up scene |
| `scenes/powerup/rockets.tscn` | Rocket power-up scene |
| `scenes/powerup/fireworks.tscn` | Firework power-up scene |
| `scenes/effects/explosion.tscn` | Reused explosion effect |
| `scenes/effects/firework_burst.tscn` | Multi-point burst effect |
| `assets/powerup_icons/` | 5 SVG icons |

---

_Aggiornato: 2026-04-18 13:08 — Piotr_