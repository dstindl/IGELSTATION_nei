# IGELPFLEGESTATION PRO — Vollständige Projektdokumentation
## Übergabedokument für nahtlose Weiterentwicklung
**Version:** v1.8.47-altDB  
**Stand:** März 2026  
**Entwickler:** Denis-Alexander Stindl  
**Datei:** `index.html` (Single-File PWA, ~372 KB, ~6.660 Zeilen)

---

## ÜBERGABE-PAKET (IMMER BEREITSTELLEN)

### Pflichtregeln für jede neue Version:
1. **ZIP-Datei** `igelpflegestation-vX.X.XX.zip` bereitstellen — enthält ALLE Dateien
2. **Changelog** in `Changelog`-Komponente in index.html aktualisieren
3. **Versionsnummer erhöhen** — HTML-Kommentar oben UND Changelog-Header (`"Version X.X.XX"`)
4. **Tabelle ausgeben** welche Dateien im GitHub-Repo ausgetauscht werden müssen
5. **Keine Einzeldateien** mehr separat bereitstellen — nur noch das ZIP

### ZIP-Inhalt (immer aktuelle Dateien, kein Ballast):
| Datei | Zweck |
|---|---|
| `index.html` | Deployment → GitHub Pages Root |
| `igelpflegestation-vX.X.XX-altDB.html` | Versionierte lokale Sicherung |
| `PROJEKTDOKU-vX.X.XX-altDB-UEBERGABE.md` | Diese Dokumentation |
| `manifest.json` | PWA-Manifest mit Icon-Referenzen |
| `service-worker.js` | Offline-Cache (Cache-Name = Versionsnummer) |
| `icon-192.png` | App-Icon Android/PWA |
| `icon-512.png` | App-Icon hochauflösend |
| `deploy.sh` | Git-Deploy-Script |
| `update.sh` | Haupt-Update-Script (pull → kopieren → deploy) |
| `TERMUX-SETUP-ANLEITUNG.md` | Einrichtungsanleitung Termux |

**Wichtig:** ZIP enthält immer NUR den aktuellen Stand — keine alten Versionen ansammeln.

### Pflicht-Antwortformat nach jeder Änderung:
Nach dem ZIP immer eine Tabelle zeigen:

| Datei | Aktion |
|---|---|
| `index.html` | ✅ NEU hochladen |
| `manifest.json` | — unverändert |
| `service-worker.js` | — unverändert |
| `icon-192.png` | — unverändert |
| `icon-512.png` | — unverändert |

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
**NIEMALS:** `bg-blue-*`, `bg-green-*`, Gradient-Klassen — **außer** Status-Badges und blauer Navbar.

### Tailwind-Klassen-Vokabular

**Primär-Button (schwarz):**
`bg-gray-900 text-white rounded-xl py-3 text-sm font-medium hover:bg-gray-700 transition-all`

**Sekundär-Button (Rahmen):**
`border border-gray-200 text-gray-600 rounded-xl py-3 text-sm font-medium hover:bg-gray-50 transition-all`

**Assistent-Button (Igelkarte, prominent schwarz):**
`flex items-center gap-1.5 bg-gray-900 text-white text-xs rounded-xl px-3 py-1.5 font-medium hover:bg-gray-700 active:scale-95 transition-all shadow-sm`

**Eingabefelder:**
`border border-gray-200 rounded-xl px-4 py-3 text-sm focus:outline-none focus:border-gray-400`
(Fokus mit Ring: `focus:border-gray-900 focus:ring-1 focus:ring-gray-900`)

**Labels für Formularfelder:**
`block text-xs font-semibold text-gray-600 mb-1`

**Modals:**
`fixed inset-0 bg-black bg-opacity-50 z-50 flex items-center justify-center p-4`
Innen: `bg-white rounded-2xl w-full max-w-sm shadow-xl flex flex-col` + `style={{maxHeight:'92vh'}}`

**Neu-Anlage Modal (über bestehendem Modal, z-60):**
`bg-white rounded-2xl w-full max-w-sm shadow-2xl border-2 border-gray-900 flex flex-col`

**Inline-Edit (unter dem Eintrag, blauer Akzent):**
`bg-blue-50 border-l-2 border-blue-400` (Eintrag selbst: `bg-blue-50 border-l-2 border-blue-400`)

