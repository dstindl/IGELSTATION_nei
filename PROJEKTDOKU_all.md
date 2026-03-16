# Igelpflegestation Pro — Projektdokumentation

**Version:** 2.3.85 | **Stand:** März 2026 | **Entwickler:** Denis-Alexander Stindl

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
IGEL_STARTPROMPT.md                  Chat-Kontext-Prompt für neuen Chat
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
med_haeufigkeiten      Häufigkeitsdefinitionen
```

---

## 3. Kritische Regeln

### Babel-Constraints (Spinner-Ursachen)
- **NIEMALS** `data:image/base64` direkt in JSX → Babel-Crash
- **NIEMALS** doppelte `const`-Deklaration im selben Scope
- **NIEMALS** doppelte `className` auf demselben Element
- **NIEMALS** JSX als Wert in JS-Objekt-Literal
- **NIEMALS** Template-Literale mit einfachen Anführungszeichen in `${}` → `padStart(2,'0')` bricht Babel! String-Verkettung verwenden: `+(n<10?'0':'')+n`
- **NIEMALS** `padStart(2,'0')` direkt in JSX `{}` Ausdruck (auch außerhalb von Template-Literals gefährlich)
- **NIEMALS** schließendes `</div>` ohne öffnendes `<div>` im JSX
- **NIEMALS** Inline-Komponente mit eigenem `useState` innerhalb einer anderen Komponente definieren → führt zu Re-mount bei jedem Re-render des Elternteils (State-Reset)
- **Braces-Balance** im gesamten Babel-Script muss 0 sein

### Firestore-Regeln
- `serverTimestamp()` nicht in Arrays → `new Date().toISOString()` stattdessen
- `orderBy()` ohne Index → 0 Ergebnisse → immer client-seitig sortieren
- `app_todos` = EIN Dokument `main` mit `items[]` — keine separaten Dokumente
- `arrayUnion()` für Append auf `gewichtsverlauf[]`

### Navigation
- Menü-Seiten `onClose`: **NIEMALS** `history.back()` → popstate-Konflikt
- Korrekt: `history.replaceState({igelApp:true,level:1},'')` + `igelMenuOpen(false)`

### Neue Komponenten
- Immer **vor `UserProfile`** einfügen
- Version-Bump Changelog: Anker auf **stabilen älteren Eintrag** — NIEMALS auf neue Version

### State-Lifting Regel (ab v2.3.59)
`verlaufOpen` und `expandedDays` in `TRow` (innerhalb HedgehogDetail) **müssen** in `HedgehogDetail` als Maps gehalten werden — sonst reset bei jedem Live-Uhr-Re-render (alle 10s):
```javascript
// In HedgehogDetail (NICHT in TRow):
const [verlaufOpenMap,  setVerlaufOpenMap]  = useState({});
const [expandedDaysMap, setExpandedDaysMap] = useState({});
const toggleVerlauf   = (idx) => setVerlaufOpenMap(prev => ({...prev, [idx]: !prev[idx]}));
const toggleExpandDay = (idx, key) => setExpandedDaysMap(prev => ({...prev, [idx+'__'+key]: !prev[idx+'__'+key]}));
```

---

## 4. Versions-Pflicht (alle 5 Stellen bei JEDER Änderung)

1. **Changelog-Array** im JSX (am Anfang einfügen)
2. **LoadingScreen**: `>vX.X.XX</div>` im HTML-Splash
3. **Menü-Footer**: `>Version X.X.XX</div>` (class="msheet-version")
4. **Changelog-Header**: `Version X.X.XX · Cloud-basierte...` im JSX
5. **Service Worker**: `igelpflegestation-vX.X.XX` in service-worker.js

### Balance-Check nach jeder Änderung
```python
import re
with open('index.html','r') as f: c=f.read()
s=re.search(r'<script type="text/babel">(.*?)</script>',c,re.DOTALL).group(1)
print("Braces: %d, Parens: %d" % (s.count('{')-s.count('}'), s.count('(')-s.count(')')))
```
→ Beide Werte müssen **0** sein. Sonst Spinner!

### ZIP-Befehl
```bash
cd /home/claude/igelstation && rm -f /home/claude/Igelstation.zip
zip /home/claude/Igelstation.zip index.html igelpflegestation-vX_X_XX-altDB.html \
  service-worker.js icon-192.png icon-512.png deploy.sh update.sh PROJEKTDOKU_all.md IGEL_STARTPROMPT.md
