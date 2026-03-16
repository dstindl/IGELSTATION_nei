# Igelpflegestation Pro — Projektdokumentation

**Version:** 2.4.07 | **Stand:** März 2026 | **Entwickler:** Denis-Alexander Stindl

---

## LEITLINIE FÜR FORTFÜHRUNG

Diese Dokumentation wird **bei jedem Versionswechsel aktualisiert**. Sie enthält alle Informationen, die ein neuer Chat-Start ohne Rückfragen benötigt. Der Aufbau ist:

1. **Infrastruktur** — Stack, Dateien, ZIP-Regeln, Versionspflicht
2. **Design-System** — vollständiges Regelwerk, alle Patterns
3. **Kritische Regeln** — was Babel/Firestore/Navigation kaputt macht
4. **Bekannte Bugs** — alle bisherigen Whitescreen-Ursachen mit Fix
5. **Komponenten** — jede Komponente mit States, Logik, Pfaden, Fallstricken
6. **Datenstrukturen** — Firestore-Felder
7. **Versionshistorie** — vollständig

Bei jeder neuen Funktion, jedem Bug-Fix oder Design-Änderung: **entsprechenden Abschnitt ergänzen**, Versionshistorie aktualisieren. Nicht kürzen — Vollständigkeit ist wichtiger als Kompaktheit.

---

## 1. Infrastruktur

### Stack
```
React 18 + Babel Standalone 7.23.5  cdnjs — kein npm, kein Build
Firebase 10.7.1                     Auth + Firestore
Tailwind CSS CDN                    Utility-CSS (Legacy; neuer Code: inline styles)
jsQR 1.4.0                          QR-Scanning aus Kamera
QRCode.js 1.0.0                     QR-Code-Generierung
DM Sans / DM Mono                   Google Fonts (800/700/600, Mono 500)
Nominatim (OpenStreetMap)           Adress-Autocomplete (Debounce 600ms)
```

| | |
|---|---|
| **URL** | dstindl.github.io/IGELSTATION_nei |
| **Firebase Projekt** | igelstation-3c3db |
| **Architektur** | Single-File index.html, alle Komponenten darin |
| **apiKey** | AIzaSyD1LbzZGypzSYvRC-RRNvT2JUTpPRMM8E4 |
| **authDomain** | igelstation-3c3db.firebaseapp.com |

### ZIP-Inhalt (ab v2.4.07)
```
index.html          Haupt-App
service-worker.js   Offline-Cache (Cache-Name muss mit Version bumpen)
icon-192.png        PWA-Icon
icon-512.png        PWA-Icon
deploy.sh           GitHub Pages Ersteinrichtung
update.sh           Update-Deployment
PROJEKTDOKU_all.md  Diese Datei (immer aktualisiert)
IGEL_STARTPROMPT.md Chat-Kontext-Prompt (immer aktualisiert)
```

**Nicht im ZIP:** ~~igelpflegestation-vX_X_XX-altDB.html~~ (entfernt v2.4.07), ~~KONZEPT_IGELBESTAND_DASHBOARD.md~~ (entfernt v2.4.07)

### ZIP-Befehl
```bash
cd /home/claude/igelstation && rm -f /home/claude/Igelstation.zip
zip /home/claude/Igelstation.zip index.html service-worker.js \
  icon-192.png icon-512.png deploy.sh update.sh PROJEKTDOKU_all.md IGEL_STARTPROMPT.md
```

### Firestore Collections
```
hedgehogs          Igelkarten mit allen Unterdaten (treatments[], gewichtsverlauf[] etc.)
users              Benutzerprofile: { uid, name, email, role, active, inviteCode }
app_todos          IMMER EIN Dokument "main" mit { items: [] } — keine separaten Dokumente!
treatmentDatabase  Behandlungsvorlagen: { name, diagnosisId, diagnosisName, medications[], notes }
medicationDatabase Medikamente: { name, activeSubstance, brand, category, defaultDosage,
                   dosageUnit, applicationRoutes[], defaultFrequency, frequencyOptions[],
                   linkedDiagnoses[] }
diagnosisDatabase  Diagnosen: { name, group, severity, recommendedMedications[] }
```

---

## 2. Versions-Pflicht (5 Stellen — bei JEDER Änderung)

```
1. Changelog-Array im JSX     — neuer Eintrag am Anfang; Anker zeigt auf bisherig aktuellen!
2. LoadingScreen              — >vX.X.XX</div>
3. Menü-Footer                — >Version X.X.XX</div> (class="msheet-version")
4. Changelog-Header           — Version X.X.XX · Cloud-basierte...
5. service-worker.js          — igelpflegestation-vX.X.XX (Cache-Name)
```

**Balance-Check nach jeder Änderung — Pflicht:**
```python
import re
with open('index.html','r') as f: c=f.read()
s=re.search(r'<script type="text/babel">(.*?)</script>',c,re.DOTALL).group(1)
print("Braces: %d, Parens: %d" % (s.count('{')-s.count('}'), s.count('(')-s.count(')')))
# Beide müssen 0 sein. Sonst Spinner oder Whitescreen!
```

---

## 3. Lieferregeln

- **ZIP immer bereitstellen** — nie nur index.html
- **PROJEKTDOKU_all.md** bei jedem Versionswechsel aktualisieren (Versionshistorie + geänderte Abschnitte)
- **IGEL_STARTPROMPT.md** aktualisieren wenn ZIP-Regeln oder Stack sich ändern
- **Konzepte** immer als interaktive HTML-Datei — mit Phone-Mockups, Lese+Edit+Neu — nie PDF/Markdown/Screenshot
- **Changelog** vollständig halten — alle Versions-Fixes dokumentieren

---

## 4. Design System — Warm Stone (Standard ab v2.4.x)

Verbindlicher Standard für alle neuen und überarbeiteten Komponenten. Bei Unklarheit: bestehende v2.4.x-Komponenten als Referenz nehmen.

### 4.1 Farben

