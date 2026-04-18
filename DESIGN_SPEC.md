# Ken Bus Adventure — Design Spec v1.0
**Author:** Piotr (Architecture)  
**Date:** 2026-04-18  
**Status:** DRAFT — In Review  
**Linear:** CLA-93

---

## 1. Overview

**Typology:** 2D Side-scrolling Action Game (Single-player, Web HTML5)
**Core Loop:** Bus scrolls automatically right → Ken punches obstacles → collect kids → survive to end of level
**Target:** Children (visual clarity, simple controls) + absurdist humor (adult appeal)

**Key Design Pillars:**
1. **Legibility** — Every element is instantly recognizable at a glance (kids = yellow helmet, obstacles = red)
2. **Juice** — Punch effects, screen shake, particle bursts on every impact
3. **Absurdism** — Ken's stoic face while driving a school bus is the joke

---

## 2. Visual & Rendering

### 2.1 Resolution & Scaling
- **Base resolution:** 1280×720 (16:9)
- **Scaling:** SetStretchMode(Expand) — scales to fit viewport, keeps aspect ratio

### 2.2 Color Palette
| Element | Color | Hex |
|---|---|---|
| Background sky | Cyan-blue | #87CEEB |
| Bus body | Yellow | #FFD700 |
| Ken | White gi + brown hair | #FFFFFF / #3D2314 |
| Kids | Yellow helmet | #FFFF00 |
| Obstacles | Red warning | #FF4444 |
| Power-up glow | Gold | #FFD700 |

### 2.3 Scenes & Levels

**4 Levels (Scenario):**
1. **Scuola** — School zone: 7:00 AM, blue sky, school building
2. **Città** — Urban: traffic, cars, billboards
3. **Bosco** — Forest: green trees, wildlife, narrow road
4. **Luna** — Space: purple sky, craters, floating debris

Each level: 1 screen width of background tiling horizontally, procedurally generated, difficulty scales over 180s.

### 2.4 Sprites & Animation

**Ken:**
- Idle: leaning forward, fists ready
- Punch: 3-frame animation (wind-up, extend, retract) — 0.4s total
- Punch cooldown: 1.5s (visual gray-out)

**Bus:** Wheels spin tied to scroll speed, body bobs on punch (juice)

**Kids:** Wave animation (2 frames), collected = shrink + fly toward bus

**Obstacles:** 4 types (car, barrier, cone, billboard). Hit = explode into particles + screen shake 0.1s

**Power-ups:** Float with sine wave bob, gold glow aura

### 2.5 UI

**HUD:**
- Top-left: Kids collected (icon + number)
- Top-right: Score
- Top-center: Lives (hearts)
- Bottom-center: Active power-up slot

**Screens:**
- Start: Title + TAP TO START
- Game Over: Final score + kids saved + RETRY
- Level Complete: Score tally + NEXT LEVEL

---

## 3. Simulation / Physics

### 3.1 Scroll
- Auto-scroll speed: 150 px/s base (+5% every 30s per level)
- Horizontal only, bus Y fixed

### 3.2 Collision
- Rectangle-based Area2D, hitboxes slightly smaller than visuals (forgiving)
- 5 layers: Bus, Obstacles, Kids, Power-ups, Punch hitbox

### 3.3 Punch Mechanic
- Tap/click anywhere → Ken punches
- Hitbox: 128×128px rectangle in front of bus, active 0.2s
- Destroys obstacle on contact, 1.5s cooldown
- Does NOT affect kids or power-ups

### 3.4 Obstacles
- Spawn off-screen right, scroll left at bus speed
- Variety by level (cars/bags/cones for Scuola, cars/taxis/barriers for Città, etc.)

### 3.5 Kids
- Spawn on road ahead of bus, stand + wave
- Missed = stays for next pass
- Max 5 kids on screen at once

### 3.6 Power-up System
| Power-up | Effect | Duration |
|---|---|---|
| 🚀 Rocket | Bus speed ×2 | 5s |
| 🛡️ Shield | Invincible | 8s |
| ⚡ Turbo | Speed ×1.5 + invincible | 6s |
| 🎆 Fireworks | Clear all obstacles | Instant |
| 🚌 Double Deck | Wider bus (easier collect) | 10s |

