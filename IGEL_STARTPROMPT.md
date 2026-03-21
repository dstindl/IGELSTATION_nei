# Igelpflegestation Pro — Kontext-Prompt für neuen Chat

Ich entwickle **Igelpflegestation Pro** — eine Single-File React PWA (`index.html`) für Igelrettungsstationen.

## Schritt 1: Lies zuerst diese Dateien
Bitte lese zu Beginn **immer** folgende Dateien aus `/mnt/user-data/uploads/`:
1. `index.html` — die aktuelle App (enthält alle Komponenten, Versionsstand, Changelog)
2. `PROJEKTDOKU_all.md` — vollständige Projektdokumentation (Architektur, Design-System, Regeln, Fallstricke)

---

## Stack
- React 18 + Babel Standalone 7.23.5 · Firebase 10.7.1 · Tailwind CSS CDN · DM Sans/Mono
- Deployment: GitHub Pages → `dstindl.github.io/IGELSTATION_nei`

## ZIP-Befehl (bei JEDER Lieferung)
```bash
cd /home/claude/igelstation && rm -f /home/claude/Igelstation.zip
zip /home/claude/Igelstation.zip index.html service-worker.js \
  icon-192.png icon-512.png deploy.sh update.sh PROJEKTDOKU_all.md IGEL_STARTPROMPT.md
```

## PRE-FLIGHT Balance-Check
```bash
python3 -c "import re; f=open('/home/claude/igelstation/index.html').read(); s=re.search(r'<script type=\"text/babel\">(.*?)</script>',f,re.DOTALL).group(1); print('Braces:',s.count('{')-s.count('}'),'Parens:',s.count('(')-s.count(')'))"
```

## State-Check
```bash
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

## Aktueller Stand: v2.5.00

### Anwesenheitsplan (v2.5.00 — Grundgerüst implementiert)
**Was läuft:** Tab-Navigation Meine Woche/Team, Zeitband, Team-Grid, Detail-Sheet, Edit-View, Firestore-Write, Menü-Kachel  
**Noch offen:**
- Tages-Karten-Liste (Entwurf B) als 3. Tab "Meine Einträge"
- Admin-Einstellungsseite (Schichtzeiten, Mindestbesetzung, Bundesland)
- Feiertage-API (openholidaysapi.org → `feiertage/2026_NW`)
- Planvorlage für Admins

**Neue Firestore Collections:**
- `anwesenheit` · DocId: `{uid}_{YYYY-MM-DD}_{fruh|spat}`
- `planConfig/settings`
- `feiertage/2026_NW`

### Offene Roadmap (nach Anwesenheitsplan)
- Import-Funktion (konzept_import_v2.html)
- completedApplications++ korrekt aus Pflegeplan quittieren
- Toleranz/Tagesbeginn/Ende in App-Einstellungen (Admin, persistent)

## Kritische Regeln
- Inline-Komponenten → `renderX()` Funktion
- `padStart` verboten in Template-Literals → `(n<10?'0':'')+n`
- SVG camelCase: `strokeWidth`, `strokeLinecap`
- `serverTimestamp()` NIE in Arrays → `new Date().toISOString()`
- str_replace: Neuen State ADDIEREN, nie substituieren

## Design: #e8e5e1 Seite · #fff Karten 1.5px #c9c5c1 · shadow 0 8px 28px rgba(28,25,23,.18)
