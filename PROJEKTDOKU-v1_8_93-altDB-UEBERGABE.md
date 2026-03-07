# IGELPFLEGESTATION PRO — Vollständige Projektdokumentation
## Übergabedokument für nahtlose Weiterentwicklung
**Version:** v1.8.70-altDB  
**Stand:** März 2026  
**Entwickler:** Denis-Alexander Stindl  
**Datei:** `index.html` (Single-File PWA, ~380 KB, ~7.171 Zeilen)

---

## ÜBERGABE-PAKET (IMMER BEREITSTELLEN)

### Pflichtregeln für jede neue Version:
1. **ZIP-Datei** `IGELSTATION.zip` bereitstellen — enthält ALLE Dateien
2. **Changelog** in `Changelog`-Komponente in index.html aktualisieren
3. **Versionsnummer erhöhen** — HTML-Kommentar oben UND Changelog-Header (`"Version X.X.XX"`) UND `msheet-version` im HTML
4. **service-worker.js** Cache-Name auf neue Version setzen
5. **Keine Einzeldateien** mehr separat bereitstellen — nur noch das ZIP

### ZIP-Inhalt (immer `IGELSTATION.zip`):
| Datei | Zweck |
|---|---|
| `index.html` | Deployment → GitHub Pages Root (= aktuelle altDB-HTML) |
| `igelpflegestation-vX.X.XX-altDB.html` | Versionierte lokale Sicherung |
| `PROJEKTDOKU-vX.X.XX-altDB-UEBERGABE.md` | Diese Dokumentation |
| `service-worker.js` | Offline-Cache (Cache-Name = Versionsnummer) |
| `icon-192.png` | App-Icon Android/PWA |
| `icon-512.png` | App-Icon hochauflösend |
| `deploy.sh` | Git-Deploy-Script |
| `update.sh` | Haupt-Update-Script (pull → kopieren → deploy) |

**Wichtig:** ZIP immer als `IGELSTATION.zip` — einheitlicher Name für Termux `update`-Befehl.

### Deploy-Kommandos nach jeder Änderung:
```
update
```

---

## 1. PROJEKT-ÜBERBLICK

Eine Progressive Web App (PWA) zur Verwaltung von Igelpflegestationen. Vollständig in einer einzigen HTML-Datei. Kein Build-System, kein npm — direkt via GitHub Pages hostbar. React-JSX wird im Browser durch Babel Standalone kompiliert.

**Live-URL:** https://dstindl.github.io/IGELSTATION_nei/  
**Repository:** github.com/dstindl/IGELSTATION_nei  
**Branch:** `main` — Datei: `index.html`

---

## 2. TECHNOLOGIE-STACK

### CDN-Scripts (in dieser Reihenfolge im `<head>`)
```html
<!-- Stabile, gepinnte Versionen auf cdnjs — NICHT unpkg.com (auf Mobile unzuverlässig) -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/react/18.2.0/umd/react.production.min.js" crossorigin="anonymous"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/react-dom/18.2.0/umd/react-dom.production.min.js" crossorigin="anonymous"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/babel-standalone/7.23.5/babel.min.js" crossorigin="anonymous"></script>
<script src="https://cdn.tailwindcss.com"></script>
<script src="https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/10.7.1/firebase-auth-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/10.7.1/firebase-firestore-compat.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/qrcodejs/1.0.0/qrcode.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/jsqr@1.4.0/dist/jsQR.js"></script>
```

**WICHTIG:** Niemals zurück auf `unpkg.com` — führt auf Android zu `Script error. 0:0` Whitescreen.

### Firebase Konfiguration
```javascript
const firebaseConfig = {
  apiKey: "AIzaSyD1LbzZGypzSYvRC-RRNvT2JUTpPRMM8E4",
  authDomain: "igelstation-3c3db.firebaseapp.com",
  projectId: "igelstation-3c3db",
  storageBucket: "igelstation-3c3db.firebasestorage.app",
  messagingSenderId: "695889743897",
  appId: "1:695889743897:web:6ca27f35d25639c66b9a88"
};
```

