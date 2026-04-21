# RETROSPETTIVA — Ken Bus Adventure
**Data:** 2026-04-22
**Team:** Elisa (PO+PM), Thomas (Coder), Goksu (QA), Nico (Decision Maker)

---

## 🟢 Cosa è andato bene

### 1. Passaggio a GitHub + TASKS.md
- Rimuovere Linear è stata la decisione giusta — GitHub è source of truth
- TASKS.md chiaro e visibile a tutti
- Commit history trackable

### 2.分工 Ruoli chiari
- Elisa: PO + PM + coordinamento
- Thomas: implementation
- Goksu: QA
- Nico: decision maker finale
- Funzionava bene quando rispettato

### 3. TASK_TEMPLATE.md
- Template compilato prima di implementare → no ambiguity
- Bypassato solo quando task era semplice (TASK 2 bug fix)

### 4. mmx vision per Visual QA
- Tool `mmx vision describe` funziona per analisi screenshot
- Alternative migliore del tool `image` nativo (che broken)

### 5. Code QA via curl
- Verifica stringhe/funzioni nel codice senza browser → efficiente
- Goksu ha fatto un buon lavoro di verifica

---

## 🔴 Cosa è andato male

### 1. Comunicazione in loop
- Reazioni Discord e messaggi multipli per la stessa cosa
- 20+ messaggi in pochi minuti quando bastava 1
- **Rimedio:** una risposta strutturata > 10 reactions

### 2. sessions_send per cose critiche
- Timeout frequenti, messaggi persi
- Regola: solo per cose non-bloccanti, mai per urgency
- **Rimedio:** Discord mention diretto + file su GitHub

### 3. Image tool broken
- Tool nativo `image` dava sempre errore "chat content is empty (2013)"
- Tutti i subagent fallivano
- **Rimedio:** usare `mmx vision describe` come backup

### 4. Sourcemancanza clear su main vs gh-pages
- Commits su entrambi i branch senza chiarezza
- Thomas ha pushato index.html da gh-pages a main (ok) ma confusione iniziale
- **Rimedio:** main = source, gh-pages = deploy. Mai mixed.

### 5. Git pull iniziale saltato
- Ogni sessione deve iniziare con `git fetch origin && git merge origin/main`
- Thomas ha iniziato senza, ha causato confusione su quale codice usare
- **Rimedio:** enforcement nel piano azione

### 6. Richiesta visual QA ambigua
- "Goksu deve vedere ogni livello" → richiesto screenshot di ogni level
- Ma Goksu in sandbox non può fare screenshot dinamici (solo title screen)
- **Rimedio:** definire sempre cosa serve con vincoli tecnologici chiari

---

## 🟡 Lezioni apprese

### Pipeline efficace
```
Brief → TASK_TEMPLATE.md → Implementation → Code QA (curl) → Visual QA (mmx vision) → Deploy
```

### Tool giusti per ogni job
| Job | Tool |
|-----|------|
| Code inspection | curl + grep |
| Screenshot analysis | `mmx vision describe` |
| Live browser | Playwright + Chrome headless |
| Visual rendering check | Chrome headless screenshot |

### Cosa non fare
- Non usare `sessions_send` per cose urgenti
- Non mandare 10 messaggi quando 1 basta
- Non chiedere a un agente di fare qualcosa fuori dal suo sandbox

---

## 🔧 Azioni di miglioramento

### Per Elisa (PO)
- [ ] Quando briefo un task, includere sempre vincoli tecnologici
- [ ] Una risposta strutturata > 10 messaggi in thread
- [ ] Prima di spedire un task, verificare che sia fattibile con tools disponibili

### Per il team
- [ ] Git pull all'inizio di ogni sessione (non saltare mai)
- [ ] Non usare `sessions_send` per cose che richiedono risposta rapida
- [ ] Se un tool non funziona, reporting immediato + workaround

### Per Nico (Decision Maker)
- [ ] Quando chiedi qualcosa, completa la frase ( TASK 2 si è tagliato)
- [ ] Per playtest reale, servono headless browser su host — chiedere in anticipo se necessario

---

## 📋 Piano azione aggiornato

1. **Git pull all'inizio** — non negotiation
2. **Una risposta** invece di 10 reactions — rispetto per il thread
3. **mmx vision** come tool primario per analisi immagini
4. **GitHub come unica source of truth** — niente più Linear
5. **sessions_send** solo per non-urgent async

---

*Retro condotta da Elisa — 2026-04-22*