**Basis-Palette:**
```
#fafaf8   Seitenhintergrund
#ffffff   Karten, Header-Bars, Inputs
#f5f5f4   Sub-Karten, sekundäre Hintergründe
#e7e5e4   Standard-Rahmen, Trennlinien (row borders)
#d6d3d1   Gedimmte Rahmen, leere Werte (–)
#a8a29e   Labels über Feldern, Subtext, Zähler
#78716c   Sekundärer Text, inaktive Seg-Buttons
#57534e   Tertiärer Text, Meta-Daten
#44403c   Primärer Body-Text
#1c1917   Primärfarbe: Buttons, aktive States, Stift-aktiv
```

**Severity-Badges:**
```
Leicht:  bg:#dcfce7  text:#166634  border:#86efac
Mittel:  bg:#fef3c7  text:#92400e  border:#fde68a
Schwer:  bg:#fee2e2  text:#dc2626  border:#fca5a5
```

**Banner:**
```
Flow (amber):   bg:#fffbeb  border:#fde68a  text:#92400e   — Workflow-Schritte
Info (blau):    bg:#eff6ff  border:#bfdbfe  text:#1e40af   — Erklärungen
Fehler (rot):   bg:#fff1f2  border:#fecdd3  text:#e11d48   — Pflichtfeld-Fehler
Erfolg (grün):  bg:#f0fdf4  border:#bbf7d0  text:#166634
```

**Status-Badges Igel:**
```
Aufnahme:            bg:#f5f5f4  text:#78716c
In Pflege:           bg:#fef3c7  text:#92400e  border:#fde68a
Überwinterung:       bg:#eff6ff  text:#1e40af  border:#bfdbfe
Auswilderungsbereit: bg:#dcfce7  text:#166634  border:#86efac
Ausgewildert:        bg:#f0fdf4  text:#15803d
Verstorben:          bg:#fee2e2  text:#dc2626  border:#fca5a5
```

**Timeline-Farben:**
```javascript
const TL_SEG  = { 'done-open':'#f0fdf4','done-locked':'#f0fdf4','due':'#fefce8','overdue-locked':'#fff1f2','pending':'#fafaf8' };
const TL_ICOL = { 'done-open':'#166634','done-locked':'#166634','due':'#ca8a04','overdue-locked':'#e11d48','pending':'#d6d3d1' };
const QV_BG   = { 'done-open':'#dcfce7','done-locked':'#dcfce7','due':'#fefce8','overdue-locked':'#fff1f2','pending':'#fafaf8' };
const QV_BD   = { 'done-open':'#86efac','done-locked':'#86efac','due':'#fde68a','overdue-locked':'#fecdd3','pending':'#e7e5e4' };
```

### 4.2 Typografie

```
DM Sans 800   Seiten-Titel (15px), Karten-Überschriften, Buttons
DM Sans 700   Section-Labels, Feldwerte fett
DM Sans 600   Feldwerte Lese-Modus
DM Mono 500   IDs (IGL-xxx), Gewicht, Uhrzeiten, Code-Werte
```

**Label-Standard (über jedem Formularfeld):**
```javascript
{ fontSize:9, fontWeight:700, color:'#a8a29e', textTransform:'uppercase',
  letterSpacing:'.05em', marginBottom: 3 }
```

### 4.3 Komponenten-Patterns (Referenz-Code)

**Standard-Karte:**
```javascript
{ background:'#fff', borderRadius:14, border:'1px solid #e7e5e4',
  boxShadow:'0 2px 8px rgba(28,25,23,.07)', overflow:'hidden' }
```

**Sub-Karte (z.B. Med-Eintrag in TreatmentDB):**
```javascript
{ background:'#f5f5f4', borderRadius:12, border:'1.5px solid #e7e5e4', padding:12 }
// Aktiv/fokussiert → border:'1.5px solid #1c1917'
```

**Seiten-Header (sticky, Titel absolut zentriert):**
```javascript
// Wrapper:
{ position:'sticky', top:0, background:'#fff', display:'flex', alignItems:'center',
  justifyContent:'space-between', padding:'10px 16px',
  borderBottom:'2px solid #e7e5e4', zIndex:10 }
// Titel:
{ position:'absolute', left:'50%', transform:'translateX(-50%)', fontSize:15,
  fontWeight:800, color:'#1c1917', whiteSpace:'nowrap', fontFamily:"'DM Sans',sans-serif" }
// Zurück-Button: { width:36, height:36, borderRadius:'50%', background:'#f5f5f4', border:'none' }
// Plus-Button:   { width:36, height:36, borderRadius:10,   background:'#1c1917', border:'none' }
```

**Section-Label:**
```javascript
{ fontSize:8, fontWeight:800, color:'#a8a29e', textTransform:'uppercase',
  letterSpacing:'.1em', padding:'2px 0 6px' }
```

**Karten-Zeile:**
```javascript
// Standard: { padding:'10px 14px', borderBottom:'1px solid #f0eeec' }
// Letzte:   { padding:'10px 14px' }  // kein border
```

**Input:**
```javascript
{ border:'1.5px solid #e7e5e4', borderRadius:10, padding:'9px 12px', fontSize:13,
  outline:'none', background:'#fafaf8', color:'#1c1917', fontFamily:'inherit', width:'100%' }
// Fehler: { border:'1.5px solid #fca5a5', background:'#fff1f2' }
```

**Select (immer mit Chevron-SVG, position:relative auf Wrapper):**
```javascript
{ ...Input, appearance:'none', paddingRight:28 }
// + <svg style={{position:'absolute',right:10,top:'50%',transform:'translateY(-50%)',pointerEvents:'none'}}
//      width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="#a8a29e" strokeWidth="2.5">
//   <polyline points="6 9 12 15 18 9"/></svg>
```

