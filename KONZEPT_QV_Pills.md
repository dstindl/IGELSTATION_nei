# Technisches Konzept: QV-Style Pills + Timeline-Dropdown
## Pflegeplan & Igelkarte — v2.3.73+

---

## 1. Überblick

Quittierung und Tagesfortschritt werden in beiden Views (Pflegeplan + Igelkarte) auf dasselbe visuelle System umgestellt, das bereits im QR-QuickView funktioniert.

**Vor dem Umbau:** Timeline immer sichtbar (48px pro Med), Quittierung über Klick auf Timeline-Kreise.

**Nach dem Umbau:** Pills direkt sichtbar, Timeline ins Dropdown, erledigte Meds kompakt.

---

## 2. Layout-Schichten pro Medikament-Zeile

```
┌─────────────────────────────────────────────────────┐
│ Med-Zeile AKTIV (background: #fff)                  │
│  [Medikamentname]              [Status-Badge:fällig] │
│  [dose · route · freq]                               │
│  [◎ 10:00] [✓ 18:00]  ← QV-Pills                   │
│  [══════════░░░░░░░░░] ← Fortschrittsbalken          │
│  Zuletzt: 15.03 10:02 · Denis                       │
├─────────────────────────────────────────────────────┤
│ [⏱ Timeline]              [▾]  ← Dropdown #fffdfb  │
│   (ausgeklappt: 44px TL-Frame + Zeitachse)          │
├─────────────────────────────────────────────────────┤
│─────────────────── [dünne Linie #e0ddd9] ───────────│ ← Trenner
├─────────────────────────────────────────────────────┤
│ Med-Zeile ERLEDIGT (background: #f7f6f5, opacity .75)│
│  [~~Fenbendazol~~]          [✓ 14:02]               │
├─────────────────────────────────────────────────────┤
│ [⏱ Timeline Fenbendazol]  [▾]  ← done-toggle grau  │
├─────────────────────────────────────────────────────┤
│ [📅 Verlauf anzeigen]      [▾]  ← #f2efec stone     │
└─────────────────────────────────────────────────────┘
```

---

## 3. Farbschichten (4 distinkte Ebenen)

| Bereich | Farbe | Hex |
|---------|-------|-----|
| Med-Zeile aktiv | Weiß | `#fff` |
| Med-Zeile erledigt | Warm gedimmt | `#f7f6f5` |
| Timeline-Dropdown | Warm offweiß | `#fffdfb` |
| Verlauf-Dropdown | Stone-50 | `#f2efec` |

Trennlinie aktiv/erledigt: `#e0ddd9` (1px)

---

## 4. QV-Pill System (identisch mit QR-QuickView)

### 6 Slot-Zustände und ihre visuelle Darstellung

| State | Hintergrund | Rand | Icon | Farbe | Animation | Klickbar |
|-------|-------------|------|------|-------|-----------|----------|
| `done-open` | `#dcfce7` | `#86efac` | ✓ | `#166634` | – | ✅ Rückgängig |
| `done-locked` | `#dcfce7` | `#86efac` | ✓ | `#166634` | – | ❌ |
| `due` | `#fefce8` | `#fde68a` | ◎ | `#ca8a04` | amber pulse | ✅ Quittieren |
| `overdue-locked` | `#fff1f2` | `#fecdd3` | ● | `#e11d48` | red pulse | ❌ + 🔒 |
| `pending` | `#fafaf8` | `#e7e5e4` | ○ | `#d6d3d1` | – | ❌ opacity .5 |

### Pill-Anatomie
```
┌───────────────────────┐
│ [icon] [HH:MM]        │  padding: 6px 10px 6px 8px
│        ↑ DM Mono 10px │  border-radius: 999px
└───────────────────────┘  border: 2px solid [QV_BD[st]]
         ↗ Schloss-Badge bei locked:
           position:absolute, top:-4px, right:-4px
           14×14px, border-radius:50%, bg:#1c1917
```

### Konstanten (Komponenten-Scope, NICHT in .map())
```javascript
const QV_BG  = {'done-open':'#dcfce7','done-locked':'#dcfce7','due':'#fefce8','overdue-locked':'#fff1f2','pending':'#fafaf8'};
const QV_BD  = {'done-open':'#86efac','done-locked':'#86efac','due':'#fde68a','overdue-locked':'#fecdd3','pending':'#e7e5e4'};
const QV_COL = {'done-open':'#166634','done-locked':'#166634','due':'#ca8a04','overdue-locked':'#e11d48','pending':'#d6d3d1'};
const QV_ICN = {'done-open':'✓','done-locked':'✓','due':'◎','overdue-locked':'●','pending':'○'};
const QV_ANM = {'due':'qv-pulse-amber 2.2s ease-in-out infinite','overdue-locked':'qv-pulse-red 1.8s ease-in-out infinite'};
```
**KRITISCH:** Diese dürfen NICHT in `.map()` Callbacks definiert werden → Babel-Fehler.

