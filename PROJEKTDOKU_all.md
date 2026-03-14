# Igelpflegestation Pro — Projektdokumentation

**Version:** 2.3.44 | **Stand:** März 2026 | **Entwickler:** Denis-Alexander Stindl

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
igelpflegestation-vX_X_XX-altDB.html Benannte Backup-Version
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
- **Braces-Balance** im gesamten Babel-Script muss 0 sein

### Firestore-Regeln
- `serverTimestamp()` nicht in Arrays → `new Date().toISOString()` stattdessen
- `orderBy()` ohne Index → 0 Ergebnisse → immer client-seitig sortieren
- `app_todos` = EIN Dokument `main` mit `items[]` — keine separaten Dokumente
- `arrayUnion()` für Append auf `gewichtsverlauf[]`

### Navigation
- Menü-Seiten `onClose`: **NIEMALS** `history.back()` → popstate-Konflikt
- Korrekt: `history.replaceState({igelApp:true,level:1},'')` + `igelMenuOpen(false)`
- QR Quick-View: `history.pushState({showQuickView:true},'')` beim Öffnen

### Neue Komponenten
- Immer **vor `UserProfile`** einfügen
- Version-Bump Changelog: Anker auf **stabilen älteren Eintrag** — NIEMALS auf neue Version

---

## 4. Versions-Pflicht (alle 5 Stellen bei JEDER Änderung)

1. **Changelog-Array** im JSX (am Anfang einfügen)
2. **LoadingScreen**: `>vX.X.XX</div>` im HTML-Splash (Zeile ~326)
3. **Menü-Footer**: `>Version X.X.XX</div>` (class="msheet-version", Zeile ~376)
4. **Changelog-Header**: `Version X.X.XX · Cloud-basierte...` im JSX
5. **Service Worker**: `igelpflegestation-vX.X.XX` in service-worker.js

### Balance-Check nach jeder Änderung
```python
import re
with open('index.html','r') as f: c=f.read()
s=re.search(r'<script type="text/babel">(.*?)</script>',c,re.DOTALL).group(1)
print(f"Braces: {s.count('{')-s.count('}')}, Parens: {s.count('(')-s.count(')')}")
# Beide müssen 0 sein!
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
#d97706   Amber — fällige Gaben
#16a34a   Grün — erledigte Gaben
#dc2626   Rot — überfällige Gaben
#fef3c7   Amber-Badge Hintergrund
```

### Typografie
```
DM Sans (800)   Display, Headings, Buttons
Arial           Body-Text
DM Mono (500)   IDs, Gewicht, Code-Werte
```

### Fälligkeits-Kreise (konsistent in Quick-View, Pflegeplan, Igelkarte)
```
Grün solid #16a34a + weißer Haken   Gabe erledigt
Amber pulsierend #d97706            Gabe fällig (jetzt)
Rot pulsierend #dc2626              Überfällig (gestern nicht gegeben)
Grau transparent #e7e5e4            Noch nicht fällig (Abendgabe)
```

### CSS-Keyframes
```css
@keyframes qv-pulse-red   { 0%,100%{box-shadow:0 0 0 0 rgba(220,38,38,.35)} 50%{box-shadow:0 0 0 5px rgba(220,38,38,0)} }
@keyframes qv-pulse-amber { 0%,100%{box-shadow:0 0 0 0 rgba(217,119,6,.3)}  50%{box-shadow:0 0 0 4px rgba(217,119,6,0)} }
```

### Prinzipien
- Keine Emojis in JSX
- SVG-Attribute in camelCase (`strokeWidth`, `strokeLinecap`)
- `fixed inset-0` NIEMALS in `fade-in`-Div
- BottomBar: `height: 62px`, `z-index: 9000`
- Formulare mit Fixed-Nav: `padding-bottom: calc(env(safe-area-inset-bottom, 0px) + 74px)`

---

## 6. Komponenten-Architektur

### Haupt-Komponenten
```
MainApp              Root, Routing, globaler State, QR-Trigger
HedgehogDetail       Igelkarte (4 Kacheln: Behandlung/Gewicht/Diagnose/Info)
Pflegeplan           Tagesplan aller Igel, Gaben quittieren
QRScannerModal       Kamera-QR-Scan (jsQR), Taschenlampe
QRQuickView          Bottom Sheet nach QR-Scan
AddHedgehogForm      2-Schritt-Wizard neue Igelaufnahme
TreatmentWizard      4-Schritt: Diagnose→Medikament→Dosis→Start
MedikamentDB         Medikamentenstammdaten CRUD
DiagnoseDB           Diagnosestammdaten CRUD
TreatmentDB          Behandlungsvorlagen CRUD
TodoList             Aufgaben (app_todos/main.items[])
UserProfile          Profil (Name, Passwort)
UserManagement       Admin: Benutzerverwaltung
SettingsDialog       App-Einstellungen
DashboardDonut       Donut-Chart Bestandsübersicht
ChangelogPage        Versionshistorie
```

