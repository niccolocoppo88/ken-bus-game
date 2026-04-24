# TASK: OST Anime per Ken Bus Adventure

## Feature
Aggiungere due tracce OST anime al gioco:
1. **Tough Boy (Opening Hokuto no Ken)** — video `2Y2VzSY1HIg` — per gameplay normale
2. **Raoh Ending Theme** — per boss fight Raoh

## Obiettivo
Il gioco deve avere musiche anime epiche come sottofondo. Toggle on/off con pulsante. Durante il boss fight con Raoh, la OST cambia in tema epico del villain.

## Criteri di Successo
- [ ] Pulsante "TOUGH BOY" toggle play/pause la OST
- [ ] Tough Boy OST = `2Y2VzSY1HIg`
- [ ] Durante boss fight Raoh, OST cambia in tema epico (video `oF4JrSOqJfk` o equivalente)
- [ ] Volume appropriato (35%) senza stuttering
- [ ] Nessun autoplay problematico (rispetta browser policies)

## Dipendenze
- [x] Git merge main completato
- [x] Repository accessibile

## Output Atteso
- `index.html` aggiornato con nuovi video ID
- Logica toggle per play/pause
- Logica swap OST per boss fight

## Criteri QA
- Goksu verifica: quando clicchi il pulsante 🔊 TOUGH BOY, parte l'opening anime
- Goksu verifica: quando entri nel boss fight con Raoh, l'OST cambia automaticamente
- Goksu verifica: volume non troppo alto, musica si sente ma non copre effetti sonori

## Formato Asset (se applicable)
- YouTube video IDs:
  - Tough Boy Opening: `2Y2VzSY1HIg`
  - Raoh Theme (cercare alternativo se `oF4JrSOqJfk` non è il tema corretto)

## Note
Il video ID `oF4JrSOqJfk` potrebbe non essere esattamente il tema di Raoh. Verificare con Elisa/Goksu se serve un video diverso. Come fallback, usare lo stesso Tough Boy anche per Raoh (epico comunque).