**Segmented Control:**
```javascript
// Container: { display:'flex', padding:2, background:'#e7e5e4', borderRadius:9, gap:1 }
// Aktiv:     { flex:1, padding:'7px', borderRadius:7, background:'#1c1917', color:'#fff',
//              fontSize:10, fontWeight:700, border:'none', cursor:'pointer', transition:'all .15s' }
// Inaktiv:   { background:'transparent', color:'#78716c' }
```

**Sticky Save-Bar:**
```javascript
{ position:'sticky', bottom:0, background:'#fff', borderTop:'1px solid #e7e5e4',
  padding:'10px 12px', display:'flex', gap:8,
  paddingBottom:'calc(10px + env(safe-area-inset-bottom,0px))' }
// Speichern: { flex:2, background:'#1c1917', color:'#fff', fontWeight:800, fontSize:13 }
// Abbrechen: { flex:1, background:'#f5f5f4', color:'#78716c', fontWeight:700, fontSize:13 }
```

**Löschen-Bestätigung (Bottom-Sheet statt Modal):**
```javascript
// Overlay:  { position:'fixed', inset:0, background:'rgba(0,0,0,.45)', zIndex:60,
//             display:'flex', alignItems:'flex-end', padding:12 }
// Sheet:    { background:'#fff', borderRadius:18, width:'100%', maxWidth:400, padding:20 }
// Löschen-Button: { background:'#e11d48', color:'#fff' }
```

### 4.4 Formular-Standard-Struktur

```
1. Sticky Header (Zurück + Titel)
2. FlowBanner [amber]   — bei Datenbank-Formularen (Schritt 1/2/3/4 Workflow)
3. Section A → Karte mit beschrifteten Zeilen (Label + Feld)
4. Section B → Karte
5. InfoBanner [blau]    — direkt vor erklärungsbedürftigem Abschnitt
6. Section C → Karte
7. Fehler-Banner [rot]  — nur bei Pflichtfeld-Validierungsfehler
8. Sticky Save-Bar
```

### 4.5 Listen-Standard-Struktur

```
1. Sticky Header (Zurück + Titel + Plus-Button)
2. Suchfeld
3. Counter-Label ("3 Einträge")
4. Karten-Liste (gap 9–10px)
   └─ Karte: Name/Titel + optional Subtext
   └─ Badges (Kategorie, Dosis, Schweregrad etc.)
   └─ Fußzeile: Meta links + Stift/Löschen rechts
5. Leer-Zustand mit CTA-Button
```

### 4.6 Render-Funktionen vs. Inline-Komponenten — KRITISCH

Babel Standalone crasht, wenn JSX-Komponenten innerhalb anderer Komponenten mit `const X = () =>` definiert werden. **Immer render-Funktionen:**

```javascript
// FALSCH → Whitescreen:
const FlowBanner = ({ step }) => (<div>...</div>);
// Aufruf: <FlowBanner step={2} />

// RICHTIG:
const renderFlowBanner = (step) => (<div>...</div>);
// Aufruf: {renderFlowBanner(2)}
```

Ausnahme: Komponenten auf oberster Ebene außerhalb anderer Komponenten (z.B. `DiagnoseDB`, `MedikamentDB`) sind OK.

### 4.7 Datenbank-Workflow-Reihenfolge

```
Schritt 1 → Diagnosen anlegen          (beschreibt Krankheitsbild)
Schritt 2 → Medikamente anlegen        (mit Diagnosen verknüpfen → Assistent-Vorschlag)
Schritt 3 → Behandlungsvorlagen bauen  (Diagnose + Medikamente kombinieren)
Schritt 4 → Behandlung am Igel         (Vorlage auf Igel anwenden)
```

Diese Reihenfolge gilt überall: DatenbankHub (Diagnosen vor Medikamenten), FlowBanner in Formularen, Ersteinrichtungs-Banner.

---

## 5. Kritische Regeln

### 5.1 Babel-Constraints (Spinner / Whitescreen)

| Problem | Symptom | Lösung |
|---------|---------|--------|
| `padStart(2,'0')` in Template-Literal `${}` | Spinner | `(n<10?'0':'')+n` |
| HTML-Tags in String via `dangerouslySetInnerHTML` | Whitescreen | JSX-Children übergeben |
| `const X = ()=>` (Inline-Komponente) innerhalb anderer | Whitescreen | `renderX()` Funktion |
| `const filtered` fehlt vor `return` | Whitescreen (ReferenceError) | Immer nach Refactoring prüfen |
| SVG-Attribute mit Bindestrichen (`stroke-width`) | Crash | camelCase: `strokeWidth`, `strokeLinecap` |
| `useState` in `.map()` Callback | Crash | Auf Top-Level heben |
| Doppelte `const`-Deklaration im selben Scope | Spinner | Namen prüfen |
| `data:image/base64` direkt in JSX | Crash | Extern referenzieren |
| Fehlendes schließendes `</div>` nach IIFE `})()` | Spinner | Braces-Check |

### 5.2 Firestore-Regeln

- `serverTimestamp()` **nie** in Firestore-Arrays → `new Date().toISOString()` (ISO-String)
- `orderBy()` ohne Index → 0 Ergebnisse → immer **client-seitig sortieren**
- `app_todos` = **ein** Dokument `main` mit `items[]` — keine separaten Dokumente
- `arrayUnion()` für Append auf `gewichtsverlauf[]`
- `firebase.firestore.FieldValue.serverTimestamp()` für `zuletztBearbeitetAm` OK (kein Array)

### 5.3 Navigation-Regeln

- `onClose` in allen Menü-Seiten ruft **ausschließlich `history.back()`** auf — nie State direkt setzen
- `igelMenuOpen()` immer mit Parameter aufrufen (auch `false`)
- Menü-Seiten haben **keine** eigene `history.pushState()` — das macht der Aufrufer
- Neue Seiten brauchen einen Eintrag in `_backState.current` (→ popstate-Handler)
- `detailOrigin` steuert wohin `selected` zurückspringt: `'main'` | `'pflegeplan'` | `'bestand'`

### 5.4 Neue Komponenten einfügen

