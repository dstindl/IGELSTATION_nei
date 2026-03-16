# Konzept-Übergabe: Igelbestand + Dashboard
**Für:** Nächste Chat-Session  
**Stand:** v2.3.84 — März 2026  
**Projekt:** Igelpflegestation Pro

---

## 1. Kontext & Ausgangslage

### App-Stack
- React 18 + Babel Standalone 7.23.5 (Single-File PWA, `index.html`)
- Firebase 10.7.1 (Auth + Firestore), Projekt: `igelstation-3c3db`
- Tailwind CDN + DM Sans Font
- Deployment: `dstindl.github.io/IGELSTATION_nei`

### Aktueller Stand Navigation
Die BottomBar hat 5 Buttons: **Dashboard · Bestand · Aufnehmen · QR · Pflegeplan**

Der **Bestand-Button** (`bnav-bestand`) ist bereits eingebaut und löst `__igelAction('bestand')` aus.  
In React existiert bereits `showBestand` State + ein Placeholder-Block der gerendert wird wenn `showBestand === true`.

**Was fehlt:** Die echte `IgelBestand`-Komponente + Dashboard-Vereinfachung.

---

## 2. Feature: Igelbestand-Seite

### Ziel
Eigene Vollseite mit Igelkarten-Liste + Filter — analog zum Pflegeplan-Filter-System.

### Navigation & State
```
BottomBar "Bestand" → showBestand = true → IgelBestand-Komponente
IgelBestand → Igelkarte öffnen → setDetailOrigin('bestand'), setSelected(h)
Igelkarte Zurück-Button → zeigt "← Bestand" → zurück zu showBestand
```

Der `detailOrigin`-State ist bereits implementiert. Wert `'bestand'` funktioniert bereits für den Zurück-Button in der Igelkarte.