**Badges:**
- Schwer/Aktiv: `bg-gray-900 text-white text-[10px] px-1.5 py-0.5 rounded-full font-medium`
- Mittel: `bg-gray-100 text-gray-600`
- Leicht: `bg-gray-50 text-gray-400`

**z-Index Hierarchie:**
- `z-40` — Sticky Header
- `z-50` — Standard-Modals
- `z-60` — TreatmentWizard, Neu-Anlage-Modals (über z-50)

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

### Neue Komponenten einfügen
**IMMER vor `MedikationDatenbank` einfügen** (damit vor `HedgehogDetail` definiert).
Position prüfen: `babel_script_start < neue_komponente_position < babel_script_end`

### Komponenten-Reihenfolge (v1.8.45, Zeilennummern ca.)
```
1-166:    Firebase Init, CSS, loadSettings
167-330:  App (Auth-Wrapper)
331-433:  LoadingScreen, LoginScreen
434-999:  PasswordSetup, PasswordReset, AdminSetup, InviteRegistration
1000-1153: DashboardDonut
1154-1202: SEED_MEDICATIONS (20), SEED_DIAGNOSES (20)
1203-1530: MedikamentDB (mit linkedDiagnoses, Neu-Modal, Inline-Edit)
1530-1850: DiagnoseDB (mit Gruppen-Picker, Neu-Modal, Inline-Edit)
1850-2200: TreatmentWizard (Top-Gruppen, Med-Suche, Verknüpfungen)
2200-2800: MedikationDatenbank (LEGACY — nicht entfernen!)
2800-3000: TodoList
3000-3900: MainApp
3900-4100: CSVImportDialog
4100-4400: Changelog (aktuell bis v1.8.45)
4400-4650: UserProfile, QRScannerModal, SettingsDialog
4650-5100: UserManagement, AddHedgehogForm
5100-6500: HedgehogDetail + MedCard + Medikation-Modal
6500-6663: DesignSpec, ReactDOM.render, ServiceWorker
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

#### `medicationDatabase/{id}` (NEU, AltDB)
```javascript
{
  name, activeSubstance, brand, category,
  applicationRoutes: ['oral','subkutan'],
  defaultDosage: '0.4',       // Nur Zahl
  dosageUnit: 'mg/kg',        // mg/kg | ml/kg | mg | ml | ""
  defaultFrequency: 'einmalig',
  defaultDuration: 1,
  frequencyOptions: ['einmalig','nach 14 Tagen'],
  linkedDiagnoses: ['diagnosisDb-doc-id', ...],  // NEU v1.8.45
}
```

#### `diagnosisDatabase/{id}` (NEU, AltDB)
```javascript
{
  name, group, severity: 'leicht'|'mittel'|'schwer',
  recommendedMedications: ['medicationDb-doc-id', ...],
}
```

#### `medikationen/{id}` (Optional, permission-geschützt)
Separate Tracking-Collection. `saveTreatment` schreibt hier **optional** (try-catch, schlägt ohne Rules still fehl). Pflicht-Schreiben läuft nur über `hedgehogs.medikationen[]`.

#### `invites/{id}`, `auditLog/{id}`, `app_todos/main`
Wie zuvor. `app_todos/main.todos[]` Array mit `{ id, text, priority, done, createdAt, createdBy }`.

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

**HINWEIS:** `medikationen` Collection ist optional. `saveTreatment` schreibt primär in `hedgehogs.medikationen[]`. Falls `medikationen`-Rules fehlen, wird der Fehler still ignoriert.

---

## 7. NAVIGATION & BACK-BUTTON (v1.8.45)

### Implementierung
```javascript
// In MainApp useEffect:
window.addEventListener('hashchange', handleHashChange);
const handlePopState = () => {
  if (selected) { setSelected(null); return; }  // Detail -> Liste
  // Sonst Browser-Standard
};
window.addEventListener('popstate', handlePopState);

// Beim Öffnen eines Igels:
setSelected(h);
window.history.pushState({ view: 'detail', id: h.id }, '', `#igel-${h.id}`);