---

## 3. DESIGN-SYSTEM (STRIKT EINHALTEN)

### Grundprinzip: Schwarz/Weiß Minimalistisch
**NIEMALS:** `bg-blue-*`, `bg-green-*`, Gradient-Klassen — **außer** Status-Badges.

### Vollseiten-Muster (ab v1.8.50 — KRITISCH)
Alle Menü-Seiten sind seit v1.8.54 vollständig als Vollseiten implementiert.
**Niemals** Menü-Seiten als Modal zurückbauen.

**Vollseiten-Wrapper:**
```jsx
<div className="min-h-screen bg-gray-50 pb-20 fade-in">
  <div className="sticky top-0 bg-white flex items-center justify-between px-4 py-3 border-b border-gray-100 z-10">
    <button onClick={onClose} className="flex items-center gap-2 text-gray-600 hover:text-gray-900 transition-all">
      <svg ...Pfeil-Links.../> 
      <span className="text-sm font-medium">Zurück</span>
    </button>
    <h2 className="text-sm font-semibold text-gray-900">Seitenname</h2>
    <div style={{width:'64px'}}/> {/* Spacer für Zentrierung */}
  </div>
  <div className="p-5 space-y-5">
    {/* Inhalt */}
  </div>
</div>
```

**Early-Return-Muster in MainApp (vor dem Haupt-return):**
```jsx
if (showDesignSpec)   return <DesignSpec onClose={() => setShowDesignSpec(false)} />;
if (showTodoList)     return <TodoList onClose={() => setShowTodoList(false)} userData={userData} />;
if (showSettings)     return <SettingsDialog settings={settings} onUpdate={updateSetting} onClose={() => setShowSettings(false)} />;
if (showDatenbankHub) return ( <div className="min-h-screen ..."> ... </div> );
if (showChangelog)    return <Changelog onClose={() => setShowChangelog(false)} />;
if (showProfile)      return <UserProfile ... />;
if (showUserMgmt)     return <UserManagement ... />;
if (showAddForm)      return <AddHedgehogForm ... />;
```

### Tailwind-Klassen-Vokabular

**Primär-Button (schwarz):**
`bg-gray-900 text-white rounded-xl py-3 text-sm font-medium hover:bg-gray-700 transition-all`

**Sekundär-Button (Rahmen):**
`border border-gray-200 text-gray-600 rounded-xl py-3 text-sm font-medium hover:bg-gray-50 transition-all`

**Eingabefelder:**
`border border-gray-200 rounded-xl px-4 py-3 text-sm focus:outline-none focus:border-gray-400`

**Labels für Formularfelder:**
`block text-xs font-semibold text-gray-600 mb-1`

**Sub-Modals (innerhalb einer Vollseite, z-60):**
`fixed inset-0 bg-black bg-opacity-60 z-60 flex items-center justify-center p-4`
Innen: `bg-white rounded-2xl w-full max-w-sm shadow-xl`

**Badges:**
- Schwer/Aktiv: `bg-gray-900 text-white text-[10px] px-1.5 py-0.5 rounded-full font-medium`
- Mittel: `bg-gray-100 text-gray-600`
- Leicht: `bg-gray-50 text-gray-400`

**z-Index Hierarchie:**
- `z-10` — Sticky Vollseiten-Header
- `z-40` — Alte Sticky Header (Igelkarte etc.)
- `z-50` — Standard-Modals (QR-Scanner, Betreuer-Dialog etc.)
- `z-60` — Sub-Aktions-Modals (Form, Delete-Confirm innerhalb Vollseiten)

**Status-Badges (farbig, einzige Ausnahme):**
- aufnahme: `bg-red-100 text-red-800`
- pflege: `bg-blue-100 text-blue-800`
- ueberwinterung: `bg-blue-200 text-blue-900`
- ausgewildert: `bg-gray-100 text-gray-800`
- verstorben: `bg-black text-white`

---

## 4. ARCHITEKTUR & KRITISCHE REGELN

