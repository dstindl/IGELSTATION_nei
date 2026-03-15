# Igelpflegestation Pro — Projektdokumentation

**Version:** 2.3.62 | **Stand:** März 2026 | **Entwickler:** Denis-Alexander Stindl

---

## 1. Projektübersicht

Igelpflegestation Pro ist eine Progressive Web App (PWA) für Igelrettungsstationen. Vollständige digitale Verwaltung von Igelpatienten: Behandlungspläne, Medikamentengaben, Gewichtsverläufe, QR-Scanning, Mehrbenutzerverwaltung — kein Build-Step, kein App-Store, direkt im Browser.

| | |
|---|---|
| **URL** | dstindl.github.io/IGELSTATION_nei |
| **Firebase Projekt** | igelstation-3c3db |
| **Architektur** | Single-File index.html, kein Build-Step |
| **Datenhaltung** | Firestore (Echtzeit-Sync) |
| **Auth** | Firebase Auth (E-Mail + Passwort) |
| **Offline** | Service Worker, Cache-First |

---

## 2. Tech Stack

```
React 18 + Babel Standalone 7.23.5  (cdnjs — kein npm, kein Build)
Firebase 10.7.1                      Auth + Firestore
Tailwind CSS CDN                     Utility-CSS
jsQR 1.4.0                           QR-Scanning aus Kamera
QRCode.js 1.0.0                      QR-Code-Generierung
DM Sans / DM Mono                    Google Fonts
```

### Dateien im Projekt
```
index.html                           Haupt-App (alle Komponenten)
igelpflegestation-vX_X_XX-altDB.html Benannte Backup-Version (nur aktuelle)
service-worker.js                    Offline-Cache
icon-192.png / icon-512.png          PWA-Icons
deploy.sh                            GitHub Pages Ersteinrichtung
update.sh                            Update-Deployment
PROJEKTDOKU_all.md                   Diese Datei
```

### Firestore Collections
```
hedgehogs              Igelkarten (treatments[], notizen[], gewichtsverlauf[])
users                  Benutzerprofile (name, role, uid)
app_todos              Einzel-Dokument "main" mit items[] Array
treatmentDatabase      Behandlungsvorlagen (inkl. medications[])
medicationDatabase     Medikamentenstammdaten
diagnosisDatabase      Diagnosestammdaten
med_gruppen            Medikamenten-Gruppen
med_behandlungen       Behandlungs-Stammdaten
med_arten              Applikationsarten
med_haeufigkeiten      Haeufigkeitsdefinitionen
```

---

## 3. Kritische Regeln

### Babel-Constraints (Spinner-Ursachen)
- **NIEMALS** data:image/base64 direkt in JSX -> Babel-Crash
- **NIEMALS** doppelte const-Deklaration im selben Scope
- **NIEMALS** doppelte className auf demselben Element
- **NIEMALS** JSX als Wert in JS-Objekt-Literal
- **NIEMALS** Template-Literale mit einfachen Anfuehrungszeichen in ${} -> padStart(2,'0') bricht Babel! Stattdessen: (n<10?'0':'')+n
- **NIEMALS** padStart(2,'0') direkt in JSX {} Ausdruck (auch ausserhalb Template-Literals gefaehrlich)
- **NIEMALS** schliessendes </div> ohne oeffnendes im JSX
- **NIEMALS** Inline-Komponenten mit eigenem State innerhalb anderer Komponenten (fuehrt zu Re-mount bei jedem Re-render des Elternteils)
- Braces-Balance im gesamten Babel-Script muss 0 sein

### Firestore-Regeln
- serverTimestamp() nicht in Arrays -> new Date().toISOString() stattdessen
- orderBy() ohne Index -> 0 Ergebnisse -> immer client-seitig sortieren
- app_todos = EIN Dokument main mit items[] Array — keine separaten Dokumente
- arrayUnion() fuer Append auf gewichtsverlauf[]

### Navigation
- Menue-Seiten onClose: NIEMALS history.back() -> popstate-Konflikt
- Korrekt: history.replaceState({igelApp:true,level:1},'') + igelMenuOpen(false)

### Neue Komponenten
- Immer vor UserProfile einfuegen
- Version-Bump Changelog: Anker auf stabilen aelteren Eintrag — NIEMALS auf neue Version

### State-Lifting Regel (neu ab v2.3.59)
- verlaufOpen und expandedDays in TRow (innerhalb HedgehogDetail) MUESSEN in HedgehogDetail als Maps gehalten werden
- Sonst: reset bei jedem Live-Uhr-Re-render (alle 10s) -> Dropdown schliesst sich automatisch
- Pattern: const [verlaufOpenMap, setVerlaufOpenMap] = useState({})

---

## 4. Versions-Pflicht (alle 5 Stellen bei JEDER Aenderung)