// Beim Zurück:
setSelected(null);
window.history.pushState({ view: 'list' }, '', window.location.pathname);
```

**Verhalten:** Hardware-Back auf Android und Browser-Zurück navigiert immer zuerst Schritt zurück (Detail→Liste), schließt dann erst die App/den Tab.

---

## 8. HAUPTKOMPONENTEN — NEUE FEATURES v1.8.45

### `MedikamentDB` — Neu
- **Neu-Anlage:** Separates zentriertes Modal mit schwarzem Rahmen (`border-2 border-gray-900`, z-60)
- **Bearbeiten:** Inline direkt unter dem Eintrag, blauer Akzent (`bg-blue-50 border-l-2 border-blue-400`)
- **Edit-Icon** beim bearbeiteten Eintrag wird blau gefärbt
- **Alle Felder mit Labels:** Wirkstoff, Präparat/Marke, Kategorie, Dosis (Zahl), Einheit, Applikationswege, Standard-Häufigkeit, Häufigkeitsoptionen
- **Diagnose-Verknüpfung:** Checkboxen mit allen Diagnosen aus `diagnosisDatabase`
  - Speichert als `linkedDiagnoses: [diagId, ...]` im Medikament
  - TreatmentWizard liest beide Richtungen: `m.linkedDiagnoses.includes(diagId)` ODER `wizardDiag.recommendedMedications.includes(medId)`

### `DiagnoseDB` — Neu
- **Neu-Anlage:** Zentriertes Modal, schwarzer Rahmen
- **Bearbeiten:** Inline unter Eintrag, blauer Akzent
- **Gruppen-Picker:** Button "Gruppe wählen" → Dropdown mit existierenden Gruppen + "Neue Gruppe erstellen" Input
- **Schweregrad:** 3-Button-Toggle statt Select
- **Alle Felder mit Labels**

### `TreatmentWizard` — Aktualisiert
- **Schritt 1:** Diagnosegruppen sortiert nach Häufigkeit (meiste Diagnosen = wahrscheinlichste). TOP-Badge auf erster Gruppe
- **Schritt 3:** Suchfeld für Medikamente; empfohlene Medikamente oben (fett umrahmt)
  - Verknüpfung via `m.linkedDiagnoses.includes(diagId)` ODER `diagDB.recommendedMedications.includes(medId)`
- **Suche:** Sucht in Name und Kategorie, filtert alle Medikamente wenn aktiv
- **Schritt 4:** Feldbezeichnungen groß und deutlich

### `HedgehogDetail` — Aktualisiert
- **Assistent-Button:** Schwarz, weißer Text, Stacked-Layer-Icon, `shadow-sm`
- **saveTreatment:** `medikationen.add()` ist optional (try-catch), Hauptspeicherung via `hedgehogs.update()`

---

## 9. BEKANNTE PROBLEME & LÖSUNGEN

| Problem | Ursache | Lösung |
|---|---|---|
| Whitescreen / "Script error. 0:0" auf Mobile | CDN `unpkg.com` | Nur `cdnjs.cloudflare.com` |
| Babel Syntaxfehler | Emoji in JSX-Expression | Niemals in `{}` oder `className={}` |
| Komponente als Text sichtbar | Außerhalb `<script>` Tag | Position prüfen: `babel_start < pos < babel_end` |
| PERMISSION_DENIED Whitescreen | Firestore Rules geändert | try-catch in `onAuthStateChanged` (seit v1.8.43) |
| "Missing or insufficient permissions" beim Wizard | `medikationen`-Collection fehlt in Rules | try-catch in `saveTreatment` (seit v1.8.45) |
| Hardware-Zurück beendet App | Kein popstate-Listener | `addEventListener('popstate', ...)` (seit v1.8.45) |

---

## 10. OFFENE FEATURES (Priorisiert)

### Priorität Hoch
1. **`recommendedMedications` befüllen:** In DiagnoseDB beim Bearbeiten: Checkboxen für Medikamente → speichert IDs in `recommendedMedications[]`. Aktuell nur `linkedDiagnoses` auf Medikament-Seite.

2. **Behandlungsfortschritt:** "Gabe durchgeführt" Button → `completedApplications++`. Anzeige: `2/5 Gaben`. Auto-Abschluss wenn `completed >= planned`.

3. **Diagnosen-Dropdown in Igelkarte:** Freie Diagnose-Texteingabe durch `diagnosisDatabase`-Dropdown ersetzen.

### Priorität Mittel
4. **Legacy-System ablösen:** `MedikationDatenbank` + `med_*` Collections entfernen, wenn alle Stationen auf AltDB umgestellt sind.

5. **Gewicht-Chart:** SVG Liniendiagramm im Gewichts-Abschnitt.

6. **Druckansicht:** Alle Daten eines Igels als druckbares Formular.

### Priorität Niedrig
7. **Offline-Modus:** Service Worker für read-only ohne Internet.

8. **Backup/Restore:** Admin-Export als JSON.

---

## 11. DEPLOYMENT

### GitHub Pages
```
Repo: github.com/dstindl/IGELSTATION_nei | Branch: main | Datei: index.html (Wurzel)
```

### Ersteinrichtung nach Deploy
```
1. Als Admin einloggen
2. Datenbank → Medikamente → "20 Standardmedikamente laden"  
3. Datenbank → Diagnosen → "20 Standarddiagnosen laden"
4. Optional: Diagnosen bearbeiten → Gruppen zuweisen
5. Optional: Medikamente bearbeiten → Diagnosen verknüpfen
```

---

## 12. CODE-KONVENTIONEN

```javascript
// Firestore - Live-Listener:
const unsub = db.collection('col').onSnapshot(
  snap => setState(snap.docs.map(d=>({id:d.id,...d.data()}))),
  err => console.error('Permission:', err.code)  // Silent fail
);
return () => unsub();

