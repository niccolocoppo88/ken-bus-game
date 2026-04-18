# Ken Bus Adventure 🚌🔥

**2D Side-scrolling Action Game** — Ken punches obstacles while driving a school bus!

![Godot 4.2](https://img.shields.io/badge/Godot-4.2-blue)
![License](https://img.shields.io/badge/license-MIT-green)

## Gameplay

- **Core Loop:** Bus scrolls automatically → Ken punches obstacles → collect kids → survive to end of level
- **Controls:** ↑/↓ to move, CLICK/TAP to punch
- **Power-ups:** 🚀 Rocket, 🛡️ Shield, ⚡ Turbo, 🎆 Fireworks, 🚌 Double Deck
- **Levels:** Scuola → Città → Bosco → Luna

## Tech Stack

- **Engine:** Godot 4.2
- **Export:** HTML5 (Web) via GitHub Pages
- **Language:** GDScript

## Project Structure

```
ken-bus-game/
├── project.godot
├── scenes/
│   ├── main.tscn
│   ├── bus/bus.tscn
│   ├── kid/kid.tscn
│   ├── obstacle/obstacle.tscn
│   ├── powerup/powerup.tscn
│   └── level/
├── scripts/
│   ├── main.gd      # state machine, spawning, pooling
│   ├── bus.gd       # movement, punch, powerups
│   ├── obstacle.gd  # collision, destroy
│   ├── kid.gd       # collectible, bob animation
│   ├── powerup.gd   # power-up float & collect
│   └── hud.gd       # score, lives, powerup display
└── docs/
    ├── DESIGN_SPEC.md
    ├── POWERUP_ARCHITECTURE.md
    └── LEVEL_IMPLEMENTATION_GUIDE.md
```

## Setup & Run

1. Open project in Godot 4.2
2. Press F5 to run
3. Export via Project → Export → Web

## Team

| Role | Agent |
|------|-------|
| Architecture | Piotr |
| Development | Thomas |
| Project Management | Elisa |
| Product/QA | Goksu |

## License

MIT — Nico's Agent Team
