# Branch Strategy — Ken Bus Adventure

## Branch Model

```
main        → source of truth (development)
   ↓
gh-pages   → deploy only (mirrors main)
```

**Rule:** `gh-pages` is ALWAYS a fast-forward mirror of `main`. Never commit directly to `gh-pages`.

---

## Deploy Flow

```
Developer pushes to main
        ↓
CI runs on main (braces balance + syntax check)
        ↓
CI checks main === gh-pages SHA
        ↓
If out of sync → CI FAILS (see sync enforcement below)
        ↓
main merged/deployed → gh-pages updated via: git push origin main:gh-pages
```

---

## CI Checks (`.github/workflows/ci-checks.yml`)

### 1. JS Syntax + Brace Balance (`validate-js`)

```yaml
- Extracts JS from <script> tag
- Strips strings/comments
- Counts { and } — must match
- Runs node --check on extracted.js
```

**Fails if:** unbalanced braces or syntax error in extracted JS.

### 2. Branch Sync Check (`check-branch-sync`)

```yaml
- Runs on: every push to main
- Compares: origin/main SHA vs origin/gh-pages SHA
- If different → CI FAILS with message:
  "ERROR: main and gh-pages are out of sync!
   Fix: git push origin main:gh-pages"
```

**Rule:** always verify sync before closing a ticket.

### 3. Playwright Smoke Test (`smoke-test`)

```javascript
// smoke_test_game.js — 5 checks
1. Title screen visible (#avvia button)
2. Click AVVIA → game starts
3. Title screen hidden (state = playing)
4. Canvas renders
5. Kids counter visible (game is running)
```

**Fails if:** any check returns false. Exit code 1 on failure, 0 on success.

---

## Team Rules

### Before Closing Any Ticket

1. Verify `main === gh-pages`:
   ```bash
   git log origin/main origin/gh-pages --oneline
   ```
2. If out of sync → push: `git push origin main:gh-pages`
3. Confirm CI green before declaring "done"

### Before Merging to main

1. Run local checks:
   ```bash
   # Brace balance
   python3 -c "
   import re; c=open('index.html').read(); m=re.search(r'<script>(.*?)</script>',c,re.DOTALL)
   j=m.group(1); j=re.sub(r'\"[^\"]*\"','',j); j=re.sub(r\"'[^']*'\",'',j); j=re.sub(r'//.*','',j)
   print(f'{{ = {j.count(\"{\")}, }} = {j.count(\"}\")}')"
   
   # Syntax check
   node --check extracted.js
   ```

2. Verify CI is green on GitHub Actions

---

## Files Reference

| File | Purpose |
|------|---------|
| `index.html` | Game source (single HTML file) |
| `.github/workflows/ci-checks.yml` | CI pipeline (braces + sync + smoke) |
| `smoke_test_game.js` | Playwright E2E smoke test |
| `DESIGN_SPEC.md` | Game design specification |

---

_Doc created: 2026-04-26 — Retro Ken Bus Bug action item #4_