1. Changelog-Array im JSX (am Anfang einfuegen)
2. LoadingScreen: >vX.X.XX</div> im HTML-Splash
3. Menue-Footer: >Version X.X.XX</div> (class="msheet-version")
4. Changelog-Header: Version X.X.XX - Cloud-basierte... im JSX
5. Service Worker: igelpflegestation-vX.X.XX in service-worker.js

### Balance-Check nach jeder Aenderung
```python
import re
with open('index.html','r') as f: c=f.read()
s=re.search(r'<script type="text/babel">(.*?)</script>',c,re.DOTALL).group(1)
print("Braces: %d, Parens: %d" % (s.count('{')-s.count('}'), s.count('(')-s.count(')')))
```
Beide Werte muessen 0 sein. Sonst Spinner!

### ZIP-Befehl (immer frisch)
```bash
cd /home/claude/igelstation && rm -f /home/claude/Igelstation.zip
zip /home/claude/Igelstation.zip index.html igelpflegestation-vX_X_XX-altDB.html \
  service-worker.js icon-192.png icon-512.png deploy.sh update.sh PROJEKTDOKU_all.md
```

---

## 5. Design System — Warm Kompakt

### Farben
```
#fafaf8   Hintergrund (Stone 50)
#ffffff   Karten, Header
#1c1917   Primaer-Aktion, Text (Stone 900)
#292524   Sekundaer (Stone 800)
#44403c   Text sekundaer
#a8a29e   Text gedimmt
#e7e5e4   Trennlinien (gestrichelt)
```

### Timeline Design F — Farbpalette
```
#f0fdf4   Mintgruen  — done-open / done-locked (erledigt)
#fefce8   Cremgelb   — due (faellig, im Toleranzfenster)
#fff1f2   Altrosa    — overdue-locked (verpasst, gesperrt)
#fafaf8   Warm Grau  — pending (noch nicht faellig)
```

### TL_* Konstanten (in Pflegeplan UND HedgehogDetail identisch definiert)
```javascript
const TL_SEG   = {'done-open':'#f0fdf4','done-locked':'#f0fdf4','due':'#fefce8','overdue-locked':'#fff1f2','pending':'#fafaf8'};
const TL_ICOL  = {'done-open':'#166634','done-locked':'#166634','due':'#ca8a04','overdue-locked':'#e11d48','pending':'#d6d3d1'};
const TL_ICON  = {'done-open':'✓','done-locked':'✓','due':'◎','overdue-locked':'●','pending':'○'};
const TL_ANIM  = {'due':'qv-pulse-amber 2.2s ease-in-out infinite','overdue-locked':'qv-pulse-red 1.8s ease-in-out infinite'};
const TL_LOCKED= {'done-locked':true,'overdue-locked':true};
const TL_CAN   = {'done-open':true,'due':true};
```

### Toleranz-Logik — 5 Zustaende
```
done-open      Erledigt, noch im Fenster    -> rueckgaengig moeglich (check)
done-locked    Erledigt, Fenster abgelaufen -> eingefroren gruen (check + Schloss)
due            Faellig, im Fenster          -> quittierbar (Kreis, pulsiert gelb)
overdue-locked Verpasst, Fenster abgelaufen -> gesperrt rot (Kreis + Schloss, Schraffur)
pending        Noch nicht faellig           -> grau, nicht klickbar (Kreis leer)
```

### CSS-Keyframes (im HTML style-Tag, nicht in Babel)
```css
@keyframes qv-pulse-red   { 0%,100%{opacity:1} 50%{opacity:.5} }
@keyframes qv-pulse-amber { 0%,100%{opacity:1} 50%{opacity:.55} }
```

---

## 6. Pflegeplan (v2.3.52+)

### State
```javascript
const [dayStartH, setDayStartH] = React.useState(6);
const [dayEndH,   setDayEndH]   = React.useState(22);
const [toleranceMins, setToleranceMins] = React.useState(120);
const [showDaySettings, setShowDaySettings] = React.useState(false);
const [simTime, setSimTime] = React.useState(-1);
const activeSec = simTime >= 0 ? simTime : nowSec;
```

### Test-Panel (gelb gestrichelt)
Enthaelt 4 Regler: Tagesbeginn (0-12), Tagesende (12-24), Toleranz (15min-12h), Sim-Zeit + live-Button.
Geplant: in App-Einstellungen verschieben (nur Admin).

### tlSlotState Signatur im Pflegeplan
```javascript
const tlSlotState = (task, di, cur, dayStart, dayLen) => { ... }
// task.applications MUSS befuellt sein!
tasks.push({ ..., applications: m.applications || [] });
```

