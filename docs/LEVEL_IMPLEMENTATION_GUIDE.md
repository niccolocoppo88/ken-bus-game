# Ken Bus Adventure — Level Implementation Guide
**Author:** Piotr (Architect)
**Date:** 2026-04-18
**Status:** ACTIVE — For Thomas
**Based on:** DESIGN_SPEC.md v1.0 + arch_review_ken-bus.md

---

## Overview

Questa guida detail il comportamento specifico di ogni scenario (level) per il full game. I 4 level condividono `level.gd` come base ma hanno variazioni in: palette colori, obstacle types, background layer, soundtrack mood.

---

## Level Overview

| Level | Name | Duration | Base Speed | Obstacle Types | Background Palette | Power-up Frequency |
|---|---|---|---|---|---|---|
| 1 | Scuola | 180s | 150 px/s | car, barrier, cone | Blue sky, yellow school | Normal |
| 2 | Città | 180s | 157 px/s | taxi, billboard, barrier | Gray concrete, neon signs | Normal |
| 3 | Bosco | 180s | 165 px/s | tree, rock, bird | Green canopy, brown earth | High (kids more frequent) |
| 4 | Luna | 180s | 172 px/s | crater, satellite, asteroid | Purple/black, white craters | Low (more challenging) |

Speed progression è globale (tabella speed progression nel DESIGN_SPEC.md) — ogni level inizia alla speed corrispondente al tempo elapsed nel game completo (Level 2 non inizia da 150px/s, ma dalla speed che il game aveva a 180s).

---

## Level 1: Scuola (School Zone)

**Visual Palette:**
- Sky: #87CEEB (cyan-blue)
- Ground: #8B4513 (brown road)
- Buildings: #FFD700 (yellow school), #4169E1 (blue doors)
- Trees: #228B22 (forest green)
- Accent: #FF4444 (danger red for obstacles)

**Background Layers:**
- Layer 1 (sky): 15 px/s — clouds, sun
- Layer 2 (buildings): 80 px/s — school building, trees
- Layer 3 (road): 180 px/s — road markings, kids on sidewalk

**Obstacle Spawn Weights:**
- car: 40%
- barrier: 30%
- cone: 30%

**Kids Behavior:**
- Spawn rate: 1 ogni 4-6s
- Visual: kid with yellow helmet + backpack
- Animation: wave arms when bus approaches

**Power-up Frequency:** Normal (1 ogni 15-20s)

---

## Level 2: Città (Urban Zone)

**Visual Palette:**
- Sky: #708090 (slate gray, slightly overcast)
- Ground: #404040 (dark asphalt)
- Buildings: #696969 (gray concrete), #FF69B4 (neon signs for shops)
- Accent: #FFD700 (taxi yellow), #FF4444 (traffic lights)

**Background Layers:**
- Layer 1 (sky): 15 px/s — few clouds, buildings silhouette
- Layer 2 (buildings): 80 px/s — tall buildings, billboards, shop signs
- Layer 3 (road): 180 px/s — road, traffic lights, manhole covers

**Obstacle Spawn Weights:**
- taxi: 35%
- billboard: 35%
- barrier: 30%

**Kids Behavior:**
- Spawn rate: 1 ogni 5-7s (meno che scuola — più traffico, meno kids)
- Visual: kid with backpack, standing on sidewalk
- Animation: look left/right before crossing

**Power-up Frequency:** Normal (1 ogni 15-20s)

---

## Level 3: Bosco (Forest Zone)

**Visual Palette:**
- Sky: #87CEEB (blue sky seen through tree canopy)
- Ground: #228B22 (grass), #654321 (dirt path)
- Trees: #006400 (dark green canopy), #8B4513 (brown trunks)
- Accent: #90EE90 (light green highlights)

**Background Layers:**
- Layer 1 (sky/canopy): 15 px/s — light rays through leaves
- Layer 2 (trees): 80 px/s — tree trunks, branches
- Layer 3 (road): 180 px/s — dirt path, rocks, wildlife

**Obstacle Spawn Weights:**
- tree: 40%
- rock: 30%
- bird: 30% (volando da lato)

**Kids Behavior:**
- Spawn rate: 1 ogni 3-5s (più kids nel bosco — zona residenziale)
- Visual: kid with cap + fishing rod or nature explorer hat
- Animation: wave, point at animals

**Power-up Frequency:** Alta (1 ogni 10-15s) — compensare difficoltà bosco

**Special:**
- Background ha birds che attraversano lo schermo ( sprite separato, layer 2)
- Occasional firefly particles alla sera (dopo 90s elapsed)

---

## Level 4: Luna (Space Zone)

**Visual Palette:**
- Sky: #0D0D1A (deep black-purple)
- Ground: #808080 (gray moon dust)
- Stars: #FFFFFF (white dots, parallax lento)
- Accent: #9370DB (purple craters), #FFD700 (gold artifacts)

**Background Layers:**
- Layer 1 (stars): 5 px/s — star field with occasional shooting star
- Layer 2 (craters): 40 px/s — moon surface craters
- Layer 3 (dust): 180 px/s — moon dust trail

**Obstacle Spawn Weights:**
- crater: 30%
- satellite: 35% (fluttua in aria, colpisce bus più in alto)
- asteroid: 35%

**Kids Behavior:**
- Spawn rate: 1 ogni 8-12s (kids rari sulla luna — astronauti)
- Visual: small astronaut figure with helmet glow
- Animation: float slightly (low gravity)

**Power-up Frequency:** Bassa (1 ogni 25-30s) — sfida max

**Special:**
- Low gravity: kids oscillano su/giù con sine wave (ampiezza 5px, periodo 2s)
- Screen shake diverso (più "lunar" — oscillazione più lenta)
- Star field parallax Layer 0 (ancora più lento, 8 px/s)

---

## Cross-Level Architecture

### Level Transitions

```
Level Complete Screen → 3s → Next Level Intro → 2s → PLAYING
```

Transition sequence:
1. `LEVEL_COMPLETE` state → show score tally
2. After 3s → fade to black
3. Load next level scene (background preload during tally)
4. Fade in → show level name ("LUNA") for 2s
5. Fade out → `PLAYING`

### Kids Pool (Shared Across Levels)

I kids sono shared resource, non level-specific. Quando si cambia level:
- Clear todos i kids attivi
- Reset spawn timer
- Mantieni kids collected counter

### Speed Continuity

La speed è continua, non resetta tra livelli. Dopo 180s (fine level 1), la speed è 157 px/s e level 2 inizia a quella speed.

### Power-up State

Power-up attivi vengono mantenuti attraverso level transition (se non scaduti). Timer continua durante level transition.

---

## Sound Design per Level (P2 — post MVP)

| Level | Music Mood | SFX Ambient |
|---|---|---|
| Scuola | Cheerful, school bell occasionally | Traffic hum, birds |
| Città | Urban beat, synth | Car horns, neon buzz |
| Bosco | Calm, nature | Wind, crickets, birds |
| Luna | Space ambient, low drone | Astronaut radio static, wind |

---

## Implementation Notes

1. **Level scenes:** `scenes/level/scuola.tscn`, `scenes/level/citta.tscn`, `scenes/level/bosco.tscn`, `scenes/level/luna.tscn`
2. **Base level script:** `scripts/level.gd` con variabili esportate per customization per level
3. **Obstacle types:** Ogni level ha il suo subset (weight dict passato da level.gd)
4. **Background parallax:** 3 layer per tutti i level, stesso script con color palette parameterizzabile

---

_Aggiornato: 2026-04-18 12:08_