```

---

## 5. Design System — Warm Kompakt

### Farben
```
#fafaf8   Hintergrund (Stone 50)
#ffffff   Karten, Header
#1c1917   Primär-Aktion, Text (Stone 900)
#292524   Sekundär (Stone 800)
#44403c   Text sekundär
#a8a29e   Text gedimmt
#e7e5e4   Trennlinien (gestrichelt)
```

### Timeline Design F — Farbpalette (Toleranz-Logik)
```
#f0fdf4   Mintgrün  — done-open / done-locked (erledigt)
#fefce8   Cremgelb  — due (fällig, im Toleranzfenster)
#fff1f2   Altrosa   — overdue-locked (verpasst, gesperrt)
#fafaf8   Warm Grau — pending (noch nicht fällig)
```

### TL_* Konstanten (identisch in Pflegeplan und HedgehogDetail)
```javascript
const TL_SEG   = {'done-open':'#f0fdf4','done-locked':'#f0fdf4','due':'#fefce8','overdue-locked':'#fff1f2','pending':'#fafaf8'};
const TL_ICOL  = {'done-open':'#166634','done-locked':'#166634','due':'#ca8a04','overdue-locked':'#e11d48','pending':'#d6d3d1'};
const TL_ICON  = {'done-open':'✓','done-locked':'✓','due':'◎','overdue-locked':'●','pending':'○'};
const TL_ANIM  = {'due':'qv-pulse-amber 2.2s ease-in-out infinite','overdue-locked':'qv-pulse-red 1.8s ease-in-out infinite'};
const TL_LOCKED= {'done-locked':true,'overdue-locked':true};
const TL_CAN   = {'done-open':true,'due':true};
```

### Toleranz-Logik — 6 Zustände
```
done-open      Erledigt, im Toleranzfenster     → rückgängig möglich (✓)
done-locked    Erledigt, Fenster abgelaufen     → eingefroren grün (✓🔒)
due            Fällig, im Toleranzfenster       → quittierbar (◎, pulsiert gelb)
overdue-locked Verpasst, Fenster abgelaufen     → gesperrt rot (●🔒, Schraffur)
pending        Noch nicht fällig                → grau, nicht klickbar (○)
```

### Timeline — CSS-Keyframes
```css
@keyframes qv-pulse-red   { 0%,100%{opacity:1} 50%{opacity:.5} }
@keyframes qv-pulse-amber { 0%,100%{opacity:1} 50%{opacity:.55} }
```

### Typografie
```
DM Sans (800)   Display, Headings, Buttons
Arial           Body-Text
DM Mono (500)   IDs, Gewicht, Code-Werte, Timeline-Zeitlabels
```

---

## 6. Pflegeplan — Timeline (v2.3.52+)

### States (Pflegeplan-Komponente)
```javascript
const [dayStartH, setDayStartH] = React.useState(6);
const [dayEndH,   setDayEndH]   = React.useState(22);
const [toleranceMins, setToleranceMins] = React.useState(120); // ±2h
const [showDaySettings, setShowDaySettings] = React.useState(false);
const [simTime, setSimTime] = React.useState(-1);         // -1=live
const activeSec = simTime >= 0 ? simTime : nowSec;
```

### Test-Panel (gelb gestrichelt, später Admin-Einstellungen)
- Tagesbeginn-Regler (0–12 Uhr)
- Tagesende-Regler (12–24 Uhr)
- Toleranz-Regler (±15min – ±12h, Schritt 15min)
- Uhrzeit-Sim-Regler + live-Button
- Uhr-Icon-Button im Header zeigt aktive Zeit

### tlSlotState Logik
```javascript
const tlSlotState = (task, di, cur, dayStart, dayLen) => {
  const t = tlDoseTime(di, task.freqPerDay, dayStart, dayLen);
  const tolSec = toleranceMins * 60;
  const inWindow = cur >= (t-tolSec) && cur <= (t+tolSec);

  const slotGiven = task.applications.some(a => {
    const appSec = new Date(a.doneAt).getHours()*3600+...;
    return appSec >= (t-tolSec) && appSec <= (t+tolSec);
  }) || tapped.has(circleKey);

  if (slotGiven) return inWindow ? 'done-open' : 'done-locked';
  if (cur < t-tolSec) return 'pending';
  if (inWindow) return 'due';
  return 'overdue-locked';
};
```

### WICHTIG: task.applications muss im tasks.push() enthalten sein
```javascript
tasks.push({
  ...,
  applications: m.applications || [],  // ← PFLICHT für tlSlotState
});
```

### Design F Segmente
- Balken geteilt in N+1 Segmente (N = Anzahl Gaben)
- Segment 0 (links) = Farbe des ERSTEN Kreises
- Segment i = Farbe von Kreis i-1
- Weiße halbtransparente Kreise über Segmenten
- Icons: ✓ erledigt, ◎ fällig, ● verpasst, ○ ausstehend
- Schraffur auf gesperrten Segmenten
- Weißer Zeitmarker mit Pfeil

---

## 7. QR Quick-View (v2.3.61+)

### State in MainApp
```javascript
const [showQuickView, setShowQuickView] = useState(false);
const [quickViewIgel, setQuickViewIgel] = useState(null);
const [quickViewInitialAction, setQuickViewInitialAction] = useState(null);
```

### Medikamente — Pills-Design (ab v2.3.61)
Jede Gabe wird als **Pill-Chip** dargestellt: Icon (Symbol) + Uhrzeit nebeneinander.
Farben analog TL_* Konstanten. Schloss-Badge oben rechts auf gesperrten Pills.
Nur `QV_CAN = {'done-open':true,'due':true}` ist klickbar (innerhalb Toleranzfenster).

```javascript
const QV_DAY_START = 6*3600;
const QV_DAY_END   = 22*3600;
const QV_DAY_LEN   = QV_DAY_END - QV_DAY_START;
const QV_TOL_MINS  = 120;  // ±2h — geplant: aus App-Settings lesen
```

### Badge-Logik (ab v2.3.62)
```javascript
const hasDue = slots.some(st => st === 'due');
const hasOv  = slots.some(st => st === 'overdue-locked');
// Badge-Text:
// allDone  → 'erledigt'    (grün)
// hasOv    → 'überfällig'  (rot)
// hasDue   → 'fällig'      (gelb) ← NUR wenn Slot im Toleranzfenster
// sonst    → 'ausstehend'  (grau)
```

### medState enthält applications[] (Pflicht ab v2.3.61)
```javascript
list.push({
  ti, mi, name, detail, doneToday, todayCount, freqPerDay, wasGivenBefore,
  applications: [...(m.applications||[])],  // ← PFLICHT für qvSlotState
});
```

### Live-Uhr in QV (ab v2.3.61)
```javascript
const [qvNowSec, setQvNowSec] = React.useState(...);
React.useEffect(() => {
  const iv = setInterval(() => { setQvNowSec(getNowSec()); }, 10000);
  return () => clearInterval(iv);
}, []);
```

### Weitere Funktionen
- Gewicht eintragen → `gewichtsverlauf[]` + `gewichtAktuell`
- Notizen → `h.notizen[]`
- Behandlung anlegen → `onOpenCard('startVorlage')` → Vorlage-Modal direkt
- Footer-Button: `paddingBottom: calc(env(safe-area-inset-bottom, 0px) + 74px)`
- `onOpenCard` liest frische Daten: `hedgehogs.find(x => x.id === h.id)`

---

## 8. Igelkarte (HedgehogDetail) — ab v2.3.58

### Props
```javascript
HedgehogDetail({ hedgehog, userData, users, onBack, onUpdate, initialEditMode, initialAction })
```

### initialAction
```javascript
const [showVorlageModal, setShowVorlageModal] = useState(
  () => initialAction === 'startVorlage' && !isGuest
);
```

### Timeline im Behandlungs-Tab (ab v2.3.58)
Identisches Design F wie Pflegeplan. Jede Medikament-Zeile zeigt:
- Timeline-Frame (56px) mit Farbsegmenten, Kreisen, Zeitmarker
- Zeitachsen-Labels (5 Punkte)
- Fortschrittsbalken Gesamtbehandlung (blau=aktiv, grün=fertig)
- Warndreieck (⚠) im Karten-Header und an der Med-Zeile wenn `overdue-locked`

### TL-State in HedgehogDetail (lokal)
```javascript
const [tlDayStartH, setTlDayStartH] = useState(6);
const [tlDayEndH,   setTlDayEndH]   = useState(22);
const [tlTolMins,   setTlTolMins]   = useState(120);
const [tlSimTime,   setTlSimTime]   = useState(-1);
const [tlNowSec,    setTlNowSec]    = useState(...);
const [showTlPanel, setShowTlPanel] = useState(false);
// Uhr-Button im Header öffnet Test-Panel (4 Regler: Tagesbeginn, Tagesende, Toleranz, Sim-Zeit)
```

### tlSlotState Signatur in HedgehogDetail
```javascript
const tlSlotState = (med, di) => {
  // Liest tlDayStartH, tlDayEndH, tlTolMins, tlActiveSec aus Closure
};
```

### Verlauf (ab v2.3.59)
- Verpasste Gaben als rote Warneinträge (Warndreieck-Icon, rosa Hintergrund)
- Sortierung: chronologisch aufsteigend (älteste zuerst, neueste unten)
- Berechnung: für jeden vergangenen Tag (startDate → gestern): `freq - dayCount`

### Datenstruktur hedgehog
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

## 9. Rollen & Auth

```
admin    Vollzugriff, Benutzerverwaltung, alle CRUD
pfleger  Standard: Igel anlegen/bearbeiten, Gaben quittieren
gast     Nur lesen, keine Schreiboperationen
```

```javascript
SESSION_MS  = 8 * 60 * 60 * 1000
SESSION_KEY = 'igelSessionLoginAt'
```

### Firebase Config
```javascript
apiKey: "AIzaSyD1LbzZGypzSYvRC-RRNvT2JUTpPRMM8E4"
authDomain: "igelstation-3c3db.firebaseapp.com"
projectId: "igelstation-3c3db"
```

---

## 10. Bekannte Fallstricke

### Spinner-Diagnose
```python
import re
with open('index.html','r') as f: c=f.read()
s=re.search(r'<script type="text/babel">(.*?)</script>',c,re.DOTALL).group(1)
print("Braces: %d, Parens: %d" % (s.count('{')-s.count('}'), s.count('(')-s.count(')')))
```

### Häufige Ursachen (Erfahrungswerte)
1. Braces ≠ 0 → kaputten Changelog-Eintrag prüfen
2. Template-Literal mit `'0'` in `${}` → String-Verkettung stattdessen
3. `padStart(2,'0')` in JSX `{}` Ausdruck → `(n<10?'0':'')+n`
4. Schließendes `</div>` ohne öffnendes nach einem IIFE `})()`
5. `tlDotState` statt `tlSlotState` (veralteter Funktionsname nach Migration)
6. `task.applications` fehlt in `tasks.push()` → tlSlotState crash
7. `verlaufOpen`/`expandedDays` als lokaler State in `TRow` → reset alle 10s durch Live-Uhr

### Daten-Frische
- `quickViewIgel` ist Snapshot → immer `hedgehogs.find(x => x.id === h.id)` nutzen
- `tapped` Set ist optimistisch → nach Firestore-Write den Key entfernen (Doppelzählung!)
- `effectiveDone = Math.min(freqPerDay, todayCount + tapped.count)`

---

## 11. Versionshistorie

| Version | Feature | Kernänderung |
|---------|---------|-------------|
| 2.3.85 | Igelbestand + Dashboard | IgelBestand-Komponente (Filter Status/Betreuer/Gewicht, Suche, Igelkarten mit Banner+Trend+Diagnosen); Dashboard vereinfacht: Donut+Heute-Kacheln+Schnellzugriff |
| 2.3.84 | Fix: Hamburger Igel erfassen | Hamburger-Icon in Schritt 1 + Schritt 2 von AddHedgehogForm ergänzt — alle Screens konsistent |
| 2.3.83 | UI-Korrekturen | 3 Punkte → Hamburger überall, kein grauer Kreis; QR-Scanner Blitz neben Taschenlampe; Schrittzähler 1/2 unter Titel |
| 2.3.82 | Menü: reines Overlay | igelMenuToggle ohne __igelCloseAllExceptMenu, kein history.pushState, Swipe-Down direkt igelMenuClose() — Hintergrundseite bleibt immer offen |
| 2.3.81 | Fix: Swipe-Gesten Feintuning | Nicht-passiver touchmove auf BottomBar → preventDefault() ab 8px → kein Seiten-Scroll beim Hochswipen; Cooldown auch bei Menu-Close → kein Bar-Flicker nach Swipe-Down |
| 2.3.80 | Fix: Swipe-Down + BottomBar-Flicker | Swipe-Down nur history.back() → kein doppelter Close + kein Beenden-Dialog; 600ms Cooldown nach BottomBar-Klick → kein Hide-Effekt |
| 2.3.79 | Fix: Menü Scroll-Lock + Swipe-Down | body.position=fixed beim Öffnen → Hintergrund nicht scrollbar; Scroll-Hide nur wenn Menü geschlossen; Swipe-Down auf Sheet schließt Menü |
| 2.3.78 | BottomBar + Menü Redesign | Menü-Button raus, Bestand rein, Labels, Swipe-Up öffnet Menü, 3-Punkte in allen Headers, Herkunfts-Label in Igelkarte, detailOrigin bestand, Hauptseite-Header |
| 2.3.77 | Igel erfassen: Design-Refresh | DM Sans, 8px Labels, warm stone Inputs, Cards ohne blaue Border, Status als Chips, inline Fehlertexte, Stepper schwarz, Adress-Suggestions inline styles |
| 2.3.76 | Pflegeplan: Filter als Dropdown | Toggle-Strip: zugeklappt mit farbigem Icon + Mini-Chip-Summary + Zurücksetzen-Button; Chevron zeigt Auf/Zu; filterOpen default false |
| 2.3.75 | Fix: Filter-Chips pfleger-sensitiv | dueCnt/overCnt/doneCnt + availMeds/availDiags aus pfleger-gefilterter Basis — kein Widerspruch zwischen Chip-Count und Ergebnis |
| 2.3.74 | Pflegeplan: Filter-Block + Spacing | Sticky Filter-Block (Weiß+Shadow): Status-Chips (nur wenn >0), Fällig/Überfällig/Erledigt, Med+Diagnose aufklappbar, Leer-Zustand mit Reset, Stats ohne Progressbar, 14px/12px Spacing |
| 2.3.73 | QV-Style Pills + Timeline-Dropdown | Pflegeplan + Igelkarte: QV-Pills direkt sichtbar, Timeline ins Dropdown; erledigte Meds kompakt mit done-bubble; tlOpenMap + tlOpenMiMap als Scope-Maps; QV_* Konstanten außerhalb .map() |
| 2.3.70 | Pflegeplan: Banner-Layout überarbeitet | Name+Pfleger zentriert; Diagnosen unter Behandlungsanzahl im card-body; kein "keine Diagnose"-Text |
| 2.3.69 | Fix: Igelkarte Kartenbreite + Diagnosen | Outer wrapper entfernt → gleiche Breite wie Pflegeplan; Diagnosen aus treatments.diagnosisName als Fallback |
| 2.3.68 | Pflegeplan + Igelkarte: Banner-Design | Farbiger Banner pro Igel (8 Töne), Pfleger + Diagnosen im Banner; Stone-700-Banner für Behandlungskarten in Igelkarte |
| 2.3.67 | Fix: QR-Scanner Header | Titel zentriert, 2px Border, einheitlicher Stil |
| 2.3.66 | Design: Alle Seiten-Header vereinheitlicht | fontSize 15/fontWeight 800/DM Sans, borderBottom 2px #e7e5e4, Titel absolut zentriert auf allen Seiten |
| 2.3.65 | Fix: BottomBar-Navigation aus Igelkarte | setSelected(null) fehlte in __igelAction für pflegeplan/neu/qr — Igelkarte blieb sichtbar |
| 2.3.64 | Einstellungen: Timeline-Parameter zentralisiert | Neue Unterseite Einstellungen → Behandlungen → Timeline; Shared State via localStorage; Pflegeplan + Igelkarte gespiegelt; Testpanels bleiben aktiv |
| 2.3.63 | Igelkarte: Ring entfernt, kompaktere Karten | Fortschritts-Ring (Donut) aus Behandlungs-Header entfernt (redundant); Badge+Action in einer Zeile; Header-Padding 12→9px, Med-Zeilen 11→9px, Timeline 56→48px |
| 2.3.62 | Fix: QV Badge ausstehend/fällig | Badge 'fällig' nur wenn Slot im Toleranzfenster liegt |
| 2.3.61 | QR Quick-View: Pills + Toleranz-Logik | Pills-Design statt Kreise, nur ◎ fällig klickbar, Live-Uhr, applications[] in medState |
| 2.3.60 | Fix: Verlauf-Sortierung | Chronologisch aufsteigend (älteste zuerst) |
| 2.3.59 | Fix: Verlauf-Dropdown + verpasste Gaben | verlaufOpen aus TRow in HedgehogDetail gehoben, rote Warn-Einträge im Verlauf |
| 2.3.58 | Igelkarte: Timeline Design F | Design F Timeline in Behandlungs-Tab, Warndreieck, Test-Panel (Uhr-Button) |
| 2.3.57 | Fix: Spinner — fehlendes div | Zeitachse hatte kein öffnendes div nach IIFE |
| 2.3.56 | Fix: Spinner — Template-Literal | padStart(2,'0') in Template-Literal → String-Verkettung |
| 2.3.55 | Fix: Spinner — applications | applications-Feld in tasks.push() ergänzt |
| 2.3.54 | Toleranz-Logik + 6 Zustände | Zeitfenster-gebundene Quittierung, 15min–12h Toleranz |
| 2.3.53 | Design F Timeline | Farbsegmente, Anfang = Farbe des 1. Kreises |
| 2.3.52 | 24h Timeline + Sim-Regler | Zeitachse mit Uhrzeit-Sim im Test-Panel |
| 2.3.51 | Live-Uhr + Test-Panel | Uhr-Button, Tagesbeginn/Ende Regler |
| 2.3.50 | Fix: Doppel-Quittierung | tapped nach Firestore-Write entfernen |
| 2.3.49 | Linker Farbbalken entfernt | Nur noch Kreise kommunizieren Status |
| 2.3.48 | Fortschrittsbalken + Kreis-Fix | effectiveDone konsistent, Amber statt Rot |
| 2.3.47 | Rote Badges entfernt | Kein Rot mehr außer Kreisen |
| 2.3.46 | QRQuickView zurück + Kreise | QRQuickView wiederhergestellt (war gelöscht) |
| 2.3.45 | Pflegeplan Warm + Toggle | Stone-Design, reversibles Toggle |
| 2.3.44 | QR Quick-View Grüne Kreise | initialAction=startVorlage öffnet Vorlage-Modal |
| 2.3.43 | QR Quick-View Fälligkeitsfarben | Kreise mit Grün/Amber/Rot/Grau |
| 2.3.37 | QR Quick-View | Bottom Sheet nach QR-Scan |
| 2.3.30 | Bottom-Navigation | Scroll-hiding, safe-area-inset |
| 2.2.00 | TreatmentWizard | 4-Schritt, Dosisberechnung |
| 2.0.00 | Datenbank-Hub | Stammdaten-Hierarchie |
| 1.8.00 | RBAC + Donut-Chart | Rollenbasierte Zugriffskontrolle |
| 1.0.00 | Launch | Firebase, Igel CRUD, Auth |

---

## 12. Roadmap

### Offen / Nächste Prioritäten
- [x] Timeline + Toleranz-Logik in Igelkarte Behandlungs-Tab ✅ v2.3.58
- [x] Warndreieck bei verpasster Gabe ✅ v2.3.58
- [x] QR Quick-View Pills-Design + Toleranz ✅ v2.3.61
- [ ] Toleranz-Einstellung in App-Einstellungen (nur Admin, persistent)
- [ ] Tagesbeginn/Tagesende in App-Einstellungen (nur Admin, persistent)
- [ ] completedApplications++ korrekt aus Pflegeplan
- [ ] Diagnosefield: Dropdown statt Freitext
- [ ] Auto-Navigation in neue Igelkarte nach Erfassung
- [ ] Printable Datenblatt pro Igel

### Mittelfristig
- [ ] Push-Notifications für fällige Gaben
- [ ] Foto-Upload pro Igel
- [ ] Statistiken: Erfolgsquoten, Behandlungsdauern

---

## 13. Code-Referenzen

### BottomBar
```
height: 62px, position: fixed, bottom: 0, z-index: 9000
Formulare: padding-bottom: calc(env(safe-area-inset-bottom, 0px) + 74px)
```

### Settings (localStorage)
```javascript
// Laden:
try { return JSON.parse(localStorage.getItem('igel_settings') || '{}'); } catch { return {}; }
// Speichern:
try { localStorage.setItem('igel_settings', JSON.stringify(s)); } catch {}
```

### ZIP-Befehl
```bash
cd /home/claude/igelstation && rm -f /home/claude/Igelstation.zip
zip /home/claude/Igelstation.zip index.html igelpflegestation-vX_X_XX-altDB.html \
  service-worker.js icon-192.png icon-512.png deploy.sh update.sh PROJEKTDOKU_all.md IGEL_STARTPROMPT.md
```

---

### Timeline-Settings Shared State (ab v2.3.64)
Timeline-Parameter werden in `igel_settings` (localStorage) gespeichert:
```javascript
// Keys: tlDayStartH, tlDayEndH, tlTolMins, tlSimTime
// Pflegeplan + HedgehogDetail lesen via: settings.tlDayStartH ?? 6
// Schreiben via: onUpdateSetting('tlDayStartH', value)
// Einstellungen-Unterseite: Einstellungen → Behandlungen → Timeline-Einstellungen
// Testpanels in beiden Komponenten bleiben aktiv und sind synchronisiert
```

*Zuletzt aktualisiert: März 2026 · v2.3.85*

### Igel-Farbpalette (ab v2.3.72)
```javascript
const IGEL_COLORS = ['#5c5248','#6b4f38','#4a6352','#5c4a6b','#7a5c34','#4a5568','#5a4a3a','#3d5a4a'];
// Zuweisung: colorIdx = Object.keys(map).length % IGEL_COLORS.length (beim groupByIgel)
// Igelkarte Behandlungen: Stone 700 #44403c (einheitlich)
```