### BottomBar
```
bnav-menu       Hamburger-Menü
bnav-home       Startseite
bnav-neu        Neuer Igel
bnav-qr         QR-Scanner → Quick-View
bnav-pflegeplan Pflegeplan
```

### Menü-Seiten Pattern
- Full-Page Early-Return (kein Modal)
- `onClose`: `history.replaceState({igelApp:true,level:1},'')` + `igelMenuOpen(false)`
- Back-State: `_backState.current` enthält alle relevanten States

---

## 7. QR Quick-View (v2.3.37+)

### Flow
QR-Icon → Scanner → QR erkannt → Bottom Sheet über Scanner

### State in MainApp
```javascript
const [showQuickView, setShowQuickView] = useState(false);
const [quickViewIgel, setQuickViewIgel] = useState(null);
const [quickViewInitialAction, setQuickViewInitialAction] = useState(null);
```

### Funktionen
- Gewicht eintragen → `gewichtsverlauf[]` + `gewichtAktuell`
- Medikamente: N Kreise (1 pro Gabe), live Firestore-Write, reversibel
- Fälligkeitsfarben analog Pflegeplan
- Fortschrittsbalken bei >1 Gabe/Tag
- Notizen → `h.notizen[]`
- Behandlung anlegen → öffnet Igelkarte + `showVorlageModal=true` direkt
- `onOpenCard` liest frische Daten: `hedgehogs.find(x => x.id === h.id)`

### initialAction
```javascript
// HedgehogDetail: showVorlageModal startet direkt
const [showVorlageModal, setShowVorlageModal] = useState(
  () => initialAction === 'startVorlage' && !isGuest
);
```

### Dot-State Logik
```javascript
const getDotState = (item, dotIdx) => {
  if (dotIdx < item.todayCount) return 'done';
  if (dotIdx === item.todayCount) return item.wasGivenBefore ? 'overdue' : 'due';
  return 'pending';
};
```

### Medikament-Feldnamen (in treatments[].medications[])
```javascript
m.medicationName    // Name des Medikaments
m.dose              // Dosierung (Zahl)
m.unit              // Einheit (mg, ml...)
m.applicationRoute  // oral, subkutan, topisch...
m.frequency         // "1x täglich", "2x täglich"...
m.plannedApplications
m.completedApplications
m.applications[]    // [{ doneAt, doneBy, weightAtTime }]
```

### Test-Buttons im Scanner
Gelber Dev-Bereich mit:
- "Stachi scannen" → sucht Igel mit "stachi" im Namen
- "Ohne Behandlung" → Igel ohne treatments[]

---

## 8. Pflegeplan

### Task-Berechnung
```javascript
const selApps = (m.applications||[]).filter(a => a.doneAt.startsWith(selectedDate));
const freqPerDay = freq.includes('4x')?4 : freq.includes('3x')?3 : freq.includes('2x')?2 : 1;
const doneToday = selApps.length >= freqPerDay;
const overdue = !doneToday && isToday && lastApp && lastApp.doneAt.split('T')[0] < todayStr;
```

### Quittieren (recordFromPlan)
```javascript
const app = { doneAt: new Date().toISOString(), doneBy: userData.name, weightAtTime: h.gewichtAktuell };
const completed = (parseInt(m.completedApplications)||0) + 1;
// → update treatments[] auf hedgehog-Dokument
window.__pflegeplanRefresh && window.__pflegeplanRefresh();
```

---

## 9. Igelkarte (HedgehogDetail)

### Props
```javascript
HedgehogDetail({ hedgehog, userData, users, onBack, onUpdate, initialEditMode, initialAction })
```

### Kacheln
```
behandlung   Aktive Behandlungen, Vorlage starten, Ring-Fortschritt
gewicht      Verlaufsgraph, neue Messung
diagnose     Aus Behandlungsvorlagen extrahiert
info         Stammdaten, Finder, Bearbeitung
```

