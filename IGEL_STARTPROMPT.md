# Igelpflegestation Pro — Kontext-Prompt für neuen Chat

Ich entwickle **Igelpflegestation Pro** — eine Single-File React PWA (`index.html`) für Igelrettungsstationen.

## Schritt 1: Lies zuerst diese Dateien
Bitte lese zu Beginn **immer** folgende Dateien aus `/mnt/user-data/uploads/`:
1. `index.html` — die aktuelle App (enthält alle Komponenten, Versionsstand, Changelog)
2. `PROJEKTDOKU_all.md` — vollständige Projektdokumentation (Architektur, Regeln, Komponenten, Fallstricke)

Aus diesen beiden Dateien leitest du den aktuellen Versionsstand, alle kritischen Regeln und den Entwicklungsstand ab. Frage mich **nicht** nach weiterem Kontext — alles steht darin.

---

## Stack (Kurzreferenz)
- React 18 + Babel Standalone 7.23.5 (cdnjs) — kein Build-Step
- Firebase 10.7.1 (Auth + Firestore), Projekt: `igelstation-3c3db`
- Tailwind CSS CDN, jsQR, QRCode.js, DM Sans/Mono Fonts
- Deployment: GitHub Pages → `dstindl.github.io/IGELSTATION_nei`

---

## ZIP-Regel (KRITISCH — bei JEDER Lieferung)
Das Ergebnis wird **immer** als `Igelstation.zip` bereitgestellt.

### ZIP-Inhalt (flach, keine Unterordner):
| Datei | Beschreibung |
|-------|-------------|
| `index.html` | Haupt-App (identisch mit altDB-Datei) |
| `igelpflegestation-vX_X_XX-altDB.html` | Benannte Version (nur aktuelle, keine alten) |
| `service-worker.js` | Offline-Cache |
| `icon-192.png` | PWA-Icon |
| `icon-512.png` | PWA-Icon |
| `deploy.sh` | GitHub Pages Ersteinrichtung |
| `update.sh` | Update-Deployment |
| `IGEL_STARTPROMPT.md` | **Chat-Startprompt (immer aktuell halten!)** |
| `PROJEKTDOKU_all.md` | **Projektdokumentation (immer aktuell halten!)** |

### ZIP-Befehl:
```bash
cd /home/claude/igelstation && rm -f /home/claude/Igelstation.zip
zip /home/claude/Igelstation.zip index.html igelpflegestation-vX_X_XX-altDB.html \
  service-worker.js icon-192.png icon-512.png deploy.sh update.sh PROJEKTDOKU_all.md IGEL_STARTPROMPT.md
```

---

## Versionen-Pflicht (bei JEDER Änderung alle 5 Stellen!)
1. Changelog-Array im JSX (am Anfang einfügen, Anker auf älteren Eintrag!)
2. LoadingScreen: `>vX.X.XX</div>` im HTML-Splash
3. Menü-Footer: `>Version X.X.XX</div>` (class="msheet-version")
4. Changelog-Header: `Version X.X.XX · Cloud-basierte...` im JSX
5. Service Worker Cache-Name: `igelpflegestation-vX.X.XX`

Nach jeder Änderung **Balance-Check**:
```python
import re
with open('index.html','r') as f: c=f.read()
s=re.search(r'<script type="text/babel">(.*?)</script>',c,re.DOTALL).group(1)
print(f"Braces: {s.count('{')-s.count('}')}, Parens: {s.count('(')-s.count(')')}")
```
→ Beide Werte müssen **0** sein. Sonst Spinner!

---

## Kritische Regeln (nie vergessen)
- **NIEMALS** `data:image/base64` direkt in JSX → Babel-Crash
- **NIEMALS** doppelte `const`-Deklaration im selben Scope
- **NIEMALS** doppelte `className` auf demselben Element
- **NIEMALS** `history.back()` in Menü-Seiten-onClose → popstate-Konflikt
- **NIEMALS** `orderBy()` ohne Firestore-Index → client-seitig sortieren
- **NIEMALS** `serverTimestamp()` in Firestore-Arrays → `new Date().toISOString()`
- **NIEMALS** beim Version-Bump Anker auf neue Version setzen → zerstört Einträge
- Neue Komponenten **immer vor `UserProfile`** einfügen
- `app_todos` = EIN Dokument `main` mit `items[]` Array (NICHT separate Dokumente)

---

## Projektdoku aktuell halten
Die `PROJEKTDOKU_all.md` im ZIP muss nach **jeder Session** aktualisiert werden:
- Neue Features dokumentieren
- Geänderte Datenstrukturen nachführen
- Neue Fallstricke eintragen
- Versionshistorie ergänzen

Format: Markdown, vollständig, selbsterklärend — damit der nächste Chat-Start ohne Rückfragen möglich ist.