### Single-File Babel JSX — Einschränkungen
- **KEINE Emojis** in JSX-Expressions (`{}`, `className={}`) — bricht Babel auf Android
- Emojis in JSX-Text (`<p>OK</p>`) und `<option>` sind OK
- Alle `─` Box-Chars nur in JS-Kommentaren
- Babel 7.23.5: unterstützt `?.`, Template Literals, Arrow Functions
- **Dateigröße unter 400 KB** halten
- **Hyphenierte SVG-Attribute** (z.B. `stroke-width`) sind in JSX ungültig → immer camelCase (`strokeWidth`)

### Neue Komponenten einfügen
**IMMER vor `MedikationDatenbank` einfügen** (damit vor `HedgehogDetail` definiert).
Position prüfen: `babel_script_start < neue_komponente_position < babel_script_end`

### Menü-Seiten Konvertierungs-Muster (3 Schritte — ab v1.8.50)
1. **Komponente umbauen:** `fixed inset-0 ... z-50` → `min-h-screen bg-gray-50 pb-20` + sticky Back-Header
2. **Early return** in `MainApp` vor dem Haupt-`return (...)` hinzufügen: `if (showX) return <X />;`
3. **Inline-Render entfernen:** `{showX && <X />}` aus dem Haupt-Return löschen

### Komponenten-Reihenfolge (v1.8.54, Zeilennummern ca.)
```
1-330:    Firebase Init, CSS, BottomNav HTML, loadSettings
331-629:  App (Auth-Wrapper), LoadingScreen, LoginScreen
630-999:  PasswordSetup, PasswordReset, AdminSetup, InviteRegistration
1000-1153: DashboardDonut
1154-1202: SEED_MEDICATIONS, SEED_DIAGNOSES
1203-1530: MedikamentDB
1530-1850: DiagnoseDB
1850-2200: TreatmentWizard
2200-2800: MedikationDatenbank (LEGACY — nicht entfernen!)
2800-3077: TodoList (Vollseite seit v1.8.53)
3077-3600: MainApp (State, useEffects, Early Returns)
3600-4050: MainApp Haupt-Return (Dashboard, Igelliste, Modals)
4050-4280: CSVImportDialog
4280-4520: Changelog (Vollseite seit v1.8.50)
4520-4820: UserProfile, QRScannerModal
4820-4870: SettingsDialog (Vollseite seit v1.8.52)
4870-5100: UserManagement
5100-5350: AddHedgehogForm (Vollseite seit v1.8.49)
5350-6800: HedgehogDetail + MedCard + Medikation-Modal
6800-6940: DESIGN_SPEC Konstante
6940-7020: DesignSpec (Vollseite seit v1.8.54)
7020-7031: ReactDOM.render, ServiceWorker
```

---

## 5. FIREBASE DATENBANK-STRUKTUR

### Collections — Vollständig

#### `users/{uid}`
```javascript
{ name, email, role: 'admin'|'mitarbeiter'|'gast', active: true, deleted: false,
  createdAt, hasPassword: true, inviteCode, countryCode, telefon, adresse }
```

#### `hedgehogs/{id}`
```javascript
{
  name, status, aufnahmedatum, igelId: "IGL-"+Date.now(),
  fundort, finderName, finderCountryCode, finderTelefon, finderEmail, finderAdresse,
  geschlecht, alterSchaetzung, gewichtAktuell, betreuer, notizen,
  ueberwinterungAktiv, ueberwinterungStart, ueberwinterungGewicht,
  gewichtVerlauf: [{ datum, gewicht, erfasstVon }],
  diagnosen: [{ datum, diagnose, erfasstVon }],
  behandlungen: [{ datum, behandlung, erfasstVon }],
  medikationen: [{
    datum, behandlungName, artName, menge, haeufigkeit,
    applicationRoute, plannedApplications, completedApplications: 0,
    aktiv: true, diagnosisId, medicationId, _medRefId?,
    erfasstVon, einheit, notiz
  }],
  statusHistory: [{ status, geaendertVon, geaendertAm }],
  changeHistory: [{ field, oldValue, newValue, changedBy, changedAt }],
  aufgenommenVon, aufgenommenAm, zuletztBearbeitetVon, zuletztBearbeitetAm
}
```