### Datenstruktur hedgehog
```javascript
{
  id, name, fundtiernummer, igelId, aufnahmedatum, status,
  geschlecht, alterSchaetzung, gewichtAktuell,
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

```javascript
SESSION_MS  = 8 * 60 * 60 * 1000   // 8 Stunden
WARNING_MS  = 30 * 60 * 1000        // Warnung 30 min vorher
SESSION_KEY = 'igelSessionLoginAt'
```

### Firebase Config
```javascript
apiKey: "AIzaSyD1LbzZGypzSYvRC-RRNvT2JUTpPRMM8E4"
authDomain: "igelstation-3c3db.firebaseapp.com"
projectId: "igelstation-3c3db"
```

---

## 11. Bekannte Fallstricke

### Spinner-Diagnose
```python
import re
with open('index.html','r') as f: c=f.read()
s=re.search(r'<script type="text/babel">(.*?)</script>',c,re.DOTALL).group(1)
print("Braces: %d, Parens: %d" % (s.count('{')-s.count('}'), s.count('(')-s.count(')')))
dups = len(re.findall(r'className="[^"]*"\s+className="', c))
print("Dup className: %d" % dups)
```

### Häufige Ursachen
1. Braces ≠ 0 → Kaputten Changelog-Eintrag prüfen (fehlende `{`)
2. Doppelte `const`-Deklaration
3. Doppelte `className`
4. Base64-Bild in JSX
5. `history.back()` in Menü-onClose

### Daten-Frische (stale snapshot)
- `quickViewIgel` ist Snapshot vom Scan-Zeitpunkt
- Toggle und onOpenCard lesen IMMER frisch: `hedgehogs.find(x => x.id === h.id)`

### Changelog Version-Bump (sicher)
```python
# RICHTIG: Anker auf stabilen älteren Eintrag
c = c.replace("{ version: '2.3.XX',",
  "{ version: '2.3.YY', label: '...', items: [...] },\n{ version: '2.3.XX',", 1)

# FALSCH: Anker auf neue Version → zerstört Einträge → Braces -1
c = c.replace("{ version: '2.3.YY',", ...)  # NIEMALS!
```

---

## 12. Versionshistorie

| Version | Feature | Kernänderung |
|---------|---------|-------------|
| 2.3.46 | QRQuickView zurück + Kreise überall | QRQuickView wiederhergestellt, Kreise ohne Punkte, Igelkarte warm + reversibel |
| 2.3.45 | Pflegeplan Warm + Kreise + Toggle | Stone-Design, Fälligkeitsfarben, reversibles Toggle, Quick-View Footer-Fix |
| 2.3.44 | QR Quick-View: Grüne Kreise + Wizard-Start | Voller grüner Kreis+Haken, initialAction öffnet Vorlage-Modal direkt |
| 2.3.43 | QR Quick-View: Fälligkeits-Kreise | Kreise statt Checkboxen, Grün/Amber/Rot/Grau, Fortschrittsbalken |
| 2.3.42 | Fix: Igelkarte nach Quick-View | onOpenCard liest frische Daten aus live hedgehogs[] |
| 2.3.41 | QR Quick-View: Toggle-Fix | Toggle liest frische Daten, Igelkarte-Button im Header |
| 2.3.40 | Fix: Medikamentennamen | Feldnamen: medicationName, dose, unit, applicationRoute, frequency |
| 2.3.39 | QR Scanner: Test-Buttons | Stachi-Simulation + Igel-ohne-Plan im Dev-Bereich |
| 2.3.38 | Fix: m.aktiv-Filter | Medikamente aus aktiven Behandlungen korrekt angezeigt |
| 2.3.37 | QR Quick-View | Bottom Sheet, Gewicht/Meds/Notizen, Live Firestore-Write |
| 2.3.36 | Redesign: Igelerfassung | Badges outline, Linksrand helles Blau, Buttons schwarz |
| 2.3.35 | Fix: TreatmentDB | Whitescreen durch verwaistes JSX-Fragment behoben |
| 2.3.30 | Bottom-Navigation | Scroll-hiding, safe-area-inset, 5 Icons |
| 2.3.00 | QR Scanner Redesign | Helles UI, Scan-Linie, Taschenlampe |
| 2.2.00 | TreatmentWizard | 4-Schritt, Dosisberechnung aus Gewicht |
| 2.1.00 | Igelkarte Kacheln | 4 Kacheln, Info-Strip, Tab-Leiste sticky |
| 2.0.00 | Datenbank-Hub | Stammdaten-Hierarchie, TreatmentDB, MedikamentDB |
| 1.8.00 | RBAC + Donut-Chart | Rollenbasierte Zugriffskontrolle |
| 1.7.00 | QR-Code Generierung | QR pro Igelkarte, Druckansicht |
| 1.0.00 | Launch | Firebase, Igel CRUD, Auth, Firestore Echtzeit-Sync |

---

## 13. Roadmap

### Nächste Prioritäten
- [ ] Kreise-System im Pflegeplan (Fälligkeitsfarben + Puls)
- [ ] Kreise-System in Igelkarte Behandlungs-Kachel
- [ ] Warm-Hintergrund-Audit (bg-gray-* → Stone)

### Mittelfristig
- [ ] Diagnosefield: Dropdown statt Freitext
- [ ] completedApplications++ aus Quick-View
- [ ] Auto-Navigation in neue Igelkarte nach Erfassung
- [ ] Printable Datenblatt pro Igel

### Langfristig
- [ ] Foto-Upload pro Igel
- [ ] Push-Notifications für fällige Gaben
- [ ] Statistiken: Erfolgsquoten, Behandlungsdauern

---

*Zuletzt aktualisiert: März 2026 · v2.3.46*