- Immer **vor `MedikamentDB`** einfügen (nicht am Ende des Scripts)
- State der neuen Komponente in `_backState.current` aufnehmen
- popstate-Handler in MainApp ergänzen

---

## 6. Whitescreen-Diagnose (Checkliste)

1. Balance-Check: `python3 -c "import re; ..."`  → Braces & Parens müssen 0 sein
2. `const filtered` vorhanden **vor** `return` in jeder Listenkomponente?
3. Inline-Komponenten `const X = ()=>` innerhalb anderer? → render-Funktionen
4. HTML-String mit `<tags>` via `dangerouslySetInnerHTML`? → JSX-Children
5. `padStart(2,'0')` in Template-Literal? → String-Verkettung
6. SVG-Attribute mit Bindestrichen? → camelCase
7. `useState` in `.map()`? → Top-Level heben
8. Edit-Formular unsichtbar? → Bedingung `(showNewModal || editingId) && isAdmin`

---

## 7. Navigation & Routing (MainApp)

Alle Seitennavigation läuft über den `popstate`-Handler in MainApp. Es gibt **kein React Router** — nur `history.pushState` + ein `_backState` Ref.

### Window-Globals (von HTML und anderen Komponenten aufrufbar)

```javascript
window.__igelAction(action)              // BottomBar-Aktionen: 'home'|'bestand'|'neu'|'qr'|'pflegeplan'
window.__igelCloseAll()                  // Schließt alle Overlays (außer Menü)
window.__igelCloseAllExceptMenu()        // Schließt alle außer Menü
window.__igelDatenbank(origin)           // Öffnet DatenbankHub; origin: 'menu'|'bestand'|'settings'|'igelkarte'
window.__igelDatenbankFromIgelkarte()    // Öffnet DB ohne closeAll (selected bleibt erhalten)
window.__igelUsers()                     // Öffnet Benutzerverwaltung
window.__igelSettings()                  // Öffnet Einstellungen
window.__igelTodo()                      // Öffnet Todo-Liste
window.__igelSpec()                      // Öffnet DesignSpec
window.__igelChangelog()                 // Öffnet Changelog
window.__igelProfile()                   // Öffnet Benutzerprofil
window.__igelLogout()                    // Logout + Session löschen
window.__igelReturnEdit                  // State: Edit-Modus vor DB-Absprung (true|false|undefined)
window.__igelReturnKachel               // State: aktiver Tab vor DB-Absprung ('diagnose'|'info'|...)
window.__igelExtendSession              // Funktion: Session verlängern
window.__igelDoLogout                   // Funktion: Sofort-Logout
window.igelMenuOpen(addHistory)         // Menü öffnen (true = pushState)
window.igelMenuClose()                  // Menü schließen
window.igelMenuToggle()                 // Menü toggle
```

### _backState (popstate-Reihenfolge)

```
Menü offen           → schließen
showDatabaseDialog   → zurück zu showDatenbankHub
showTreatmentDB      → zurück zu showDatenbankHub
showMedikamentDB     → zurück zu showDatenbankHub
showDiagnoseDB       → zurück zu showDatenbankHub
showCSVImport        → zurück zu showDatenbankHub
showDatenbankHub     → schließen + Menü öffnen
showUserMgmt         → schließen + Menü öffnen
showSettings         → schließen + Menü öffnen
showTodoList         → schließen + Menü öffnen
showChangelog        → schließen + Menü öffnen
showDesignSpec       → schließen + Menü öffnen
showQRScanner        → schließen
showQuickView        → schließen + quickViewIgel=null
showProfile          → schließen + Menü öffnen
showPflegeplan       → schließen
showBestand          → schließen + bnav-home
showAddForm          → schließen
selected             → null; je nach detailOrigin: zurück zu pflegeplan|bestand|overview
(nichts)             → App-Beenden-Dialog
```

### DatenbankHub-Rücksprung (hubBack)

Wenn `datenbankHubOrigin === 'igelkarte'`: Hub schließen, `__igelReturnEdit`/`__igelReturnKachel` bleiben gesetzt → HedgehogDetail liest sie beim Mount.

Wenn anderer Origin: `__igelReturnEdit` + `__igelReturnKachel` löschen, dann zurück zu Bestand/Settings/Menü.

---

## 8. Komponenten-Referenz

### 8.1 App (Root-Komponente)

Verwaltet Auth-State, Session-Timer (8h), Routing zwischen Login/App/Loading. Session-Key: `igelSessionLoginAt`. Nach Login: `SESSION_MS = 8*60*60*1000`.

### 8.2 MainApp

**States:**
```javascript
view               'overview'|'detail'
selected           hedgehog-Objekt oder null
hedgehogs[]        Firestore-Subscription (live)
users[]            Firestore-Subscription (live)
search             Dashboard-Suchbegriff
statusFilterPills  Array von status-Strings (multi-select)
betreuerFilter     Array von Betreuer-Namen
showDatenbankHub, showMedikamentDB, showDiagnoseDB, showTreatmentDB
showCSVImport, showUserMgmt, showSettings, showTodoList, showChangelog
showDesignSpec, showProfile, showAddForm, showQRScanner, showPflegeplan
showBestand, showQuickView, quickViewIgel, quickViewInitialAction
showExitConfirm, showSessionExpired, showSessionWarning
datenbankHubOrigin  'menu'|'bestand'|'settings'|'igelkarte'
dbCounts           { meds, diags, treatments }
detailOrigin       'main'|'pflegeplan'|'bestand'
settings           aus localStorage 'igel_settings'
```

**filteredHedgehogs:** Filtert auf `statusFilterPills`, `betreuerFilter`, `search` (name/igelId/fundort/finderName).

**Render-Reihenfolge:** `showDatenbankHub` vor `selected` — verhindert dass DB über Igelkarte rendert.

### 8.3 DiagnoseDB

**Zweck:** CRUD für Diagnose-Stammdaten.