### Komponenten-Aufruf (bereits im App-Render-Block als Placeholder)
```jsx
if (showBestand) {
  return <IgelBestand
    hedgehogs={hedgehogs}
    userData={userData}
    onClose={() => { setShowBestand(false); bnavSetActive('bnav-home'); history.replaceState({igelApp:true,level:1},''); }}
    onSelectHedgehog={(h) => {
      setShowBestand(false);
      setSelected(h);
      setDetailOrigin('bestand');
      bnavSetActive('bnav-home');
      window.history.pushState({view:'detail',id:h.id},'',`#igel-${h.id}`);
    }}
  />;
}
```

### IgelBestand-Komponente — Aufbau

**Header (sticky)**
```
← Zurück     Igelbestand     ☰ (Hamburger)
```

**Filter-Block (aufklappbar, analog Pflegeplan)**
- Zugeklappt: zeigt aktive Filter als Mini-Chips + Reset-Button + Chevron
- Aufgeklappt: Filter-Panel mit:
  - **Status-Chips**: Aufnahme · In Pflege · Überwinterung · Auswilderungsbereit · Entlassen
  - **Betreuer-Chips**: je aktiver Nutzer mit Zähler (x)
  - **Gewichtsklasse**: unter 300g · 300–500g · über 500g

**Stats-Strip** (wenn Filter aktiv): "Gefiltert · N Igel"

**Igelkarte pro Igel:**
```
┌─────────────────────────────────┐
│ [Farbbanner]  Name              │
│               IGL-XXXXXXX  Status-Badge │
├─────────────────────────────────┤
│ 766 g  +132g-Trend   Denis · 15.03 │
│ [Diagnose-Chip] [Diagnose-Chip] │
└─────────────────────────────────┘
```

### Design-Tokens (identisch mit Rest der App)
```
Hintergrund:   #fafaf8
Karten:        #fff, border: 1px solid #e7e5e4, shadow: 0 2px 8px rgba(28,25,23,.07)
Titel/Text:    #1c1917 (Stone 900)
Gedimmt:       #a8a29e
Trennlinien:   #e7e5e4
Font:          DM Sans 800 (Titel), DM Mono (IDs, Gewicht)
```

### Status-Farben (aus `statusColor` in App)
```js
aufnahme:           bg:#f5f5f4  color:#57534e  border:#d6d3d1
pflege:             bg:#fef3c7  color:#92400e  (amber)
ueberwinterung:     bg:#e0f2fe  color:#0369a1  (blau)
auswilderung_bereit:bg:#dcfce7  color:#166534  (grün)
ausgewildert:       bg:#f3f4f6  color:#6b7280  (grau)
verstorben:         bg:#f3f4f6  color:#6b7280  (grau)
```

### Igel-Banner-Farben (aus `IGEL_COLORS`)
```js
const IGEL_COLORS = ['#5c5248','#6b4f38','#4a6352','#5c4a6b','#7a5c34','#4a5568','#5a4a3a','#3d5a4a'];
// Zuweisung: IGEL_COLORS[index % IGEL_COLORS.length]
```

### Filter-State (analog Pflegeplan)
```js
const [filterOpen, setFilterOpen] = useState(false);
const [filterStatus, setFilterStatus] = useState(new Set());  // 'aufnahme','pflege' etc
const [filterBetreuer, setFilterBetreuer] = useState('');
const [filterGewicht, setFilterGewicht] = useState('');  // 'unter300','300bis500','ueber500'
const [searchText, setSearchText] = useState('');
```

### Filter-Logik
```js
const filteredHedgehogs = hedgehogs.filter(h => {
  // Nur aktive (nicht ausgewildert/verstorben) — oder alle wenn Filter gesetzt
  const isActive = !['ausgewildert','verstorben'].includes(h.status);
  if (filterStatus.size === 0 && !filterBetreuer && !filterGewicht && !searchText) {
    return isActive; // Default: nur aktive zeigen
  }
  if (filterStatus.size > 0 && !filterStatus.has(h.status)) return false;
  if (filterBetreuer && h.betreuer !== filterBetreuer) return false;
  if (filterGewicht) {
    const g = parseFloat(h.gewichtAktuell) || 0;
    if (filterGewicht === 'unter300' && g >= 300) return false;
    if (filterGewicht === '300bis500' && (g < 300 || g > 500)) return false;
    if (filterGewicht === 'ueber500' && g <= 500) return false;
  }
  if (searchText) {
    const s = searchText.toLowerCase();
    if (!(h.name||'').toLowerCase().includes(s) &&
        !(h.igelId||'').toLowerCase().includes(s) &&
        !(h.fundort||'').toLowerCase().includes(s)) return false;
  }
  return true;
});
```

### Wo einfügen
Neue Komponente `IgelBestand` **vor `UserProfile`** (Konvention: neue Komponenten immer dort).  
Den Placeholder-Block im App-Render ersetzen durch den echten Aufruf (siehe oben).

---

## 3. Feature: Dashboard vereinfachen

### Ziel
Dashboard-Seite: nur noch **Donut-Chart + Heute-Kacheln + Schnellzugriff**.  
Der **Igelbestand-Abschnitt** (Igelkarten, Filter, Suche) wird aus dem Dashboard entfernt — er lebt jetzt auf der eigenen Bestandsseite.

### Was bleibt
1. **Stats-Strip** (4 Kacheln): Gesamt / In Pflege / Überwinterung / Auswilderungsbereit
2. **Donut-Chart** (`DashboardDonut`-Komponente bleibt unverändert)
3. **Heute-Kacheln** (3er-Grid): Fällig · Überfällig · Erledigt
4. **Schnellzugriff-Row**: 2 Buttons → Pflegeplan / Bestand

### Was fällt weg
- `bestandOpen` State + Bestand-Section im Dashboard
- `statusFilterPills` Filter-Pills über dem Bestand
- `betreuerFilter` State
- Such-Input (`searchText` im Dashboard)
- Alle Igelkarten im Dashboard
- `filteredHedgehogs`-Logik im Dashboard (bleibt nur für Bestandsseite)

### Heute-Kacheln Datenquelle
```js
// Behandlungen aller aktiven Igel für heute
const today = new Date().toISOString().split('T')[0];
const allTodayTasks = hedgehogs.flatMap(h =>
  (h.treatments||[]).filter(t => t.status==='aktiv').flatMap(t =>
    (t.applicationSchedule||[]).filter(s => s.date === today)
      .map(s => ({ ...s, hedgehogId: h.id, treatmentId: t.id }))
  )
);
const dueCnt     = allTodayTasks.filter(t => !t.completed && !t.overdue).length;
const overdueCnt = allTodayTasks.filter(t => t.overdue).length;
const doneCnt    = allTodayTasks.filter(t => t.completed).length;
```

### Schnellzugriff-Row
```jsx
<div style={{margin:'0 12px',background:'#fff',borderRadius:14,border:'1px solid #e7e5e4',overflow:'hidden'}}>
  <div style={{display:'flex'}}>
    <div style={{flex:1,padding:'11px 12px',borderRight:'1px solid #e7e5e4',cursor:'pointer'}}
         onClick={() => window.__igelAction('pflegeplan')}>
      {/* Pflegeplan-Icon + Titel + "N ausstehend" */}
    </div>
    <div style={{flex:1,padding:'11px 12px',cursor:'pointer'}}
         onClick={() => window.__igelAction('bestand')}>
      {/* Bestand-Icon + Titel + "N aktiv" */}
    </div>
  </div>
