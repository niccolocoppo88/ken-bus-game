# PIANO AZIONE TEAM — Ken Bus Adventure
**Versione:** 2.0 (aggiornata da retro 2026-04-22)
**Team:** Elisa (PO+PM+Coordinatrice), Thomas (Coder), Goksu (QA), Nico (Decision Maker)

---

## 🗂 Ruoli

| Ruolo | Persona | Responsabilità |
|-------|---------|----------------|
| PO + PM + Coordinatrice | Elisa | Brief, task creation, priorità, coordinamento |
| Architect | Piotr | Architecture decisions, technical reviews |
| Coder | Thomas | Implementazione feature, commit, push |
| QA | Goksu | Code QA, visual QA, verification |
| Decision Maker | Nico | Approvazioni finali, fix/blocchi, direction |

**Regola:** Non bypassare i ruoli. Se Thomas ha dubbi → chiede a Elisa. Elisa non può implementare al posto di Thomas senza autorizzazione.

---

## 🔄 Pipeline Standard

```
Brief (Elisa) → TASK_TEMPLATE.md → Architecture Review (Piotr, se complesso) → Implementazione (Thomas) → Code QA (Goksu) → Visual QA (Elisa/Goksu) → Deploy (Elisa)
```

### Quando coinvolgere Piotr
- Task complessi con refactoring architetturale
- Nuove feature che richiedono cambi strutturali
- Fix per problemi di performance o scalability
- NON serve per: bug fix semplici, refactor grafici, QA tasks

### Step dettagliato

1. **Brief** — Elisa descrive cosa serve in Discord con context + vincoli tecnologici
2. **TASK_TEMPLATE.md** — compilato PRIMA di iniziare, anche per fix semplici
3. **Implementazione** — Thomas implementa su branch corretto (main = source)
4. **Git pull** — ogni sessione INIZIA con `git fetch origin && git merge origin/main`
5. **Code QA** — Goksu verifica via curl/grep che le modifiche siano nel codice
6. **Visual QA** — screenshot con Playwright + `mmx vision describe`
7. **Deploy** — push su gh-pages, update TASKS.md

---

## 🛠 Tool giusti per ogni job

| Job | Tool corretto | Note |
|-----|---------------|------|
| Code inspection | `curl` + `grep` | Verifica stringhe/funzioni nel codice live |
| Screenshot analysis | `mmx vision describe` | Tool primario per immagini |
| Screenshot gameplay | Playwright + Chrome headless | `npx playwright screenshot` |
| Visual QA screenshot | Chrome headless + save | `--screenshot` flag |
| HTTP verification | `lightpanda fetch` | Verifica HTML/CSS/JS delivery |
| File check | `git show` + `curl` | Verifica contenuto su GitHub |

---

## 🚫 Regole NON negoziabili

### Comunicazione
- **Una risposta strutturata** > 10 messaggi in thread
- **Mai `sessions_send` per cose urgenti** — timeout troppo frequenti, usare Discord mention diretto
- **GitHub è unica source of truth** — niente Linear, niente doc fuori da repo
- **Non taggare 100 volte** — se devi chiedere qualcosa, scrivilo una volta con @mention

### Git workflow
- Ogni sessione INIZIA con: `git fetch origin && git merge origin/main`
- `main` = source code (HTML/CSS/JS inline)
- `gh-pages` = GitHub Pages deploy (copy di main/index.html)
- Commit freq: ogni milestone significativo, non ogni micro-cambio

### Task flow
- TASK_TEMPLATE.md compilato PRIMA di implementare
- Status update su TASKS.md DOPO ogni commit
- mai iniziare implementazione senza brief scritto

---

## 📁 Struttura Repo

```
ken-bus-game/
├── index.html           # Source principale (main branch)
├── docs/
│   ├── DESIGN.md        # Design document (source of truth)
│   ├── RETRO_*.md       # Retrospettive
│   ├── TASK_*.md        # Task template compilati
│   └── *_ARCHITECTURE.md # Architetture tecniche
├── TASKS.md             # Status task — aggiornato dopo ogni milestone
└── gh-pages/           # Deploy (non toccare a mano)
```

---

## 📋 QA Checklist (prima di shippare)

- [ ] Code QA: verificato con curl che le modifiche sono nel file
- [ ] Visual QA: screenshot gameplay con Playwright + analizzato con mmx vision
- [ ] TASKS.md aggiornato (status Done)
- [ ] Commit pushato su main
- [ ] gh-pages aggiornato (se serve)
- [ ] Notifica team su Discord

---

## 🔧 Come fare Visual QA

```bash
# 1. Screenshot title screen
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless --disable-gpu --screenshot=/tmp/title.png --window-size=1280,720 "https://niccolocoppo88.github.io/ken-bus-game/"

# 2. Screenshot gameplay (click AVVIA)
cd /tmp && node -e "
const { chromium } = require('playwright');
(async () => {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();
  await page.goto('https://niccolocoppo88.github.io/ken-bus-game/');
  await page.waitForTimeout(2000);
  await page.click('#avvia');
  await page.waitForTimeout(3000);
  await page.screenshot({ path: '/tmp/gameplay.png' });
  await browser.close();
})();
"

# 3. Analizza con mmx vision
mmx vision describe /tmp/title.png
mmx vision describe /tmp/gameplay.png
```

---

## 📅 Log azioni (aggiornare dopo ogni milestone)

| Data | Chi | Cosa |
|------|-----|------|
| 2026-04-19 | Elisa | Creato TASKS.md, rimosso Linear |
| 2026-04-19 | Thomas | Refinements grafiche, level transition fix |
| 2026-04-19 | Goksu | Code QA pass |
| 2026-04-19 | Elisa | Visual QA con mmx vision — SHIPPED |
| 2026-04-22 | Elisa | Design document + retro team |
| 2026-04-22 | Elisa | Aggiornato piano azione (v2.0) |

---

*Document aggiornato da Elisa — 2026-04-22*