Only 1 active at a time, replaces current.

---

## 4. Audio

| Sound | Trigger |
|---|---|
| Punch hit | Obstacle destroyed |
| Kid collected | Kid enters bus hitbox |
| Power-up activate | Power-up collected |
| Game over | 3rd obstacle hit |
| Level complete | Timer reaches 0 |

No background music for MVP (P2).

---

## 5. Architecture

### 5.1 Project Structure
```
ken-bus-game/
├── project.godot
├── export_presets.cfg
├── scenes/
│   ├── main.tscn
│   ├── bus.tscn
│   ├── obstacle/ (car, barrier, cone, billboard variants)
│   ├── kid/kid.tscn
│   ├── powerup/ (rocket, shield, turbo, fireworks, doubledeck)
│   ├── level/ (scuola, citta, bosco, luna variants)
│   └── ui/ (hud, start_screen, game_over)
├── scripts/
│   ├── main.gd (state machine, spawning)
│   ├── bus.gd (movement, punch)
│   ├── obstacle.gd
│   ├── kid.gd
│   ├── powerup.gd
│   ├── level.gd
│   ├── hud.gd
│   └── audio_manager.gd
├── assets/
│   ├── sprites/
│   ├── backgrounds/
│   ├── audio/
│   └── fonts/
└── README.md
```

### 5.2 State Machine
INTRO → PLAYING → PAUSED → GAME_OVER → LEVEL_COMPLETE → (next level or INTRO)

### 5.3 Architecture Review Points
1. Area2D signals for collisions (not raycasts) — easier to tune
2. Spawner is separate node from Bus (Bus = visuals + input only)
3. Object pooling for obstacles (pre-instantiate 20, reuse)
4. CPUParticles2D for particles (HTML5 target)
5. 4 separate level scenes sharing level.gd base

---

### 5.4 Architecture Clarifications (Piotr, 2026-04-18)

**Speed Progression:**
```
0-30s:   1.00x → 150 px/s
30-60s:  1.05x → 157 px/s
60-90s:  1.10x → 165 px/s
90-120s: 1.15x → 172 px/s
120-150s: 1.20x → 180 px/s
150-180s: 1.25x → 187 px/s
```

**Spawn Rate Progression:**
Base interval 2.0s, -0.1s ogni 30s (min 0.8s).

**Punch Hitbox Implementation:**
- Bus node has child Area2D `PunchHitbox`
- On tap/click: `PunchHitbox.monitor = true` for 0.2s
- `area_entered(body)` → destroy obstacle, screen shake
- After 0.2s: `monitor = false`, start 1.5s cooldown

**PAUSED State Trigger:**
- ESC key or tap/click on mobile toggles PAUSED
- Timer pauses during PAUSED, resumes on unpause
- State transitions: PLAYING ↔ PAUSED

**Object Pool Pattern:**
```gdscript
const POOL_SIZE = 20
var obstacle_pool: Array[Area2D] = []

func get_obstacle() -> Area2D:
    for obs in obstacle_pool:
        if not obs.visible:
            return obs
    # Overflow: instantiate new
    var overflow = obstacle_scene.instantiate()
    add_child(overflow)
    obstacle_pool.append(overflow)
    return overflow
```

---

## 6. Milestone

| Date | Deliverable | Owner |
|---|---|---|
| 2026-04-18 12:00 | Design Spec | Piotr ✅ |
| 2026-04-18 15:00 | Mockups / Prototype | Thomas |
| 2026-04-18 22:00 | 1 level playable | Thomas |
| 2026-04-19 22:00 | All levels + audio | Thomas |
| 2026-04-20 18:00 | QA + GitHub Pages deploy | Goksu |
| 2026-04-20 20:00 | **M1 SHIPPED** | — |

---

## 7. Open Questions for Thomas

1. Sprite sheets — AI generation or pixel art budget?
2. Audio SFX source — TTS generators or library?
3. Godot project exists in repo or start from scratch?
4. GitHub Pages setup — custom domain? Single HTML or full export?

---

*Design Spec v1.0 — Piotr, 2026-04-18*
