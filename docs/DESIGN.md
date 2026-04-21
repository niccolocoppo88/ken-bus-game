# KEN BUS ADVENTURE — Design Document

> **Version:** 1.0 (distilled from source code, 2026-04-22)
> **Status:** Source of truth = `index.html` on GitHub

---

## 1. Concept & Vision

**KEN BUS ADVENTURE** è un endless side-scrolling game con estetica da anime Hokuto no Ken.

Il giocatore controlla un autobus giallo guidato da Ken (capelli rossi, headband) che corre attraverso scenari ispirati all'universo di Fist of the North Star. L'obiettivo è raccogliere 8 bambini per avanzare di livello, evitando ostacoli e nemici. Al livello 4 c'è il boss fight finale contro Raoh.

**Tagline:** "～北斗神拳～" (Hokuto Shinken — Fist of the North Star)

---

## 2. Visual Style

### Aesthetic
- Anime dramматичний style con effetti glow e ombre rosse
- CRT scanline overlay su title screen e pause
- Font monospace (Courier New) per tutta la UI
- Palette: nero/rosso scuro + arancione/giallo vivo per elementi chiave

### Color Palette (HUD & UI)
- **Title:** `#ffcc00` (giallo oro) su sfondo `#0a0000` (nero/rosso)
- **Buttons:** `#cc0000` (rosso) + `#ffcc00` (giallo)
- **Text shadow:** rosso + nero per profondità
- **Background:** gradient nero con scanlines

### Title Screen Elements
- `KEN BUS ADVENTURE` — glowing orange con pulse animation
- `～北斗神拳～` — subtitle rossoarancio
- `AVVIA` button — rosso con box-shadow glow
- `🔊 TOUGH BOY` — button per toggle musica
- Istruzioni: `↑↓ o W/S: muovi | SPAZIO o CLIC: pugno | ESC: pausa`

---

## 3. Gameplay

### Core Loop
1. Bus si muove automaticamente da sinistra a destra (scroll)
2. Giocatore muove bus su/giù tra 4 lane
3. Raccogliere bambini = +punti e progressione
4. Evitare/distruggere ostacoli con punch
5. Dopo 8 kids/livello → nuovo scenario + speed increase
6. Level 4 = Boss fight vs Raoh

### Mechanics
- **Lives:** 3 cuori ❤️❤️❤️, perde 1 se colpito da ostacolo o proiettile
- **Invincibility:** 1.5 secondi post-hit con flashing
- **Score:** incremento per ogni kid raccolto e ostacolo distrutto
- **Powerups:** drop随机 con effetti (shield, turbo, double deck, razzi)

### Level Progression
| Level | Scenario | Kids to Advance | Speed Multiplier |
|-------|----------|-----------------|------------------|
| 0 | City | 8 | 1.0x |
| 1 | Highway | 8 | 1.3x |
| 2 | Desert | 8 | 1.6x |
| 3 | Final | 8 | 2.0x → Boss |

### Boss Fight (Raoh)
- Appare dopo aver completato i 4 livelli
- HP: 3 colpi per sconfiggerlo
- Movement: up/down tracking
- Attacks: proiettili verticali
- Fasi: cambia pattern ogni colpo subito

---

## 4. Controls

### Desktop
- `↑/↓` o `W/S` — muovi bus su/giù
- `SPAZIO` o `CLICK` — punch attack
- `ESC` — pausa

### Mobile
- Swipe su/giù — movimento
- Doppio tap — punch
- Button `👊 PUGNO` on-screen

---

## 5. Scenarios (4)

| # | Name | Subtitle | Sky | Buildings | Road |
|---|------|----------|-----|-----------|------|
| 0 | CITTÀ | ～街～ | `#4488cc` | grey silhouettes | dark grey + yellow dashes |
| 1 | HIGHWAY | ～的高速～ | `#336699` | blue-grey | asphalt + white |
| 2 | DESERTO | ～砂漠～ | `#cc8844` | sandy pyramids | orange sand |
| 3 | FINAL | ～最終～ | `#220033` | dark ruins | dark with red accent |

---

## 6. Collectibles & Enemies

### Kids (Collectibles)
- Sprite: yellow humanoid con cuffie pink
- Glow: `shadowBlur = 20` arancione
- Animation: wave sine per braccia
- Spawn: da destra, velocità aumentata per livello

### Obstacles
- **Trucks:** grey body + red cab, verschiedene dimensioni
- **Cars:** city cars, colori vari
- **Barriers:** road work barriers

### Powerups
- **Shield:** verde sfera protettiva
- **Turbo:** boost velocità
- **Double Deck:** bus con second floor (raccoglie kids senza muovere)
- **Razzi:** attacco missile

---

## 7. Audio

### Background Music
- YouTube embed: "Tough Boy" opening theme
- Volume: 35%
- Autoplay + loop

### Sound Effects (procedural Web Audio API)
- **Punch:** 150Hz sawtooth + 80Hz square burst
- **Collect:** 660Hz + 880Hz sine blip
- **Hurt:** 100Hz sawtooth
- **Powerup:** arpeggio 440→880Hz
- **Destroy:** 200Hz + 100Hz sawtooth
- **Level Up:** fanfare 330→880Hz

---

## 8. Technical

### Stack
- HTML5 Canvas 2D (no frameworks)
- Vanilla JavaScript ES6+
- Web Audio API per sound effects
- YouTube IFrame API per background music
- CSS animations per UI elements

### Architecture
- `SCENARIOS[]` array per configurazione livelli
- Game loop via `requestAnimationFrame`
- State machine: `title → playing → paused/gameover/levelintro/bossfight/victory`
- Entity arrays: `kids_list`, `obstacles`, `powerups`

### File Structure
```
ken-bus-game/
├── index.html        # Tutto inline (HTML + CSS + JS)
├── gh-pages/         # GitHub Pages deploy
│   └── index.html
├── main/             # GitHub source branch
│   └── index.html
└── docs/
    ├── DESIGN.md     # This document
    ├── game_screenshot.png
    └── gameplay_final.png
```

---

## 9. Artwork Reference

### Ken (Player)
- Capelli rossi (drawHair)
- Headband rossa (drawHeadband)
- Body giallo (bus body)
- Driver hat rosso

### Kids
- Colore: yellow (`#ffdd00`)
- Pink headphones
- Wave animation (arms)
- Glow: orange shadowBlur 20

### Bus
- Yellow body
- Black stripe
- "SCHOOL BUS" text (quando in TASK_001 refactor)
- Shadow blur per glow effects

---

## 10. Open Issues / TODO

- YouTube video ID è placeholder (`bYbN2nyuN9Y`) — da sostituire con video reale
- Nessun sound per gameover music
- Boss fight potrebbe essere più bilanciato

---

*Document generato da Elisa — 2026-04-22*