**States:**
```javascript
diagnoses[]      Firestore live-Subscription (diagnosisDatabase)
loading, search, seeding
showNewModal     true → Neu-Formular als Vollseite
editingId        ID der zu bearbeitenden Diagnose (null = keine)
showGroupPicker  GroupPicker-Panel sichtbar
newGroupInput    Eingabe für neue Gruppe
form             { name, group, severity:'mittel' }
formErr, saving
```

**Logik:**
- `existingGroups`: `[...new Set(diagnoses.map(d=>d.group).filter(Boolean))].sort()`
- `openEdit(d)`: setzt form + editingId, setzt `showNewModal=false` — Bedingung für Formular: `(showNewModal || editingId) && isAdmin`
- `saveItem()`: schreibt `{ name, group, severity }` + bei Neu: `recommendedMedications:[]`
- `deleteItem(id)`: `window.confirm` + Firestore delete
- `seedDiagnoses()`: Batch-Write aus `SEED_DIAGNOSES` Array
- Liste nach Gruppen sortiert: `[...new Set(filtered.map(d=>d.group||''))]` → Gruppe als Section-Label

**Formular-Render-Bedingung:** `(showNewModal || editingId) && isAdmin`

**Fallstricke:**
- `FlowBannerD` ist als `renderFlowBannerD()` Funktion definiert (nicht als Komponente)
- `const filtered` muss vor `return` der Listenansicht stehen

**Pfade:** DatenbankHub → DiagnoseDB → (Zurück → DatenbankHub)

### 8.4 MedikamentDB

**Zweck:** CRUD für Medikament-Stammdaten inkl. Diagnose-Verknüpfung.

**States:**
```javascript
meds[]        Firestore live (medicationDatabase, orderBy name)
diagnosesAll[] Firestore live (diagnosisDatabase, für Verknüpfungs-Checkboxen)
loading, search, seeding
showNewModal  true → Neu-Formular
editingId     ID des zu bearbeitenden Medikaments
form          { name, activeSubstance, brand, category, applicationRoutes (CSV-String),
               defaultDosage, dosageUnit, defaultFrequency, defaultDuration,
               frequencyOptions (CSV-String), linkedDiagnoses[] }
formErr, saving
```

**Logik:**
- `openEdit(m)`: joinst `applicationRoutes[]` und `frequencyOptions[]` zu CSV-Strings für Form
- `saveItem()`: splittet CSV-Strings zurück zu Arrays, schreibt in Firestore
- `toggleDiagLink(diagId)`: toggle in `form.linkedDiagnoses`
- Applikationswege: Multi-Segmented-Control → intern CSV-String → beim Speichern split zu Array
- `(showNewModal || editingId) && isAdmin` als Formular-Render-Bedingung
- `renderFlowBanner(step)` und `renderInfoBanner(children)` als Render-Funktionen (nicht Komponenten!)
- `const filtered` vor `return` Listenansicht: filtert auf name/category/activeSubstance

**Fallstricke:**
- `FlowBanner`/`InfoBanner` als Inline-Komponenten → Whitescreen (v2.4.03 Bug)
- `const filtered` fehlte → Whitescreen (v2.4.06 Bug)
- Edit-Formular: `showNewModal && isAdmin` reicht nicht, `openEdit` setzt `showNewModal=false`

**Pfade:** DatenbankHub → MedikamentDB → (Zurück → DatenbankHub)

### 8.5 TreatmentDB

**Zweck:** CRUD für Behandlungsvorlagen (Diagnose + Medikamente + Parameter).

**States:**
```javascript
templates[]    Firestore live (treatmentDatabase)
medications[]  Firestore live (medicationDatabase, für Dropdowns)
diagnoses[]    Firestore live (diagnosisDatabase, für Badge + Dropdown)
loading, search
showForm       true → Formular (Neu oder Edit)
editingId      ID der zu bearbeitenden Vorlage
expandedMed    Set<number> — welche Med-Sub-Karten aufgeklappt sind
form           { name, diagnosisId, diagnosisName, notes,
               medications: [{ medicationId, medicationName, dose, unit,
               applicationRoute, frequency, durationDays, plannedApplications,
               repeatAfterDays, notes }] }
formErr, saving
delConfirm     id der zu löschenden Vorlage
```

**Logik:**
- `emptyForm()`: neue Vorlage mit einem leeren Med-Eintrag
- `openNew()`: setzt expandedMed=`new Set([0])` (erstes Med aufgeklappt)
- `openEdit(t)`: setzt expandedMed mit allen Indices (alle aufgeklappt)
- `toggleMedExpand(i)`: toggle Set
- `addMed()`: neues leeres Med + expandiert seinen Index
- `setMed(i, field, val)`: wenn `medicationId` gesetzt → autofill name/unit/applicationRoute aus medications[]
- `calcPlanned(m)`: berechnet plannedApplications aus durationDays + frequency
- `save()`: validiert Name/diagnosisId/medications, berechnet plannedApplications, schreibt Firestore
- Diagnose-Badge: warm-stone (kein Blau), Schwere-Badge aus diagnosisDatabase lookup
- ROUTE_SHORT: `{'oral':'oral','subkutan':'s.c.','intramuskulär':'i.m.','topisch':'topisch','inhalativ':'inhal.'}`

**Pfade:** DatenbankHub → TreatmentDB → (Zurück → DatenbankHub)

### 8.6 HedgehogDetail (Igelkarte)

**Zweck:** Vollständige Ansicht + Bearbeitung eines Igels. 4 Tabs.

**Props:**
```javascript
{ hedgehog, userData, users, onBack, onUpdate, initialEditMode,
  initialAction, initialKachel, settings, onUpdateSetting, detailOrigin }
```