// Firestore - Schreiben mit Fehlerbehandlung:
try {
  await db.collection('hedgehogs').doc(id).update({ ...changes,
    zuletztBearbeitetVon: userData.name,
    zuletztBearbeitetAm: firebase.firestore.FieldValue.serverTimestamp()
  });
} catch(e) { alert('Fehler: ' + e.message); }

// Optionale Collection (kann fehlen in Rules):
try { await db.collection('optionalCol').add(data); } catch(e) { /* silent */ }

// State Updates mit Arrays:
const updated = { ...data, arr: [...(data.arr||[]), newItem] };
setState(updated);
await db.collection('col').doc(id).update({ arr: updated.arr });
```

---

## 13. VERSIONSHISTORIE

| Version | Datum | Feature |
|---|---|---|
| **v1.8.46-altDB** | März 2026 | Comic-Süß-Icon: Login-Screen (SVG 80px), manifest.json App-Icon, apple-touch-icon + Favicon als Data URI |
| v1.8.45-altDB | Feb 2026 | Vollbild-Redesign: Bottom-Nav, alle Seiten fullscreen, kein blauer Header, Hardware-Back, Double-Back-to-Exit |
| v1.8.45-altDB | Feb 2026 | Back-Button fix, Permissions fix, Assistent-Button, Wizard-Verbesserungen, Inline-Edit, Gruppen-Picker, Diagnose-Medikament-Verknüpfung |
| v1.8.44-altDB | Feb 2026 | MedikamentDB + DiagnoseDB + TreatmentWizard vollständig, 20 Seed-Daten |
| v1.8.43-altDB | Feb 2026 | CDN-Fix (cdnjs), Auth try-catch Whitescreen |
| v1.8.42 | Jan 2026 | To-Do Admin-Liste (editierbar, Firestore) |
| v1.8.41 | Jan 2026 | To-Do Liste in Sidebar |
| v1.8.40 | Jan 2026 | Medikation komplett überarbeitet |
| v1.8.29 | Dez 2025 | QR-Code, Scanner, Rollen, Donut-Charts |
| v1.8.20 | Nov 2025 | Adress-Autocomplete (Nominatim), Ländervorwahl |

---

## 14. SCHNELL-START FÜR NEUEN CHAT

Kopiere folgendes in den neuen Chat und lade `index.html` + diese Dokumentation hoch:

> "Ich entwickle **Igelpflegestation Pro** — eine Single-File React PWA (`index.html`, ~372KB, **v1.8.46-altDB**).  
> Stack: React 18 + Babel Standalone auf cdnjs, Firebase 10.7.1, Tailwind CSS CDN, GitHub Pages.  
> Design: **schwarz/weiß minimalistisch**, KEINE Farben außer Status-Badges und blauer Navbar.  
> Neue Komponenten gehören **vor `MedikationDatenbank`** in den `<script type='text/babel'>` Tag.  
> Bitte lies zuerst die Projektdokumentation `PROJEKTDOKU-v1.8.46-altDB-UEBERGABE.md`."

**Regel für Übergabepakete:** ZIP `igelpflegestation-vX.X.XX.zip` mit allen 7 Dateien bereitstellen.
Tabelle ausgeben welche Dateien auf GitHub ausgetauscht werden müssen.
Einzeldateien werden NICHT mehr separat bereitgestellt.
