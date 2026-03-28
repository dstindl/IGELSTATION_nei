# Igelpflegestation Pro — Kontext-Prompt für neuen Chat

Ich entwickle **Igelpflegestation Pro** — eine Single-File React PWA (`index.html`) für Igelrettungsstationen.

## Schritt 1: Lies zuerst diese Dateien
Bitte lese zu Beginn **immer** folgende Dateien aus `/mnt/user-data/uploads/`:
1. `index.html` — die aktuelle App (v2.5.06, alle Komponenten + Changelog)
2. `PROJEKTDOKU_all.md` — vollständige Projektdokumentation

---

## Stack
- React 18 + Babel Standalone 7.23.5 · Firebase 10.7.1 · Tailwind CSS CDN · DM Sans/Mono
- Deployment: GitHub Pages → `dstindl.github.io/IGELSTATION_nei`
- Firebase Projekt: `igelstation-3c3db`

## ZIP-Befehl (bei JEDER Lieferung)
```bash
cd /home/claude/igelstation && rm -f /home/claude/Igelstation.zip
zip /home/claude/Igelstation.zip index.html service-worker.js \
  icon-192.png icon-512.png deploy.sh update.sh PROJEKTDOKU_all.md IGEL_STARTPROMPT.md firestore.rules
```

## PRE-FLIGHT Checks (PFLICHT vor jeder Lieferung)
```bash
# 1. Balance
python3 -c "import re; f=open('/home/claude/igelstation/index.html').read(); s=re.search(r'<script type=\"text/babel\">(.*?)</script>',f,re.DOTALL).group(1); print('Braces:',s.count('{')-s.count('}'),'Parens:',s.count('(')-s.count(')'))"

# 2. States
python3 -c "
c=open('/home/claude/igelstation/index.html').read()
states=['showDesignSpec','showBatchBearbeitung','showDatenbankHub','showMedikamentDB',
        'showDiagnoseDB','showTreatmentDB','showUserMgmt','showSettings','showChangelog',
        'showTodoList','showProfile','showAddForm','showQRScanner','showPflegeplan',
        'showBestand','showAnwesenheit']
issues=[s for s in states if ('const ['+s) not in c]
print('OK' if not issues else 'FEHLT:'+str(issues))
"
```

---

## Aktueller Stand: v2.5.06

### Anwesenheitsplan — vollständig implementiert
**Komponente:** `AnwesenheitsplanMain` (646+ Zeilen)
**Navigation:** Menü-Kachel → `window.__igelAnwesenheit()` → `showAnwesenheit` State

**Features:**
- Tab: Meine Woche (Zeitband: Balken Früh/Spät, Schraffur Abweichung, Feiertag-Overlay)
- Tab: Team-Übersicht (Coverage-Zeile amber/rot, Pfleger-Grid, amber Outline eigene Zellen)
- Tages-Detail Bottom-Sheet
- Edit-View: Schicht/Art (Geplant/Real/Krank/Urlaub/Abwesend), Zeiten, Notiz
- Multi-Day Kalender: Monat mit Multiselekt, Batch-Write
- Status-Dots: gefüllte Farben grün/orange/rot/blau/lila

**Neue Firestore Collections:**
- `anwesenheit` · DocId: `{uid}_{YYYY-MM-DD}_{fruh|spat}`
- `planConfig/settings` · `feiertage/2026_NW`

**Firestore Rules:** `firestore.rules` — muss in Firebase Console eingefügt werden

### Noch offen (v2.5.07+)
- Admin-Einstellungsseite (Schichtzeiten, Mindestbesetzung, Bundesland)
- Feiertage-API (openholidaysapi.org → `feiertage/{year}_{bundesland}`)
- Planvorlage für Admins

### Weitere offene Roadmap
- Import-Funktion (konzept_import_v2.html)
- completedApplications++ aus Pflegeplan quittieren
- Toleranz/Tagesbeginn/Ende in App-Einstellungen persistent

---

## Kritische Regeln (Kurzreferenz)
- Inline-Komponenten → `renderX()` Funktion
- `padStart` VERBOTEN in Template-Literals → `(n<10?'0':'')+n`
- SVG camelCase: `strokeWidth`, `strokeLinecap`
- `serverTimestamp()` NIE in Arrays → `new Date().toISOString()`
- `str_replace`: Neuen State ADDIEREN, nie substituieren
- Nach jedem `str_replace`: Balance-Check + State-Check

## Design: #e8e5e1 Seite · #fff Karten 1.5px #c9c5c1 · shadow 0 8px 28px rgba(28,25,23,.18)

## _backState Priorität
Menü → showDatabaseDialog → showTreatmentDB → showMedikamentDB → showDiagnoseDB → showCSVImport → showDatenbankHub → showBatchBearbeitung → **showAnwesenheit** → showUserMgmt → showSettings → showTodoList → showChangelog → showDesignSpec → showQRScanner → showQuickView → showProfile → showPflegeplan → showBestand → showAddForm → selected → App-Beenden-Dialog