### Design F Segmente
- N+1 Segmente: Segment 0 = Farbe des 1. Kreises, Segment i = Farbe von Kreis i-1
- Weiße halbtransparente Kreise mit Icon + Zeitlabel darueber
- Schraffur auf gesperrten Segmenten
- Weisser Zeitmarker mit Pfeil

---

## 7. Igelkarte — Behandlungs-Tab (v2.3.58+)

### Timeline in Medikament-Zeilen
Identisches Design F wie Pflegeplan. Jede Medikament-Zeile zeigt:
- Timeline-Frame (56px) mit Farbsegmenten, Kreisen, Zeitmarker
- Zeitachsen-Labels (5 Punkte: 0%, 25%, 50%, 75%, 100%)
- Fortschrittsbalken gesamt-Behandlung (blau=aktiv, gruen=fertig)
- Warndreieck wenn Slot overdue-locked

### State in HedgehogDetail (lokal, kein settings-Prop noetig)
```javascript
const [tlDayStartH, setTlDayStartH] = useState(6);
const [tlDayEndH,   setTlDayEndH]   = useState(22);
const [tlTolMins,   setTlTolMins]   = useState(120);
const [tlSimTime,   setTlSimTime]   = useState(-1);
const [tlNowSec,    setTlNowSec]    = useState(...);
const [showTlPanel, setShowTlPanel] = useState(false);
```

### tlSlotState Signatur in HedgehogDetail
```javascript
const tlSlotState = (med, di) => {
  // Liest tlDayStartH, tlDayEndH, tlTolMins, tlActiveSec direkt aus Closure
};
```

### verlaufOpen / expandedDays — LIFTED STATE (kritisch!)
```javascript
// In HedgehogDetail (NICHT in TRow!):
const [verlaufOpenMap,  setVerlaufOpenMap]  = useState({});
const [expandedDaysMap, setExpandedDaysMap] = useState({});
const toggleVerlauf   = (idx) => setVerlaufOpenMap(prev => ({...prev, [idx]: !prev[idx]}));
const toggleExpandDay = (idx, key) => setExpandedDaysMap(prev => ({...prev, [idx+'__'+key]: !prev[idx+'__'+key]}));
```

### Verlauf zeigt verpasste Gaben (v2.3.59+)
- Fuer jeden vergangenen Tag (startDate → gestern): freq - dayCount = verpasste Gaben
- Rote Warn-Eintraege in der Verlauf-Timeline
- Sortierung: aufsteigend (aelteste zuerst)

### Ring-Kreis im Karten-Header entfernt (v2.3.62)
Der Fortschritts-Ring (Gaben-Zaehler) wurde aus dem Behandlungs-Karten-Header entfernt.
Die Info steht bereits in der Med-Zeile (z.B. "9 / 20").

---

## 8. QR Quick-View (v2.3.61+)

### Pills-Design
Jede Gabe = Pill-Chip: Icon (Symbol) + Uhrzeit nebeneinander.
Farben analog TL_* (done=gruen, due=gelb pulsierend, overdue=rot pulsierend, pending=grau).
Schloss-Badge oben rechts auf gesperrten Pills.

### Toleranz-Logik
```javascript
const QV_DAY_START = 6*3600;
const QV_DAY_END   = 22*3600;
const QV_DAY_LEN   = QV_DAY_END - QV_DAY_START;
const QV_TOL_MINS  = 120;  // TODO: aus App-Settings lesen
```
Nur QV_CAN = {'done-open':true,'due':true} ist klickbar (innerhalb Toleranzfenster).

### Badge-Logik (v2.3.62)
```javascript
const hasDue = slots.some(st => st === 'due');
const hasOv  = slots.some(st => st === 'overdue-locked');
// Badge-Text:
// allDone -> "erledigt" (gruen)
// hasOv   -> "ueberfaellig" (rot)
// hasDue  -> "faellig" (gelb)  <- NUR wenn Slot IM Fenster
// sonst   -> "ausstehend" (grau)
```

### medState enthaelt applications[]
```javascript
list.push({
  ti, mi, name, detail, doneToday, todayCount, freqPerDay, wasGivenBefore,
  applications: [...(m.applications||[])],  // PFLICHT fuer qvSlotState
});
```

### Live-Uhr in QV (v2.3.61+)
```javascript
const [qvNowSec, setQvNowSec] = React.useState(...);
React.useEffect(() => {
  const iv = setInterval(() => { setQvNowSec(getNowSec()); }, 10000);
  return () => clearInterval(iv);
}, []);
```

---

## 9. Datenstruktur hedgehog
```javascript
{
  id, name, fundtiernummer, igelId, aufnahmedatum, status,
  gewichtAktuell,
  gewichtsverlauf: [{ datum, gewicht, notiz, erfasstVon, erfasstAm }],
  treatments: [{
    templateName, status, startDate,
    medications: [{
      medicationName, dose, unit, applicationRoute,
      frequency, plannedApplications, completedApplications,
      applications: [{ doneAt, doneBy, weightAtTime }]
    }]
  }],
  notizen: [{ datum, notiz, erfasstVon, erfasstAm }],
  betreuer, fundort, finderName, finderTelefon,
  finderEmail, finderAdresse, finderCountryCode
}
```