#### `medicationDatabase/{id}` (AltDB)
```javascript
{
  name, activeSubstance, brand, category,
  applicationRoutes: ['oral','subkutan'],
  defaultDosage: '0.4',
  dosageUnit: 'mg/kg',        // mg/kg | ml/kg | mg | ml | ""
  defaultFrequency: 'einmalig',
  defaultDuration: 1,
  frequencyOptions: ['einmalig','nach 14 Tagen'],
  linkedDiagnoses: ['diagnosisDb-doc-id', ...],
}
```

#### `diagnosisDatabase/{id}` (AltDB)
```javascript
{
  name, group, severity: 'leicht'|'mittel'|'schwer',
  recommendedMedications: ['medicationDb-doc-id', ...],
}
```

#### `medikationen/{id}` (Optional, permission-geschützt)
Separate Tracking-Collection. `saveTreatment` schreibt hier **optional** (try-catch). Pflicht-Schreiben läuft über `hedgehogs.medikationen[]`.

#### `invites/{id}`, `auditLog/{id}`, `app_todos/main`
`app_todos/main.items[]` Array mit `{ id, label, desc, priority, done }`.

#### Legacy: `med_gruppen`, `med_behandlungen`, `med_arten`, `med_haeufigkeiten`
**Nicht entfernen** — `MedikationDatenbank`-Komponente liest/schreibt diese.

---

## 6. FIRESTORE SECURITY RULES

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function userRole() { return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role; }
    function isAdmin()    { return request.auth != null && userRole() == 'admin'; }
    function isStaff()    { return request.auth != null && userRole() in ['admin','mitarbeiter']; }
    function isLoggedIn() { return request.auth != null; }

    match /users/{userId}           { allow read: if isLoggedIn(); allow write: if isLoggedIn() && request.auth.uid == userId; }
    match /hedgehogs/{hedgehogId}   { allow read: if isLoggedIn(); allow write: if isStaff(); }
    match /invites/{inviteId}       { allow read: if isLoggedIn(); allow write: if isAdmin(); }
    match /auditLog/{logId}         { allow read, write: if isLoggedIn(); }
    match /app_todos/{docId}        { allow read, write: if isAdmin(); }
    match /medicationDatabase/{id}  { allow read: if isLoggedIn(); allow write: if isAdmin(); }
    match /diagnosisDatabase/{id}   { allow read: if isLoggedIn(); allow write: if isAdmin(); }
    match /medikationen/{id}        { allow read: if isLoggedIn(); allow write: if isStaff(); }
    match /med_gruppen/{id}         { allow read: if isLoggedIn(); allow write: if isAdmin(); }
    match /med_behandlungen/{id}    { allow read: if isLoggedIn(); allow write: if isAdmin(); }
    match /med_arten/{id}           { allow read: if isLoggedIn(); allow write: if isAdmin(); }
    match /med_haeufigkeiten/{id}   { allow read: if isLoggedIn(); allow write: if isAdmin(); }
  }
}
```

---

## 7. NAVIGATION & VOLLSEITEN (ab v1.8.50)

### Vollseiten-Navigationsfluss
```
Menü-Button → igelMenuClose() → window.__igelXxx() → setShowXxx(true)
→ MainApp early return → Vollseite rendert
← Zurück-Button → onClose() → setShowXxx(false) → MainApp normaler Return
```

### Konvertierte Seiten (vollständig ab v1.8.70)
| Seite | State | Zurück-Ziel |
|---|---|---|
| Igel erfassen | `showAddForm` | Hauptseite |
| Info & Changelog | `showChangelog` | Menü |
| Datenbank-Hub | `showDatenbankHub` | Menü |
| Einstellungen | `showSettings` | Menü |
| To-Do | `showTodoList` | Menü |
| App Spezifikation | `showDesignSpec` | Menü |
| Datensätze (CSV) | `showDatabaseDialog` | Datenbank-Hub |
| Medikamente-DB | `showMedikamentDB` | Datenbank-Hub |
| Diagnosen-DB | `showDiagnoseDB` | Datenbank-Hub |
| QR-Scanner | `showQRScanner` | Hauptseite |

---

## ⚠️ ANDROID ZURÜCK-TASTE — KRITISCHE REGELN (ab v1.8.70)

### Prinzip: pushState beim Vorwärts-Navigieren, NIE beim Zurück

**IMMER** wenn eine neue Seite / das Menü geöffnet wird → `history.pushState` aufrufen.  
**NIE** im Back-Handler extra `pushState` aufrufen (außer auf der Hauptseite als Puffer).

```
Stack-Beispiel korrekt:
  App-Start:           [PUFFER, BASE]
  Menü öffnen:         [PUFFER, BASE, MENU]
  Datenbank öffnen:    [PUFFER, BASE, MENU, DB]
  Datensätze öffnen:   [PUFFER, BASE, MENU, DB, DATENSAETZE]

  Back → Datensätze weg → [PUFFER, BASE, MENU, DB]       → zeige DB
  Back → DB weg          → [PUFFER, BASE, MENU]           → zeige Menü
  Back → MENU weg        → [PUFFER, BASE]                 → schließe Menü
  Back → BASE weg        → [PUFFER]                       → Exit-Dialog + reBase
