# Ken Bus Adventure — CI/CD Design for GitHub Pages
**Author**: Piotr (Architecture)
**Date**: 2026-04-18
**Purpose**: Architettura pipeline di delivery per pubblicazione automatica su GitHub Pages dopo MVP.

---

## 1. Overview

Dopo che Thomas completa il gioco e Goksu fa QA, il gioco deve essere pubblicato automaticamente su GitHub Pages ad ogni push sul branch `main`.

**Target**: `https://niccolocoppo88.github.io/ken-bus-game/`

---

## 2. GitHub Actions Pipeline

```yaml
# .github/workflows/deploy.yml

name: Deploy to GitHub Pages

on:
  push:
    branches: [main]
  workflow_dispatch:  # Manual trigger

jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      pages: write
      id-token: write

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Godot
        uses: barоло拿去/use-godot@v4
        with:
          godot-version: 4.2.stable
          export-presets: godot-export

      - name: Install Chrome (for headless export validation)
        run: |
          wget -q -O chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
          sudo dpkg -i chrome.deb || true
          sudo apt-get install -f -y

      - name: Get Godot export templates
        run: |
          godot --headless --export-templates /tmp/templates.tpz
          mkdir -p ~/.local/share/godot/export_templates/4.2.stable/
          unzip -o /tmp/templates.tpz -d ~/.local/share/godot/export_templates/

      - name: Export HTML5
        run: |
          godot --headless --export-release "HTML5" build/index.html
        env:
          GODOT_KEY: ${{ secrets.GODOT_KEY }}

      - name: Validate build
        run: |
          # Check index.html exists and has reasonable size
          test -f build/index.html
          SIZE=$(stat -c%s build/index.html)
          if [ "$SIZE" -lt 10000 ]; then exit 1; fi

      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: build/

  post-deploy:
    runs-on: ubuntu-latest
    needs: deploy
    steps:
      - name: Notify team
        run: |
          echo "✅ Ken Bus Adventure deployed to GitHub Pages"
```

---

## 3. Repository Settings (manual setup required by Nico)

1. **Settings → Pages → Source**: GitHub Actions
2. **Settings → Pages → Custom domain** (optional): `kenbus.niccolocoppo.com` se acquistato
3. **Branch protection**: richiedere PR review per `main` prima del merge diretto

---

## 4. Godot Export Presets

```ini
# export_presets.cfg (must be in repo — non-secret)

[preset.0]

name="HTML5"
platform="HTML5"
runnable=true
custom_features=""
export_filter="all_resources"
include_filter=""
exclude_filter=""
export_path="build/index.html"
encryption_include_filters=""
encryption_exclude_filters=""
encrypt_pck=false
encrypt_directory=false

[preset.0.options]

custom_template/debug=""
custom_template/release=""
variant/extensions_support=false
vram_texture_compression/for_desktop=false
vram_texture_compression/for_mobile=false
html/export_icon=true
html/custom_html_shell=""
html/head_include=""
html/canvas_resize_policy=2
html/focus_canvas_on_start=true
html/experimental_virtual_keyboard=false
progressive_web_app/enabled=true
progressive_web_app/offline_page=""
progressive_web_app/display=1
progressive_web_app/orientation=0
progressive_web_app/icon_144x144=""
progressive_web_app/icon_180x180=""
progressive_web_app/icon_512x512=""
progressive_web_app/background_color=Color(0, 0, 0, 1)
```

---

## 5. Directory Structure After Export

```
build/
├── index.html          ← entry point
├── index.js
├── index.wasm
├── index.pck           ← game assets bundled
└── index.apple-touch-icon.png
```

---

## 6. Progressive Web App (PWA)

Il gioco verrà consegnato come **PWA** — installabile su mobile/desktop.
L'utente può "installare" Ken Bus come app dal browser.

**Vantaggi**:
- Icona sulla home screen
- Fullscreen senza browser chrome
- Offline capability (post-MVP P2)

---

## 7. Rollback Strategy

Se una build è broken:

```bash
# Rollback a commit precedente via GitHub Actions
git revert HEAD
git push origin main
# L'actions pipeline rigenera la build dalla versione precedente
```

Per emergenze: **Settings → Pages → GitHub Actions → Disable** temporaneamente.

---

## 8. Performance Budget

| Asset | Max Size | Note |
|---|---|---|
| index.html | < 50 KB | Gzip |
| index.wasm | < 15 MB | Godot engine |
| index.pck | < 10 MB | Assets + scripts |
| **Total** | **< 25 MB** | Load target: < 8s su 4G |

---

_Aggiornato: 2026-04-18 — Piotr_