---

## 10. Rollen & Auth

```
admin    Vollzugriff, Benutzerverwaltung, alle CRUD
pfleger  Standard: Igel anlegen/bearbeiten, Gaben quittieren
gast     Nur lesen, keine Schreiboperationen
```

SESSION_MS = 8h, SESSION_KEY = 'igelSessionLoginAt'

Firebase: apiKey AIzaSyD1LbzZGypzSYvRC-RRNvT2JUTpPRMM8E4 | projectId igelstation-3c3db

---

## 11. Spinner-Diagnose

```python
import re
with open('index.html','r') as f: c=f.read()
s=re.search(r'<script type="text/babel">(.*?)</script>',c,re.DOTALL).group(1)
print("Braces: %d, Parens: %d" % (s.count('{')-s.count('}'), s.count('(')-s.count(')')))
```

### Bekannte Ursachen
1. Braces/Parens != 0 -> defekter Changelog-Eintrag oder fehlendes div
2. padStart(2,'0') in JSX {} -> (n<10?'0':'')+n
3. Fehlendes oeffnendes div nach IIFE })()
4. task.applications fehlt in tasks.push() -> tlSlotState crash
5. Inline-Komponente mit State in anderer Komponente -> Re-mount-Loop
6. tlDotState statt tlSlotState (alter Funktionsname)

---

## 12. Versionshistorie

| Version | Feature | Kernänderung |
|---------|---------|-------------|
| 2.3.62 | Fix QV Badge | Badge 'faellig' nur wenn Slot im Toleranzfenster |
| 2.3.61 | QV Pills + Toleranz | Pills-Design, nur due klickbar, Live-Uhr in QV |
| 2.3.60 | Fix Verlauf-Sortierung | Chronologisch aufsteigend |
| 2.3.59 | Fix Verlauf-Dropdown + verpasste Gaben | verlaufOpen aus TRow gehoben, rote Warn-Eintraege |
| 2.3.58 | Igelkarte Timeline | Design F in Behandlungs-Tab, Warndreieck, Test-Panel |
| 2.3.57 | Fix Spinner fehlendes div | div nach IIFE fehlte |
| 2.3.56 | Fix Spinner Template-Literal | padStart in Template-Literal |
| 2.3.55 | Fix applications in tasks | applications fehlte -> tlSlotState crash |
| 2.3.54 | Toleranz-Logik 6 Zustaende | Zeitfenster-Quittierung |
| 2.3.53 | Design F Timeline | Farbsegmente |
| 2.3.52 | 24h Timeline + Sim | Zeitachse mit Sim-Regler |
| 2.3.37 | QR Quick-View | Bottom Sheet nach QR-Scan |
| 2.3.30 | Bottom-Navigation | Scroll-hiding |
| 2.2.00 | TreatmentWizard | 4-Schritt Dosisberechnung |
| 2.0.00 | Datenbank-Hub | Stammdaten-Hierarchie |
| 1.8.00 | RBAC + Donut-Chart | Rollenbasierte Zugriffskontrolle |

---

## 13. Roadmap

### Offen
- [x] Timeline in Igelkarte Behandlungs-Tab (v2.3.58)
- [x] Warndreieck bei verpasster Gabe (v2.3.58)
- [x] QR Quick-View Pills-Design (v2.3.61)
- [ ] Toleranz + Tagesbeginn/-ende in App-Einstellungen persistent (nur Admin)
- [ ] completedApplications++ korrekt aus Pflegeplan
- [ ] Diagnosefield Dropdown statt Freitext
- [ ] Auto-Navigation in neue Igelkarte nach Erfassung
- [ ] Printable Datenblatt pro Igel

### Mittelfristig
- [ ] Push-Notifications
- [ ] Foto-Upload
- [ ] Statistiken

---

## 14. Code-Referenzen

### BottomBar
height 62px, position fixed, bottom 0, z-index 9000
Formulare: padding-bottom calc(env(safe-area-inset-bottom, 0px) + 74px)

### Settings (localStorage)
```javascript
// laden:
try { return JSON.parse(localStorage.getItem('igel_settings') || '{}'); } catch { return {}; }
// speichern:
try { localStorage.setItem('igel_settings', JSON.stringify(s)); } catch {}
```

### updateSetting in MainApp
```javascript
const updateSetting = (key, val) => {
  const next = { ...settings, [key]: val };
  setSettings(next);
  saveSettings(next);
};
```

*Zuletzt aktualisiert: Maerz 2026 - v2.3.62*
