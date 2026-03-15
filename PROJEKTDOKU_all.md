# Igelpflegestation Pro — Projektdokumentation

**Version:** 2.3.61 | **Stand:** März 2026 | **Entwickler:** Denis-Alexander Stindl

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
- **NIEMALS** schließendes `</div>` ohne öffnendes `<div>` im JSX
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

### ZIP-Befehl
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

### Toleranz-Logik — 6 Zustände
```
done-open     Erledigt, im Toleranzfenster     → rückgängig möglich (✓)
done-locked   Erledigt, Fenster abgelaufen     → eingefroren grün (✓🔒)
due           Fällig, im Toleranzfenster       → quittierbar (◎, pulsiert gelb)
overdue-locked Verpasst, Fenster abgelaufen    → gesperrt rot (●🔒, Schraffur)
pending       Noch nicht fällig                → grau, nicht klickbar (○)
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
const [dayStartH, setDayStartH] = React.useState(6);     // Tagesbeginn
const [dayEndH,   setDayEndH]   = React.useState(22);     // Tagesende
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
  const pastWindow = cur > (t+tolSec);
  
  // Check if given: apps within this slot's window
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
- Segment 0 (links) = Farbe des ERSTEN Kreises (farbiger Anfangsbereich)
- Segment i = Farbe von Kreis i-1
- Weiße halbtransparente Kreise über Segmenten
- Icons: ✓ erledigt, ◎ fällig, ● verpasst, ○ ausstehend
- Schraffur auf gesperrten Segmenten
- Weißer Zeitmarker mit Pfeil

---

## 7. QR Quick-View (v2.3.37+)

### State in MainApp
```javascript
const [showQuickView, setShowQuickView] = useState(false);
const [quickViewIgel, setQuickViewIgel] = useState(null);
const [quickViewInitialAction, setQuickViewInitialAction] = useState(null);
```

### Funktionen
- Gewicht eintragen → `gewichtsverlauf[]` + `gewichtAktuell`
- Medikamente quittieren (Kreise, live Firestore), reversibel
- Notizen → `h.notizen[]`
- Behandlung anlegen → `onOpenCard('startVorlage')` → Vorlage-Modal direkt
- Footer-Button: `paddingBottom: calc(env(safe-area-inset-bottom, 0px) + 74px)`
- `onOpenCard` liest frische Daten: `hedgehogs.find(x => x.id === h.id)`

### Farben (Quick-View Kreise)
```
#dcfce7   Mintgrün  — erledigt (voller Kreis + grüner Haken)
#fef9c3   Cremgelb  — fällig (pulsierend)
#ffe4e6   Altrosa   — überfällig (pulsierend)
#fafaf8   Grau      — pending
```
Keine Umrandung, keine inneren Punkte.

---

## 8. Igelkarte (HedgehogDetail)

### Props
```javascript
HedgehogDetail({ hedgehog, userData, users, onBack, onUpdate, initialEditMode, initialAction })
```

### initialAction
```javascript
// showVorlageModal startet direkt wenn initialAction='startVorlage'
const [showVorlageModal, setShowVorlageModal] = useState(
  () => initialAction === 'startVorlage' && !isGuest
);
```

### Behandlungs-Kreise (Igelkarte)
Gleiche Warm-Farben wie Pflegeplan, reversibel:
- `getDotSt(ci)` → bg/border/animation je nach wasGivenBefore + todayCount
- Undo: entfernt letzten today-App aus applications[], setzt done=false

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
1. Braces ≠ 0 → Kaputten Changelog-Eintrag prüfen
2. Template-Literal mit `'0'` in `${}` → String-Verkettung stattdessen
3. Schließendes `</div>` ohne öffnendes nach einem IIFE `})()}`
4. `tlDotState` statt `tlSlotState` nach Migration
5. `task.applications` fehlt in `tasks.push()` → tlSlotState crash

### Daten-Frische
- `quickViewIgel` ist Snapshot → immer `hedgehogs.find(x => x.id === h.id)` nutzen
- `tapped` Set ist optimistisch → nach Firestore-Write den Key entfernen (Doppelzählung!)
- `effectiveDone = Math.min(freqPerDay, todayCount + tapped.count)`

---

## 11. Versionshistorie

| Version | Feature | Kernänderung |
|---------|---------|-------------|
| 2.3.61 | Igelkarte: Timeline in Behandlungs-Tab | Design F Timeline mit Toleranz-Logik, Warndreieck, Test-Panel (Uhr-Button) |
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
- [x] Timeline + Toleranz-Logik in Igelkarte Behandlungs-Tab übertragen ✅ v2.3.61
- [ ] Toleranz-Einstellung in App-Einstellungen (nur Admin)
- [ ] Tagesbeginn/Tagesende in App-Einstellungen (nur Admin)
- [ ] Warndreieck dauerhaft in Igelkarte wenn Gabe verpasst (✅ bereits in v2.3.61 umgesetzt)
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

### ZIP-Befehl
```bash
cd /home/claude/igelstation && rm -f /home/claude/Igelstation.zip
zip /home/claude/Igelstation.zip index.html igelpflegestation-vX_X_XX-altDB.html \
  service-worker.js icon-192.png icon-512.png deploy.sh update.sh PROJEKTDOKU_all.md
```

---

*Zuletzt aktualisiert: März 2026 · v2.3.57*