</div>
```

### States die danach nicht mehr gebraucht werden
```js
// Können entfernt werden:
const [bestandOpen, setBestandOpen] = useState(true);     // → weg
const [statusFilterPills, setStatusFilterPills] = useState([]); // → weg (oder nur für Donut-Click behalten)
const [betreuerFilter, setBetreuerFilter] = useState([]); // → weg
```

---

## 4. Kritische Regeln (immer beachten)

```
✅ Balance-Check nach jeder Änderung: Braces=0, Parens=0
✅ padStart(2,'0') NIEMALS in Template-Literals/JSX
✅ serverTimestamp() nicht in Arrays → new Date().toISOString()
✅ Neue Komponenten immer VOR UserProfile einfügen
✅ useState NIEMALS in .map() Callbacks
✅ Objekt-Konstanten NIEMALS in .map() definieren
✅ SVG-Attribute in JSX: camelCase (strokeWidth, strokeLinecap etc.)
✅ Keine Emojis in JSX (nur in Strings/Attributen)
```

### Version-Update-Checklist (immer alle 5 Stellen!)
1. Changelog-Array im Code
2. LoadingScreen `v2.x.xx`
3. `msheet-version` im HTML-Menü (`Version 2.x.xx`)
4. Changelog-Header-Text (`Version X.X.XX · Cloud-basierte…`)
5. `service-worker.js` Cache-Name

### ZIP-Befehl
```bash
cd /home/claude/igelstation
rm -f /home/claude/Igelstation.zip
zip /home/claude/Igelstation.zip index.html igelpflegestation-vX_X_XX-altDB.html \
    service-worker.js icon-192.png icon-512.png deploy.sh update.sh \
    PROJEKTDOKU_all.md IGEL_STARTPROMPT.md
```

---

## 5. Komponenten-Position im Code

```
Suche nach: "const UserProfile"
Neue Komponente IgelBestand DAVOR einfügen

Suche nach: "if (showBestand)" im App-Render
→ Placeholder-Block ersetzen durch echten IgelBestand-Aufruf

Suche nach: "=== DASHBOARD SECTION ===" im App-Render
→ Bestand-Section darunter entfernen, Schnellzugriff-Row + Heute-Kacheln einfügen
```

---

## 6. Reihenfolge der Umsetzung (empfohlen)

1. `IgelBestand`-Komponente bauen (Filter + Karten)
2. Placeholder im App-Render ersetzen
3. Dashboard vereinfachen (Igelkarten raus, Kacheln + Schnellzugriff rein)
4. Version-Bump + Changelog + ZIP

---

## 7. Startpunkt für neuen Chat

Empfohlener Eröffnungssatz:

> "Wir bauen die Igelbestandsseite für Igelpflegestation Pro (v2.3.84). Die Basis-Navigation ist fertig (showBestand State, detailOrigin 'bestand', BottomBar). Lies zuerst KONZEPT_IGELBESTAND_DASHBOARD.md aus dem ZIP, dann baue die IgelBestand-Komponente vor UserProfile ein und ersetze den Placeholder-Block."
