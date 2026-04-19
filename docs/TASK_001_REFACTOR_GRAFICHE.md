# TASK: Refinements Grafiche — Kids, Ken, Bus

## Feature
Migliorare la resa visiva dei tre elementi core del gioco: Kids (bambini da raccogliere), Ken (driver sprite), Bus (scuolabus giallo). Attualmente sono minimali/poco definiti e non trasmettono "carineria" richiesta per un gioco per bambini.

## Obiettivo
I bambini (target 4-10 anni) devono riconoscere immediatamente:
- Chi sono i personaggi da raccogliere (kids con aspetto friendly, glow visibile)
- Che Ken è il personaggio iconico di Hokuto no Ken (sprite riconoscibile)
- Che il veicolo è uno scuolabus giallo (colori e forma chiara)

## Criteri di Successo
- [ ] Kids visibili con glow giallo/arancione, animazione "braccia alzate" in loop
- [ ] Ken visibile nel bus con sprite riconoscibile (capelli rossi, fascia in fronte)  
- [ ] Bus chiaramente uno scuolabus giallo (non un autobus generico)
- [ ] Kids raccolti mostrano feedback visivo (breve animazione/suono)
- [ ] Tutti i 4 scenari (city/scuola/bosco/luna) hanno kids stilisticamente coerenti

## Dipendenze
- [x] Codice sorgente index.html disponibile in main (commit ae79519)
- [ ] nessuna — si può iniziare subito

## Output Atteso
- File: `index.html` aggiornato con CSS/JS modificato
- URL di test: https://niccolocoppo88.github.io/ken-bus-game/

## Criteri QA
**Come Goksu verifica:**
1. Apri il gioco in Chrome/Safari
2. Verifica che i kids abbiano glow visibile E animazione
3. Verifica che Ken sia riconoscibile (capelli rossi, fascia)  
4. Verifica che il bus sia giallo e sembri uno scuolabus
5. Gioca 30 secondi — raccogli 2-3 kids e verifica feedback visivo
6. Testa su mobile se possibile (viewport 375px)

## Formato Asset
- Kids: emoji/sprite 40x40px, glow CSS (box-shadow: 0 0 15px #ffcc00)
- Ken: emoji/sprite 30x50px, colori Hokuto (rosso/giallo)
- Bus: 90x50px, giallo (#FFD700) con strisce rosse

## Note
- Il codice è inline in index.html — cercare "kid", "ken", "bus" nel JS
- Usare emoji nativi dove possible per evitare asset esterni
- Mantenere performance — glow/animation devono essere CSS, non JS pesante

---

**Assegnato a:** Thomas  
**Status:** TODO  
**Creato il:** 2026-04-19  
**Approvato da:** Elisa