**Key States:**
```javascript
edit           bool — Edit-Modus aktiv
data           aktuelles hedgehog-Objekt (lokal mutiert)
originalData   Snapshot beim Öffnen (für changeHistory-Diff)
isDirty        bool — ungespeicherte Änderungen
activeKachel   'behandlung'|'gewicht'|'diagnose'|'info'
// Timeline:
tlDayStartH, tlDayEndH, tlTolMins, tlSimTime, tlNowSec
// Info-Tab Adress-Autocomplete:
infoAddrSuggs[], infoAddrLoading, infoAddrShow, infoSaveErr
infoAddrTimer (useRef)
// Modals:
showWeightModal, showDiagnosisModal, showTreatmentModal, showMedModal
showVorlageModal, showDeleteModal, showQR
treatmentDetailIdx  // Fullscreen Treatment-Detail (null = kein)
```

**Wichtige Funktionen:**

`updateField(field, value)`: setzt `data[field]`, setzt `isDirty=true`

`saveChanges()`: baut `changeHistory[]` aus Diff `originalData` vs `data`, schreibt Firestore, setzt `edit=false`

`changeStatus(newStatus)`: schreibt `status` + `statusHistory` via `arrayUnion()`

`recordApplication(treatmentIdx, medIdx)`: quittiert eine Medikamentengabe:
```javascript
// Neuer Eintrag in applications[]:
{ doneAt: new Date().toISOString(), doneBy: userData.name, weightAtTime: data.gewichtAktuell }
// completedApplications++
// done = planned > 0 && completed >= planned
// Auto-close treatment wenn alle meds done: t.status = 'abgeschlossen'
```

`deleteTreatment(idx)`: löscht aus `data.treatments[]`, schreibt Firestore

`addWeight()`: Eintrag in `gewichtsverlauf[]` + update `gewichtAktuell`

**Info-Tab Adress-Autocomplete:**
```javascript
handleInfoAddrChange(v)  // updateField + Debounce 600ms → searchInfoAddr(v)
searchInfoAddr(q)        // Nominatim-Fetch, min 3 Zeichen
selectInfoAddr(s)        // Standardformat: "Straße Nr, PLZ Ort" aus address-Feldern
```

**Info-Tab Pflichtfelder (beim Speichern):** name, geschlecht, aufnahmedatum, betreuer, status, fundort, finderName, finderTelefon

**Timeline-Helpers:**
```javascript
tlDoseTime(di, total, dayStart, dayLen)
// = dayStart + (dayLen/total)*di + (dayLen/total)*0.5
// Gibt Sekunden-Zeitpunkt für Gabe di von total Gaben

tlGetFreq(frequency)  // '3x' → 3, '2x' → 2, sonst 1

tlSlotState(med, di)  // → 'done-open'|'done-locked'|'due'|'overdue-locked'|'pending'
// Liest: tlDayStartH, tlDayEndH, tlTolMins, tlActiveSec, tlTodayStr
// Prüft applications[].doneAt heute, im Toleranzfenster um tlDoseTime
```

**Timeline 6 Zustände:**
```
done-open      Erledigt + noch im Toleranzfenster   → rückgängig möglich (✓)
done-locked    Erledigt + Fenster abgelaufen        → eingefroren (✓🔒)
due            Fällig + im Toleranzfenster          → quittierbar (◎, pulsiert amber)
overdue-locked Verpasst + Fenster abgelaufen        → gesperrt rot (●🔒)
pending        Noch nicht fällig                    → grau (○)
```

**KRITISCH:** `applications: m.applications || []` muss in **jedem** tasks.push() enthalten sein — sonst crashed tlSlotState.

**Info-Strip Berechnungen (oben in Igelkarte):**
```javascript
pflegetage   = Math.floor((new Date() - new Date(aufnahmedatum)) / 86400000)
weightTrend  = diff der letzten 2 Gewichtsmessungen
aktiveMeds   = data.medikationen.filter(m => m.aktiv !== false).length
```

**Diagnose-Tab Logik:**
- Gruppiert `data.treatments[]` nach `diagnosisName`
- `aktiveList`: treatments mit mind. einem `status==='aktiv'`
- `abgList`: treatments ohne aktives
- Stiftsymbol im Header öffnet Edit-Modus; Click auf "Zur Datenbank" speichert `__igelReturnEdit` + `__igelReturnKachel`

**Fallstricke:**
- `verlaufOpen`/`expandedDays` müssen in HedgehogDetail liegen (nicht in TRow) — Live-Uhr Re-renders
- `saveTreatment` und `saveTreatment2` existieren beide (alter + neuer Wizard-Pfad)
- `fieldClass` (Tailwind-String) noch in Basisfeldern verwendet — bei neuen Feldern inline styles

**Pfade:**
```
Dashboard/Bestand/Pflegeplan → selected=hedgehog → HedgehogDetail
HedgehogDetail → Diagnose-Tab → "Zur Datenbank" → DatenbankHub
DatenbankHub → Zurück → HedgehogDetail (mit __igelReturnEdit + __igelReturnKachel)
```

### 8.7 AddHedgehogForm (Igel erfassen)

**Zweck:** 2-Schritt-Wizard für neue Igelaufnahme.

**States:**
```javascript
step           1|2
form           { name, aufnahmedatum, status, fundort, finderName,
               finderCountryCode:'+49', finderTelefon, finderEmail,
               finderAdresse, geschlecht, alterSchaetzung, gewichtAktuell,
               betreuer, notizen, igelColor }
errors         { fieldName: true }
saving, savedHedgehog
addressSuggestions[], addressLoading, showSuggestions (Nominatim)
```

**Schritt 1:** Name (autocomplete=name), Geschlecht, Aufnahmedatum, Status, Fundort, Gewicht, Betreuer, Igelfarbe (8 Chips)

**Schritt 2:** Finder-Name (autocomplete=name), Telefon (Ländervorwahl + Nummer), E-Mail, Adresse (Nominatim), Notizen. Kann übersprungen werden.

**Igelfarbe:** 8 Töne als 2×4 Grid. Bei Neu: gespeichert als `igelColor` in Firestore.