---

## 5. State-Management

### Pflegeplan: tlOpenMap
```javascript
// In Pflegeplan-Komponente (Scope-Level):
const [tlOpenMap, setTlOpenMap] = React.useState({});

// In group.tasks.map():
const tlOpenKey = t.igelId+'-'+t.treatmentIdx+'-'+t.medIdx;
const tlOpen = !!tlOpenMap[tlOpenKey];
const setTlOpen = (v) => setTlOpenMap(prev => ({
  ...prev, [tlOpenKey]: typeof v === 'function' ? v(prev[tlOpenKey]) : v
}));
```

### HedgehogDetail TRow: tlOpenMiMap
```javascript
// In TRow-Komponente (Scope-Level, bereits korrekt per verlaufOpenMap-Muster):
const [tlOpenMiMap, setTlOpenMiMap] = useState({});

// In t.medications.map():
const tlOpenMi = !!tlOpenMiMap[mi];
const setTlOpenMi = (v) => setTlOpenMiMap(prev => ({
  ...prev, [mi]: typeof v === 'function' ? v(prev[mi]) : v
}));
```

**KRITISCH:** `useState()` NIEMALS in `.map()` Callbacks! Rules of Hooks.

---

## 6. Erledigt-Logik (zwei Bedeutungen)

### Heute erledigt (allDoneToday)
Alle Slots des heutigen Tages haben Status `done-open` oder `done-locked`.
Zeige: kompakte Zeile + `✓ HH:MM` Bubble (Uhrzeit der letzten heutigen Gabe).

### Behandlung abgeschlossen (isDone)
`m.done === true` ODER `completedApplications >= plannedApplications`.
Zeige: kompakte Zeile + `abgeschl.` Badge (grau).

### Dünne Trennlinie
Wird eingefügt wenn der vorherige Med aktiv war und der aktuelle erledigt ist:
```jsx
{mi > 0 && showDone && !prevAllDone && (
  <div style={{height:1, background:'#e0ddd9'}}/>
)}
```

---

## 7. Quittier-Logik (unverändert, nur UI-Änderung)

### Pflegeplan
```javascript
// Quittieren:
recordFromPlan(task, circleKey)  // → Firestore update + tapped optimistic

// Rückgängig:
undoFromPlan(task, circleKey)   // → Firestore update

// circleKey = igelId-treatmentIdx-medIdx-slotIndex
```

### HedgehogDetail
```javascript
// Quittieren:
recordApplication(idx, mi)  // → Firestore update

// Rückgängig (done-open):
// Inline async: removes last today-app from m.applications[]
// m.completedApplications--
// setData({...data, treatments: treatments2})
```

---

## 8. Bekannte Babel-Fallstricke (dokumentiert)

| Problem | Symptom | Fix |
|---------|---------|-----|
| `useState` in `.map()` | Spinner | State als Map in Komponenten-Scope |
| Objekt-Konstanten in `.map()` | Spinner | Konstanten in Komponenten-Scope |
| `fontSize: 8.5` (Dezimal) | Spinner | Integer verwenden: `9` |
| `padStart(2,'0')` in Template-Literal | Spinner | String-Verkettung statt Template |
| `data:image/base64` in JSX | Spinner | Extern oder CSS |
| Doppelte `const` im gleichen Scope | Spinner | Umbenennen |
| `history.back()` in Menü-onClose | popstate-Loop | `replaceState` + `igelMenuOpen(false)` |
| `serverTimestamp()` in Arrays | Fehler | `new Date().toISOString()` |

---

## 9. Dropdown-Toggle Muster (für Timeline)

```jsx
<div onClick={() => setTlOpen(v => !v)}
  style={{
    display:'flex', alignItems:'center', justifyContent:'center', gap:5,
    padding:'6px 12px', borderTop:'1px solid #ede9e6',
    fontSize:10, fontWeight:700, color: showDone ? '#a8a29e' : '#78716c',
    cursor:'pointer', background:'#fffdfb', userSelect:'none'
  }}>
  <svg ...>clock icon</svg>
  Timeline
  <svg style={{transition:'transform .25s', transform: tlOpen ? 'rotate(180deg)' : 'none'}}>
    chevron
  </svg>
</div>
{tlOpen && (
  <div style={{padding:'10px 12px', background:'#fffdfb', borderTop:'1px solid #ede9e6'}}>
    {/* 44px Timeline Frame + Zeitachsen-Labels */}
  </div>
)}
```

---

## 10. Versionshistorie dieses Features

| Version | Was |
|---------|-----|
| 2.3.73 | Eingebaut (Spinner wegen useState in .map) |
| 2.3.74 | Fix: useState in .map → Maps in Scope |
| 2.3.75 | Fix: QV_ Objekt-Konstanten in .map → Scope |
| 2.3.76 | Fix: fontSize:8.5 (Decimal → Integer) |

---

*Erstellt: März 2026 · Denis-Alexander Stindl*
