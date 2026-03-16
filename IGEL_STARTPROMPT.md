# Igelpflegestation Pro — Kontext-Prompt für neuen Chat

Ich entwickle **Igelpflegestation Pro** — eine Single-File React PWA (`index.html`) für Igelrettungsstationen.

## Schritt 1: Lies zuerst diese Dateien
Bitte lese zu Beginn **immer** folgende Dateien aus `/mnt/user-data/uploads/`:
1. `index.html` — die aktuelle App (enthält alle Komponenten, Versionsstand, Changelog)
2. `PROJEKTDOKU_all.md` — vollständige Projektdokumentation (Architektur, Design-System, Regeln, Fallstricke)

Aus diesen beiden Dateien leitest du den aktuellen Versionsstand, alle kritischen Regeln und den Entwicklungsstand ab. Frage mich **nicht** nach weiterem Kontext — alles steht darin.

---

## Stack (Kurzreferenz)
- React 18 + Babel Standalone 7.23.5 (cdnjs) — kein Build-Step
- Firebase 10.7.1 (Auth + Firestore), Projekt: `igelstation-3c3db`
- Tailwind CSS CDN (Legacy), DM Sans/Mono Fonts, jsQR, QRCode.js
- Deployment: GitHub Pages → `dstindl.github.io/IGELSTATION_nei`

---

## ZIP-Regel (KRITISCH — bei JEDER Lieferung)

Das Ergebnis wird **immer** als `Igelstation.zip` bereitgestellt — auch wenn nur eine kleine Änderung gemacht wurde.

### ZIP-Inhalt (flach, keine Unterordner):
| Datei | Beschreibung |
|-------|-------------|
| `index.html` | Haupt-App |
| `service-worker.js` | Offline-Cache |
| `icon-192.png` | PWA-Icon |
| `icon-512.png` | PWA-Icon |
| `deploy.sh` | GitHub Pages Ersteinrichtung |
| `update.sh` | Update-Deployment |
| `PROJEKTDOKU_all.md` | **Immer aktualisiert mitliefern** |
| `IGEL_STARTPROMPT.md` | **Immer aktualisiert mitliefern** |

**Nicht im ZIP (ab v2.4.07):**
- ~~`igelpflegestation-vX_X_XX-altDB.html`~~ — entfernt, unnötig
- ~~`KONZEPT_IGELBESTAND_DASHBOARD.md`~~ — entfernt, veraltet
- Keine anderen Konzept-Markdown-Dateien

### ZIP-Befehl:
```bash
cd /home/claude/igelstation && rm -f /home/claude/Igelstation.zip
zip /home/claude/Igelstation.zip index.html service-worker.js \
  icon-192.png icon-512.png deploy.sh update.sh PROJEKTDOKU_all.md IGEL_STARTPROMPT.md
```

---

## Konzept-Regel

Konzepte werden **immer als interaktives HTML** bereitgestellt — mit echten Phone-Mockups, Hover-States und allen Screens. Kein PDF, kein Screenshot, kein Markdown.

Konzepte zeigen mindestens:
- Lese-Modus (Ansicht)
- Edit-Modus (Bearbeitung)
- Neu anlegen
- Anmerkungen zu Design-Änderungen

---

## Versionen-Pflicht (bei JEDER Änderung alle 5 Stellen!)

1. **Changelog-Array** im JSX (neuen Eintrag am Anfang einfügen, Anker auf alten Eintrag!)
2. **LoadingScreen** `>vX.X.XX</div>` im HTML-Splash
3. **Menü-Footer** `>Version X.X.XX</div>` (class="msheet-version")
4. **Changelog-Header** `Version X.X.XX · Cloud-basierte...` im JSX
5. **Service Worker** Cache-Name `igelpflegestation-vX.X.XX`

Balance-Check nach jeder Änderung:
```python
import re
with open('index.html','r') as f: c=f.read()
s=re.search(r'<script type="text/babel">(.*?)</script>',c,re.DOTALL).group(1)
print("Braces: %d, Parens: %d" % (s.count('{')-s.count('}'), s.count('(')-s.count(')')))
# Beide Werte müssen 0 sein. Sonst Spinner/Whitescreen!
```

---

## Projektdokumentation aktuell halten

Die `PROJEKTDOKU_all.md` muss bei **jedem Versionswechsel** aktualisiert werden:
- Neues Feature beschreiben
- Versionshistorie ergänzen
- Neue Fallstricke eintragen
- Design-System-Ergänzungen dokumentieren

---

## Kritische Regeln (Kurzreferenz)

### Whitescreen-Häufigste Ursachen:
1. `const filtered` fehlt vor `return` nach Refactoring einer Listenkomponente
2. Inline-Komponente `const X = ()=>` innerhalb anderer Komponente → als `renderX()` Funktion
3. HTML-String mit `<tags>` via `dangerouslySetInnerHTML` → JSX-Children übergeben
4. `padStart(2,'0')` in Template-Literal `${}` → String-Verkettung
5. SVG-Attribute mit Bindestrichen (`stroke-width`) → camelCase (`strokeWidth`)
6. `useState` in `.map()` Callback → auf Top-Level heben

### Immer:
- `serverTimestamp()` **nie** in Firestore-Arrays → `new Date().toISOString()`
- Neue Komponenten **vor `MedikamentDB`** einfügen
- `onClose` immer `history.back()` — nie direkt State setzen
- `igelMenuOpen()` immer mit Parameter

### Design-System (warm stone — ab v2.4.x Standard):
- Hintergrund: `#fafaf8` | Karten: `#fff` | Rahmen: `#e7e5e4`
- Primär: `#1c1917` | Labels: `#a8a29e` (9px, uppercase, 700)
- Karten: borderRadius 14, border `1px solid #e7e5e4`, boxShadow `0 2px 8px rgba(28,25,23,.07)`
- Plus-Button: schwarzes Kästchen (borderRadius 10, bg #1c1917)
- Zurück-Button: runder Kreis (borderRadius 50%, bg #f5f5f4)
- Segmented Controls: bg #e7e5e4, aktiv bg #1c1917
- Sticky Save-Bar: bg #fff, borderTop, flex gap 8px
- Löschen: Bottom-Sheet, nicht Modal