**Adress-Autocomplete Pattern (analog Info-Tab):**
```javascript
handleAddressChange(value)  // Debounce 600ms → searchAddress(value)
searchAddress(query)        // Nominatim mit countrycodes=de
selectAddress(sug)          // display_name als finderAdresse
```

**Pflichtfelder Schritt 1:** name, fundort

**Pflichtfelder Schritt 2:** finderName, finderTelefon (wenn nicht übersprungen)

**igelId-Generierung:** `'IGL-'+Date.now()` beim Anlegen

**Pfade:** BottomBar "Neu" → AddHedgehogForm → Nach Speichern: `onOpenHedgehog(savedHedgehog)`

### 8.8 Pflegeplan

**Zweck:** Tages-Übersicht aller Medikamentengaben aller Igel als Timeline.

**States:**
```javascript
dayStartH, dayEndH, toleranceMins  — aus settings (localStorage)
simTime      -1 = live, ≥0 = Sim-Sekunden
showDaySettings  Test-Panel sichtbar
filterStatus, filterBetreuer, filterMed, filterDiag  — Filter-States
filterOpen   Dropdown-Toggle
```

**Logik:**
- Pro Igel+Behandlung+Medikament: ein "Task" mit Timeline-Slots
- `tasks.push({ ..., applications: m.applications || [] })` — PFLICHT
- `tlSlotState` = identische Logik wie in HedgehogDetail (separater Code)
- `QV_DAY_START/END/TOL_MINS` = globale Konstanten außerhalb Pflegeplan

**Uhr-Icon (amber):** öffnet Test-Panel mit 4 Reglern: Tagesbeginn, Tagesende, Toleranz, Sim-Zeit

**Pfade:** BottomBar "Pflegeplan" → Pflegeplan → Igel-Karte klicken → `onSelectHedgehog(h)` → selected in MainApp

### 8.9 QR Quick-View

**Zweck:** Bottom-Sheet nach QR-Scan — zeigt aktuelle Medikamentengaben + Gewichtseintrag.

**States in MainApp:**
```javascript
showQuickView, quickViewIgel, quickViewInitialAction
```

**KRITISCH:** `quickViewIgel` ist ein Snapshot. Immer frische Daten holen:
```javascript
const frischerIgel = hedgehogs.find(x => x.id === quickViewIgel.id);
```

**Konstanten (außerhalb Komponente):**
```javascript
const QV_DAY_START = 6*3600;
const QV_DAY_END   = 22*3600;
const QV_DAY_LEN   = QV_DAY_END - QV_DAY_START;
const QV_TOL_MINS  = 120;
```

**Badge-Logik:**
```
allDone → grün  "erledigt"
hasOv   → rot   "überfällig"
hasDue  → amber "fällig"      (nur wenn Slot im Toleranzfenster liegt!)
sonst   → grau  "ausstehend"
```

**Pfade:** BottomBar "QR" → QRScanner → scan → showQuickView=true

### 8.10 DashboardDonut

**Zweck:** Donut-Chart auf Dashboard mit Status-Segmenten.

**Props:** `{ hedgehogs, activeFilter, onSegmentClick, onClearFilter }`

Klick auf Segment → `onSegmentClick(status)` → `statusFilterPills` in MainApp

### 8.11 IgelBestand

**Zweck:** Vollständige Liste aller Igel mit Filtern.

**Filter:** Status (multi-select Chips), Betreuer (multi-select), Gewicht (Trend-Filter), Suche

**Pfade:** BottomBar "Bestand" → IgelBestand → Karte klicken → `onSelectHedgehog(h)`, setzt `detailOrigin='bestand'`

### 8.12 MedikationDatenbank (Legacy-Stammdaten)

Älteres System für med_gruppen/med_behandlungen/med_arten/med_haeufigkeiten. Wird vom TreatmentWizard genutzt. Parallel zur neueren medicationDatabase/diagnosisDatabase.

### 8.13 TreatmentWizard

4-Schritt-Assistent: Diagnose-Gruppe → Diagnose → Medikament → Dosis/Parameter. Nutzt `diagDB` + `medDB` aus HedgehogDetail. `linkedDiagnoses` aus Medikament steuert Vorschläge.

### 8.14 UserManagement

**Rollen:** `admin` | `pfleger` | `gast`

Nur Admin sieht diese Seite. Kann Rollen ändern, Benutzer deaktivieren, Einladungscodes generieren.

### 8.15 SettingsDialog + TimelineSettingsPage

Timeline-Parameter persistent in localStorage `igel_settings`:
```javascript
{ tlDayStartH:6, tlDayEndH:22, tlTolMins:120, tlSimTime:-1 }
```

`openInEditMode`: bool — Igelkarte öffnet standardmäßig im Edit-Modus

---

## 9. Datenstrukturen

### hedgehog (Firestore: hedgehogs/{id})
```javascript
{
  id,                    // Firestore-ID
  igelId,               // "IGL-{timestamp}"
  name, geschlecht,     // "männlich"|"weiblich"|"unbekannt"
  alterSchaetzung,      // Wochen (String)
  gewichtAktuell,       // g (Number)
  aufnahmedatum,        // "YYYY-MM-DD"
  status,               // "aufnahme"|"pflege"|"ueberwinterung"|"auswilderung_bereit"|"ausgewildert"|"verstorben"
  betreuer,
  fundort,
  finderName, finderTelefon, finderCountryCode, finderEmail,
  finderAdresse,        // "Straße Nr, PLZ Ort" (via Nominatim standardisiert)
  igelColor,            // Hex aus IGEL_COLORS[]
  notizen,              // String
  erstelltVon, erstelltAm,
  zuletztBearbeitetVon, zuletztBearbeitetAm,  // serverTimestamp OK hier
  statusHistory: [{ status, datum, geaendertVon }],
  changeHistory: [{ field, oldValue, newValue, changedBy, changedAt }],
  gewichtsverlauf: [{ datum, gewicht, notiz, erfasstVon, erfasstAm }],
  treatments: [{
    templateName, diagnosisName, diagnosisId, status,   // 'aktiv'|'abgeschlossen'
    startDate, notes,
    medications: [{
      medicationName, medicationId, dose, unit, applicationRoute,
      frequency, plannedApplications, completedApplications,
      done,           // bool: completed >= planned
      applications: [{  // PFLICHT für Timeline — NIE leer-initialisieren!
        doneAt,       // ISO-String
        doneBy,
        weightAtTime
      }]
    }]
  }]
}
```