```

### Neue Seite hinzufügen — 5-Punkte-Checkliste

**1. State-Variable anlegen:**
```javascript
const [showNeueSeite, setShowNeueSeite] = useState(false);
```

**2. Early Return in MainApp (vor dem Haupt-return):**
```javascript
if (showNeueSeite) return <NeueSeite onClose={() => {
  setShowNeueSeite(false);
  window.igelMenuOpen && window.igelMenuOpen(false); // NUR wenn Zurück → Menü
  // KEIN history.back() hier nötig
}} />;
```

**3. pushState beim Öffnen der Seite:**
```javascript
// Im Menü-Button-Handler oder window.__igelXxx():
setShowNeueSeite(true);
history.pushState({ page: 'neueSeite' }, '');
```

**4. _backState.current erweitern:**
```javascript
_backState.current = {
  // ... alle anderen States ...
  showNeueSeite,  // ← NEU hinzufügen
};
```

**5. Back-Handler ergänzen — an richtiger Position:**
```javascript
// Sub-Seite (Zurück → Hub):
if (s.showNeueSeite) { setShowNeueSeite(false); setShowDatenbankHub(true); return; }

// ODER Top-Level-Seite (Zurück → Menü):
if (s.showNeueSeite) { setShowNeueSeite(false); window.igelMenuOpen && window.igelMenuOpen(false); return; }
```

### igelMenuOpen(false) — KRITISCH

`igelMenuOpen()` ohne Parameter pusht `{page:'menu'}` in die History.  
`igelMenuOpen(false)` öffnet das Menü **ohne** neuen History-Eintrag zu pushen.

**Wann welche Variante:**
- Menü-Button in BottomNav drücken → `igelMenuOpen()` (pusht)
- Im Back-Handler nach Schließen einer Seite → `igelMenuOpen(false)` (pusht NICHT)
- In `onClose`-Callbacks der Vollseiten → `igelMenuOpen(false)` + `history.back()`

**Warum:** Würde `igelMenuOpen()` im Back-Handler aufgerufen werden, entsteht ein Phantom-Eintrag:
```
Stack: [BASE, MENU, DB]
Back → DB weg → [BASE, MENU]
Handler ruft igelMenuOpen() → pushed MENU2 → [BASE, MENU, MENU2]  ← FALSCH!
Nächstes Back: MENU2 weg → Menü noch sichtbar → nix passiert
Übernächstes Back: MENU weg → App schließt statt Exit-Dialog
```

### Vollständiger Back-Handler (Reihenfolge beachten!)
```javascript
const handleBack = () => {
  const s = _backState.current;
  const reBase = () => history.pushState({ igelApp: true, level: 1 }, '');

  // 1. Menü offen → schließen (höchste Priorität)
  var menuSheet = document.getElementById('menu-sheet');
  if (menuSheet && menuSheet.classList.contains('open')) {
    window.igelMenuClose && window.igelMenuClose();
    return;
  }

  // 2. Sub-Seiten → zurück zum Hub (KEIN extra push)
  if (s.showDatabaseDialog) { setShowDatabaseDialog(false); setShowDatenbankHub(true); return; }
  if (s.showMedikamentDB)   { setShowMedikamentDB(false);   setShowDatenbankHub(true); return; }
  if (s.showDiagnoseDB)     { setShowDiagnoseDB(false);     setShowDatenbankHub(true); return; }
  if (s.showCSVImport)      { setShowCSVImport(false);      setShowDatenbankHub(true); return; }

  // 3. Top-Level-Seiten → Menü öffnen (KEIN extra push — false!)
  if (s.showDatenbankHub) { setShowDatenbankHub(false); window.igelMenuOpen&&window.igelMenuOpen(false); return; }
  if (s.showSettings)     { setShowSettings(false);     window.igelMenuOpen&&window.igelMenuOpen(false); return; }
  if (s.showTodoList)     { setShowTodoList(false);     window.igelMenuOpen&&window.igelMenuOpen(false); return; }
  if (s.showChangelog)    { setShowChangelog(false);    window.igelMenuOpen&&window.igelMenuOpen(false); return; }
  if (s.showDesignSpec)   { setShowDesignSpec(false);   window.igelMenuOpen&&window.igelMenuOpen(false); return; }
  if (s.showUserMgmt)     { setShowUserMgmt(false);     window.igelMenuOpen&&window.igelMenuOpen(false); return; }

  // 4. Sonstige Seiten ohne Menü-Rückkehr
  if (s.showQRScanner)    { setShowQRScanner(false);    return; }
  if (s.showProfile)      { setShowProfile(false);      return; }
  if (s.showAddForm)      { setShowAddForm(false);      return; }
  if (s.view === 'detail') { setView('overview'); setSelected(null); return; }

  // 5. Hauptseite → Exit-Dialog + Puffer neu aufbauen
  setShowExitConfirm(true);
  reBase();
};
```

---

## 8. BEKANNTE PROBLEME & LÖSUNGEN

| Problem | Ursache | Lösung |
|---|---|---|
| Whitescreen / "Script error. 0:0" auf Mobile | CDN `unpkg.com` | Nur `cdnjs.cloudflare.com` |
| Babel Syntaxfehler | Emoji in JSX-Expression | Niemals in `{}` oder `className={}` |
| Babel Syntaxfehler | Hyphenierte SVG-Attrs | camelCase: `strokeWidth` statt `stroke-width` |
| Menü schließt aber Seite erscheint nicht | Modal statt early return | Early return VOR Haupt-`return()` in MainApp |
| PERMISSION_DENIED Whitescreen | Firestore Rules geändert | try-catch in `onAuthStateChanged` |
| Back-Taste schließt App sofort | Nur 1 History-Eintrag beim Start | `replaceState(PUFFER)` + `pushState(BASE)` beim Mount |
| Back-Taste tut nichts (2× nötig) | Extra `pushState` im Handler erzeugt Phantom-Eintrag | Im Back-Handler NIE extra pushen — nur `reBase()` auf Hauptseite |
| Nach Seite→Menü→Back schließt App | `igelMenuOpen()` pusht extra Eintrag beim Zurücknavigieren | `igelMenuOpen(false)` im Back-Handler verwenden |
| popstate feuert nicht | Alter zweiter Handler überschreibt | Nur EINEN popstate-Listener aktiv lassen |
| Stale closure im Handler | `useEffect` mit State-Dependencies re-registriert | `useRef` als State-Snapshot + leere Deps `[]` |

---

## 9. OFFENE FEATURES (Priorisiert)

### Priorität Hoch
1. **Behandlungsfortschritt:** "Gabe durchgeführt" Button → `completedApplications++`. Anzeige: `2/5 Gaben`.
2. **`recommendedMedications` befüllen:** In DiagnoseDB beim Bearbeiten Checkboxen für Medikamente.
3. **Diagnosen-Dropdown in Igelkarte:** Freie Texteingabe durch `diagnosisDatabase`-Dropdown ersetzen.

### Priorität Mittel
4. **Legacy-System ablösen:** `MedikationDatenbank` + `med_*` Collections entfernen wenn bereit.
5. **Gewicht-Chart:** SVG Liniendiagramm im Gewichts-Abschnitt.
6. **Druckansicht:** Alle Daten eines Igels als druckbares Formular.

### Priorität Niedrig
7. **Offline-Modus:** Service Worker für read-only ohne Internet.
8. **Backup/Restore:** Admin-Export als JSON.

---

## 10. DEPLOYMENT

### GitHub Pages
```
Repo: github.com/dstindl/IGELSTATION_nei | Branch: main | Datei: index.html (Wurzel)
```

### Termux Deploy (Standard)
```bash
update    # pull → entpacken → deploy in einem Befehl
```

---

## 11. VERSIONSHISTORIE

| Version | Datum | Feature |
|---|---|---|
| **v1.8.70-altDB** | März 2026 | Android Back: Phantom-History-Fix, igelMenuOpen(false), Exit-Dialog |
| v1.8.66-altDB | März 2026 | Android Back: alle Konflikte behoben, korrekter Stack |
| v1.8.62-altDB | März 2026 | Android Back: History-Buffer (2 Einträge beim Start) |
| v1.8.59-altDB | März 2026 | To-Do Aufgabe-Formular als Vollseite |
| v1.8.57-altDB | März 2026 | Diagnosen-DB als Vollseite |
| v1.8.56-altDB | März 2026 | Medikamente-DB als Vollseite |
| v1.8.55-altDB | März 2026 | Datensätze (CSV) als Vollseite |
| v1.8.54-altDB | März 2026 | App Spezifikation als Vollseite — alle Menü-Seiten konvertiert |
| v1.8.53-altDB | März 2026 | To-Do als Vollseite |
| v1.8.52-altDB | März 2026 | Einstellungen als Vollseite |
| v1.8.51-altDB | März 2026 | Datenbank-Hub als Vollseite |
| v1.8.50-altDB | März 2026 | Info & Changelog als Vollseite (Bugfix: early return) |
| v1.8.49-altDB | März 2026 | Igel erfassen als Vollseite, BottomBar Fixes |
| v1.8.48-altDB | März 2026 | BottomBar Navigation, Edge-to-Edge Design, Menü-Sheet |
| v1.8.44-altDB | Feb 2026 | MedikamentDB + DiagnoseDB + TreatmentWizard, 20 Seeds |
| v1.8.43-altDB | Feb 2026 | CDN-Fix (cdnjs), Auth try-catch Whitescreen |
| v1.8.29 | Dez 2025 | QR-Code, Scanner, Rollen, Donut-Charts |

---

## 12. SCHNELL-START FÜR NEUEN CHAT

Kopiere folgendes in den neuen Chat und lade `index.html` + diese Dokumentation hoch:

> "Ich entwickle **Igelpflegestation Pro** — eine Single-File React PWA (`index.html`, ~380KB, **v1.8.70-altDB**).  
> Stack: React 18 + Babel Standalone auf cdnjs, Firebase 10.7.1, Tailwind CSS CDN, GitHub Pages.  
> Design: **schwarz/weiß minimalistisch**, KEINE Farben außer Status-Badges.  
> Alle Menü-Seiten sind **Vollseiten** (early return Muster) — KEIN Modal für Menü-Navigation.  
> Android Zurück-Taste: `history.pushState` beim Öffnen, `igelMenuOpen(false)` im Back-Handler, niemals extra Push im Handler.  
> Neue Komponenten gehören **vor `MedikationDatenbank`** in den `<script type='text/babel'>` Tag.  
> ZIP heißt immer `IGELSTATION.zip`. Deploy-Befehl: `update`  
> Bitte lies zuerst die Projektdokumentation `PROJEKTDOKU-v1_8_70-altDB-UEBERGABE.md`."
