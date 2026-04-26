# TASKS — Ken Bus Adventure

> **Stato:** TODO = non iniziato | In Progress = in corso | Done = completato
> **Ultimo aggiornamento:** 2026-04-26

---

## Progetto: Ken Bus Adventure HTML5

| # | Task | Status | Assignee | Criteri Done | Dep |
|---|------|--------|----------|---------------|-----|
| 1 | Refinements grafiche (kids, Ken, bus) | **Done** | Thomas | Kids glow visibile, Ken riconoscibile, bus look scuolabus ✅ | Template: `docs/TASK_001_REFACTOR_GRAFICHE.md` |
| 2 | Level transition fix | **Done** | Thomas | Level avanza solo con kids raccolti, no timer ✅ | 1 |
| 3 | QA finale prima di shipping | **Done** | Goksu | QA visivo passato su Chrome ✅ | Refinements |

---

## Come aggiornare questo file

1. Quando inizi un task → cambia status in "In Progress" + aggiungi data
2. Quando finisci → status "Done" + data completamento
3. Dopo ogni milestone → aggiorna in GitHub

---

## Log Attività

| Data | Chi | Cosa |
|------|-----|------|
| 4 | Movimento player + boss | **TODO** | Thomas | Player si muove in tutte le direzioni, boss dx/sx | — |
| 5 | Fix asset visivi | **TODO** | Thomas | Sprite Kids/ostacoli visibili, nessuna X | — |

## Log Attività

| Data | Chi | Cosa |
|------|-----|------|
| 2026-04-26 | Elisa | Aggiornato TASKS.md — task 4+5 per movimento e asset |
| 2026-04-19 | Thomas | Aggiunto index.html source a main (commit ae79519) |
| 2026-04-19 | Thomas | **Refinements completati** — kids glow+animation, Ken visible, school bus stripes (commit 1f6b029) |
| 2026-04-19 | Thomas | **Level transition fix** — rimosso timer trigger, solo kids-based (commit 3edcaf4) |
| 2026-04-19 | Goksu | **QA Tasks 1+2 PASSED** — code verification done |
| 2026-04-19 | Thomas | **TASK 3 marked Done** — tutti i task completati |
| 2026-04-19 | Elisa | **VISUAL QA COMPLETED** — mmx vision confirms gameplay screenshot: kids counter 0/8, yellow bus with red-hat driver (Ken!), glow effects, parallax background ✅ |
| 2026-04-19 | Elisa | **SHIPPED** — gioco live su https://niccolocoppo88.github.io/ken-bus-game/ |