### medicationDatabase
```javascript
{ name, activeSubstance, brand, category,
  applicationRoutes: [],   // Array, gespeichert als Array
  defaultDosage, dosageUnit,
  defaultFrequency, defaultDuration,
  frequencyOptions: [],    // Array
  linkedDiagnoses: []      // Array von diagnosisDatabase-IDs
}
```

### diagnosisDatabase
```javascript
{ name, group, severity,   // 'leicht'|'mittel'|'schwer'
  recommendedMedications: []  // bei Neu angelegt, derzeit ungenutzt
}
```

### treatmentDatabase
```javascript
{ name, diagnosisId, diagnosisName, notes,
  medications: [{
    medicationId, medicationName, dose, unit, applicationRoute,
    frequency, durationDays, plannedApplications, repeatAfterDays, notes
  }],
  lastModified, createdBy, createdAt, usageCount
}
```

---

## 10. Igel-Farbpalette

```javascript
const IGEL_COLORS = ['#5c5248','#6b4f38','#4a6352','#5c4a6b','#7a5c34','#4a5568','#5a4a3a','#3d5a4a'];
const COLOR_NAMES = ['Kakao','Kastanie','Salbei','Pflaume','Umber','Schiefer','Mokka','Moos'];
// Bei Anlage in Firestore gespeichert (igelColor)
// Deterministisch aus igelId wenn kein igelColor: hash % 8
```

---

## 11. Rollen & Auth

```
admin    Vollzugriff: Benutzerverwaltung, alle CRUD, Datenbank-Seeding
pfleger  Standard: Igel anlegen/bearbeiten, Gaben quittieren
gast     Nur lesen, keine Schreiboperationen
```

Session: `SESSION_MS = 8*60*60*1000` (8h), Key: `igelSessionLoginAt`

Firebase: `apiKey: "AIzaSyD1LbzZGypzSYvRC-RRNvT2JUTpPRMM8E4"`, projectId: `igelstation-3c3db`

---

## 12. Versionshistorie

| Version | Feature |
|---------|---------|
| 2.4.07 | Info-Tab: Labels, Nominatim Autocomplete, Telefon-Vorwahl, Autofill, Pflichtfelder, Segmented Geschlecht, Sticky Save-Bar |
| 2.4.06 | Fix: `const filtered` fehlte in MedikamentDB Liste |
| 2.4.05 | Fix: dangerouslySetInnerHTML HTML-String → JSX-Children |
| 2.4.04 | Fix: FlowBanner/InfoBanner als render-Funktionen; `(showNewModal\|\|editingId)` |
| 2.4.03 | MedikamentDB + DiagnoseDB Redesign: Karten/Badges/FlowBanner/InfoBanner/Segmented |
| 2.4.02 | Datenbank Reihenfolge: Diagnose → Medikament → Behandlung |
| 2.4.01 | TreatmentDB Redesign: warm-stone, Sub-Karten, Segmented, Bottom-Sheet Delete |
| 2.4.00 | Rücksprung Igelkarte → Datenbank: `__igelReturnEdit`/`Kachel`, `initialKachel` |
| 2.3.99 | Fix: Datenbank-Button Diagnose-Tab — showDatenbankHub vor selected |
| 2.3.98 | Navigation Origin-System — datenbankHubOrigin, hubBack() |
| 2.3.97 | Igelkarte Header: Stift direkt + Uhr amber |
| 2.3.96 | Diagnose-Tab: Workflow-Banner, Behandlungs-Links, × beendet Behandlung |
| 2.3.95 | Igelfarbe: Dropdown 8 Töne bei Anlage |
| 2.3.94 | Igelfarbe: deterministisch aus igelId, Firestore gespeichert |
| 2.3.93 | Profil: Passwort ohne Reauthentifizierung |
| 2.3.91 | Redesign Profil/Datenbank/Einstellungen/Benutzer: warm-stone |
| 2.3.90 | Menü: 2×3 Kachel-Grid |
| 2.3.85 | IgelBestand + Dashboard-Donut |
| 2.3.78 | BottomBar + Menü Redesign: Swipe-Up |
| 2.3.77 | Igel erfassen: warm-stone, 8px Labels |
| 2.3.66 | Header vereinheitlicht: 15px/800/DM Sans/2px Border |
| 2.3.64 | Timeline-Settings shared localStorage |
| 2.3.61 | QR Quick-View Pills + Toleranz-Logik |
| 2.3.58 | Igelkarte Timeline Design F |
| 2.3.54 | Toleranz-Logik 6 Zustände |
| 2.3.50 | Fix: tapped nach Firestore-Write entfernen |
| 2.3.37 | QR Quick-View Bottom-Sheet |
| 2.3.30 | Bottom-Navigation Scroll-Hiding |
| 2.2.00 | TreatmentWizard 4-Schritt |
| 2.0.00 | DatenbankHub |
| 1.8.00 | RBAC + Donut-Chart |
| 1.0.00 | Launch |

---

## 13. Roadmap

- [ ] `completedApplications++` korrekt aus Pflegeplan quittieren
- [ ] Diagnose-Dropdown statt Freitext im Behandlungs-Wizard
- [ ] Auto-Navigation in neue Igelkarte nach Erfassung
- [ ] Toleranz/Tagesbeginn/Ende in App-Einstellungen (Admin, persistent)
- [ ] Printable Datenblatt pro Igel
- [ ] Push-Notifications für fällige Gaben
- [ ] Foto-Upload pro Igel

---

*Zuletzt aktualisiert: März 2026 · v2.4.07*
