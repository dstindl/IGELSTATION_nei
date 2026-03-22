# Igelpflegestation Pro — Projektdokumentation

**Version:** 2.5.50 | **Stand:** März 2026 | **Entwickler:** Denis-Alexander Stindl

---

## ⚠️ PRE-FLIGHT: VOR JEDER UMSETZUNG — ZWINGEND

> **Diese Checkliste wird von Claude bei JEDER Implementierung stillschweigend abgearbeitet, bevor die erste Zeile Code geschrieben wird. Keine Ausnahmen.**

### Schritt 1 — Betroffenen Code lesen
Vor jeder Änderung die relevante Stelle mit `view` oder `grep -n` lesen.
Nie aus dem Gedächtnis schreiben — der Code im File ist Realität, nicht der letzte Chat-Kontext.

### Schritt 2 — Babel-Constraints prüfen (mental oder per grep)
- [ ] Neue Komponente innerhalb anderer? → muss `renderX()` werden, nie `const X = () =>`
- [ ] SVG-Attribute? → camelCase (`strokeWidth`, nicht `stroke-width`)
- [ ] `padStart` in Template-Literal `${}`? → String-Verkettung statt padStart
- [ ] `dangerouslySetInnerHTML` mit HTML-Tag-Strings? → JSX-Children
- [ ] `useState` in `.map()`? → Top-Level heben
- [ ] HTML-Tags (`<path>`, `<circle>` etc.) in JS-Strings? → echte JSX-SVGs

### Schritt 3 — State-Sicherheit prüfen
Bei jeder Änderung die States betrifft:
- [ ] Neuer State: **addieren**, nie einen bestehenden ersetzen
- [ ] Prüfen ob der alte State-Setter noch irgendwo referenziert wird: `grep -n "setShowXxx"` 
- [ ] Neuer State in `_backState.current` aufnehmen?
- [ ] Neuer State in `__igelCloseAll` + `__igelCloseAllExceptMenu` aufnehmen?
- [ ] Neuer State im popstate-Handler behandelt?

### Schritt 4 — str_replace Sicherheit
- [ ] `grep -c "old_str_anker"` → muss genau `1` ergeben, nie `0` oder `>1`
- [ ] Kontext der Zielstelle gelesen — kein benachbarter Code wird unbeabsichtigt entfernt?

### Schritt 5 — Nach der Änderung (Pflicht, keine Ausnahme)
```bash
python3 -c "
import re
with open('/home/claude/igelstation/index.html','r') as f: c=f.read()
s=re.search(r'<script type=\"text/babel\">(.*?)</script>',c,re.DOTALL).group(1)
print('Braces: %d, Parens: %d' % (s.count('{')-s.count('}'), s.count('(')-s.count(')')))
"
# Beide müssen 0 sein. Bei Abweichung: sofort rückgängig, nie deployen.
```

Bei State-Änderungen zusätzlich:
```bash
python3 -c "
with open('/home/claude/igelstation/index.html','r') as f: c=f.read()
states=['showDesignSpec','showBatchBearbeitung','showDatenbankHub','showMedikamentDB',
        'showDiagnoseDB','showTreatmentDB','showUserMgmt','showSettings','showChangelog',
        'showTodoList','showProfile','showAddForm','showQRScanner','showPflegeplan','showBestand']
[print(('OK  ' if ('const ['+s) in c else 'FEHLT!'), s) for s in states]
"
```

### Schritt 6 — Version + Changelog + ZIP

**Alle 5 Versions-Stellen bumpen (Pflicht):**
```
1. Changelog-Array im JSX     — neuer Eintrag ganz oben
2. LoadingScreen              — vX.X.XX
3. Menü-Footer                — Version X.X.XX (class="msheet-version")
4. Changelog-Header-Text      — Version X.X.XX · Cloud-basierte...
5. service-worker.js          — igelpflegestation-vX.X.XX
```

**Changelog-Eintrag:** Kurze, präzise Beschreibung was geändert wurde. Bei Bug-Fixes: Ursache nennen. Bei Features: was es tut. Bei Whitescreens: was crashte und warum.

**PROJEKTDOKU_all.md aktualisieren:**
- Versionshistorie-Tabelle: neuer Eintrag
- Betroffene Komponenten-Abschnitte (Abschnitt 8): States / Logik / Fallstricke ergänzen
- Neue Bugs/Fixes in Abschnitt 5.1 Tabelle aufnehmen

**Dann ZIP neu bauen:**
```bash
cd /home/claude/igelstation && rm -f /home/claude/Igelstation.zip
zip /home/claude/Igelstation.zip index.html service-worker.js \
  icon-192.png icon-512.png deploy.sh update.sh PROJEKTDOKU_all.md IGEL_STARTPROMPT.md
```
Nie ZIP ohne Versions-Bump und Changelog-Eintrag ausliefern.

### Schritt 7 — Verifikation vor Auslieferung (Post-Implementation Recheck)

Vor dem finalen ZIP-Build die PRE-FLIGHT-Checkliste nochmals aktiv durchgehen — nicht als Erinnerung, sondern als echte Verifikation gegen den tatsächlichen Code:

```bash
# 1. Balance-Check (Pflicht)
python3 -c "
import re
with open('/home/claude/igelstation/index.html','r') as f: c=f.read()
s=re.search(r'<script type=\"text/babel\">(.*?)</script>',c,re.DOTALL).group(1)
b=s.count('{')-s.count('}'); p=s.count('(')-s.count(')')
print('Braces:',b,'Parens:',p, '→','OK' if b==0 and p==0 else 'FEHLER!')
"

# 2. Keine Inline-Komponenten in geändertem Code
grep -n "const [A-Z][a-zA-Z]* = (" /home/claude/igelstation/index.html | grep -v "^[0-9]*:    const [A-Z][a-zA-Z]* = (" | head -5

# 3. Kein aktives dangerouslySetInnerHTML im Babel-Script (Changelog-Texte ausschließen)
python3 -c "
import re
with open('/home/claude/igelstation/index.html','r') as f: c=f.read()
script=re.search(r'<script type=.text/babel.>(.*?)</script>',c,re.DOTALL).group(1)
hits=re.findall(r'dangerouslySetInnerHTML\s*=\s*\{',script)
print('dangerouslySetInnerHTML aktiv:',len(hits),'→','OK' if not hits else 'PRUEFEN: '+str(hits))
"

# 4. State-Vollständigkeit
python3 -c "
with open('/home/claude/igelstation/index.html','r') as f: c=f.read()
states=['showDesignSpec','showBatchBearbeitung','showDatenbankHub','showMedikamentDB',
        'showDiagnoseDB','showTreatmentDB','showUserMgmt','showSettings','showChangelog',
        'showTodoList','showProfile','showAddForm','showQRScanner','showPflegeplan','showBestand']
issues=[s for s in states if ('const ['+s) not in c]
print('States OK' if not issues else 'FEHLT: '+str(issues))
"

# 5. Versions-Konsistenz (nur strukturelle Stellen, nicht Changelog-Text)
python3 -c "
import re
with open('/home/claude/igelstation/index.html','r') as f: c=f.read()
with open('/home/claude/igelstation/service-worker.js','r') as f: sw=f.read()
v1=re.search(r'igelpflegestation-v([\d.]+)',sw)
v2=re.search(r'msheet-version[^v]*v?([\d.]+)',c)
v3=re.search(r'>v([\d.]+)</',c)
vers=set(filter(None,[v1 and v1.group(1),v2 and v2.group(1),v3 and v3.group(1)]))
print('Versionen (SW+Menu+Loading):',vers,'→','OK' if len(vers)==1 else 'INKONSISTENT!')
"
```

**Erst wenn alle 5 Checks grün sind → ZIP bauen → ausliefern.**

Bei einem fehlgeschlagenen Check: Problem beheben, Schritt 7 erneut ausführen. Nie mit bekanntem Issue ausliefern.

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

## 4. Design System — Warm Stone Elevated (ABSOLUTER STANDARD ab v2.4.09)

> **Diese Werte sind der einzige erlaubte Stil für alle neuen und überarbeiteten Komponenten.**
> Abweichungen nur mit expliziter Entscheidung. Bei Unklarheit: bestehende v2.4.09-Komponenten als einzige Referenz.

---

### 4.1 Seiten-Hintergründe

**Alle Scroll-Bereiche / Page-Backgrounds:**
```javascript
background: '#e8e5e1'   // ÜBERALL — Pflegeplan, Igelkarte, Bestand, Datenbank, Einstellungen,
                        // Formulare, Profil, Benutzer, Changelog — keine Ausnahmen
```
Tailwind-Override (für Legacy-Klassen): `.bg-gray-50 { background: #e8e5e1 !important; }`

---

### 4.2 Vollständige Farbpalette

**Hintergründe (von hell nach mittel):**
```
#ffffff   Karten, Header-Bars, Sticky-Leisten, Inputs, Modals, Bottom-Sheets
#fafaf8   Input-Felder, Textarea-Felder, inaktive Toggle-Zustände
          → NICHT als Seiten-Hintergrund verwenden (zu hell, kein Kontrast)
#f5f5f4   Sub-Karten (z.B. Med-Einträge in TreatmentDB), Pill-Chips, Timeline-Panels
#f0eeec   Row-Trennlinien innerhalb weißer Karten (borderBottom), Karten:active
#e8e5e1   SEITEN-HINTERGRUND (einziger erlaubter Wert) ← NEU ab v2.4.09
#dddad6   Filter-Bars, sekundäre sticky Leisten auf e8e5e1-Hintergrund
```

**Rahmen (von dezent nach kräftig):**
```
#f0eeec   Row-Trennlinien INNERHALB weißer Karten (border-bottom zwischen Zeilen)
#e7e5e4   Standard-Trennlinien, Header-Border-Bottom, Segmented-Control-Hintergrund
#c9c5c1   KARTEN-RAHMEN — alle Haupt-Karten auf e8e5e1-Hintergrund ← NEU ab v2.4.09
#1c1917   Fokus-Rahmen (Inputs), aktive Sub-Karten, aktive Toggle-Buttons
```

**Text (von gedimmt nach primär):**
```
#d6d3d1   Platzhalter leere Werte (–), deaktivierte Elemente
#a8a29e   Labels über Feldern, Section-Labels, Zähler, Subtext
#78716c   Sekundärer Text, inaktive Seg-Buttons, Meta-Angaben
#57534e   Tertiärer Text, Diagnose-Chips, Zeitangaben
#44403c   Primärer Body-Text (fließtext)
#1c1917   Primärfarbe: Buttons, Überschriften, aktive States, Primär-Icons
```

---

### 4.3 Karten — PFLICHT-Standard

**Haupt-Karte (auf e8e5e1-Hintergrund):**
```javascript
{
  background: '#fff',
  borderRadius: 14,
  border: '1.5px solid #c9c5c1',       // ← NEU: kräftiger Rahmen
  boxShadow: '0 8px 28px rgba(28,25,23,.18)',  // ← NEU: starker Shadow
  overflow: 'hidden'
}
```
> **Merke:** Rahmen 1.5px (nicht 1px), Farbe #c9c5c1 (nicht #e7e5e4), Shadow 8px/28px (nicht 2px/8px).

**Sub-Karte (innerhalb weißer Karte, z.B. Med-Einträge):**
```javascript
{
  background: '#f5f5f4',
  borderRadius: 12,
  border: '1.5px solid #e7e5e4',       // feiner als Haupt-Karte
  padding: 12
}
// Aktiv/fokussiert: border: '1.5px solid #1c1917'
```

**Kompakte Info-Karte (Meta-Daten, Verlauf):**
```javascript
{
  background: '#f5f5f4',
  borderRadius: 14,
  padding: '11px 14px'
  // kein Shadow, kein border — liegt auf e8e5e1, braucht keine Abhebung
}
```

---

### 4.4 Seiten-Header — PFLICHT-Standard

Jede Vollseite hat einen **sticky Header** mit zentriertem Titel:

```javascript
// Wrapper
{
  position: 'sticky', top: 0,
  background: '#fff',
  display: 'flex', alignItems: 'center', justifyContent: 'space-between',
  padding: '10px 16px',
  borderBottom: '2px solid #e7e5e4',   // immer 2px, nie 1px
  zIndex: 10
}

// Titel (absolut zentriert — NICHT flexbox-center)
{
  position: 'absolute', left: '50%', transform: 'translateX(-50%)',
  fontSize: 15, fontWeight: 800, color: '#1c1917',
  whiteSpace: 'nowrap', fontFamily: "'DM Sans',sans-serif"
}
```

**Header-Buttons:**
```javascript
// Zurück-Button (links)
{ width:36, height:36, borderRadius:'50%', background:'#f5f5f4', border:'none',
  cursor:'pointer', display:'flex', alignItems:'center', justifyContent:'center' }
// Icon: chevron-left, stroke #1c1917, strokeWidth 2.5

// Plus-Button / Neu-Anlage (rechts)
{ width:36, height:36, borderRadius:10, background:'#1c1917', border:'none',
  cursor:'pointer', display:'flex', alignItems:'center', justifyContent:'center' }
// Icon: plus, stroke #fff, strokeWidth 2.5

// Platzhalter wenn kein rechter Button
{ width:36 }  // leeres div für Zentrierung des Titels
```

---

### 4.5 Buttons

**Primär-Button (Speichern, Bestätigen):**
```javascript
{
  background: '#1c1917', color: '#fff',
  borderRadius: 12, padding: 11,        // bei Save-Bar
  fontSize: 13, fontWeight: 800,
  border: 'none', cursor: 'pointer', fontFamily: 'inherit'
}
// Disabled: { background: '#a8a29e' }
// Saving: { background: '#a8a29e' }
```

**Sekundär-Button (Abbrechen, neutral):**
```javascript
{
  background: '#f5f5f4', color: '#78716c',
  borderRadius: 12, padding: 11,
  fontSize: 13, fontWeight: 700,
  border: 'none', cursor: 'pointer', fontFamily: 'inherit'
}
```

**Destruktiv-Button (Löschen):**
```javascript
{
  background: '#e11d48', color: '#fff',
  borderRadius: 12, padding: 11,
  fontSize: 13, fontWeight: 800,
  border: 'none', cursor: 'pointer', fontFamily: 'inherit'
}
```

**Icon-Button (Stift / Löschen in Karten-Fußzeile):**
```javascript
// Stift
{ width:30, height:30, borderRadius:8, border:'1.5px solid #e7e5e4',
  background:'#fff', display:'flex', alignItems:'center', justifyContent:'center' }
// Icon: stroke #78716c, strokeWidth 2.5

// Löschen
{ width:30, height:30, borderRadius:8, border:'1.5px solid #fecdd3',
  background:'#fff1f2', display:'flex', alignItems:'center', justifyContent:'center' }
// Icon: stroke #e11d48, strokeWidth 2.5
```

**Kleiner Text-Link-Button (z.B. "Erste Vorlage erstellen →"):**
```javascript
{ fontSize:12, fontWeight:700, color:'#1c1917', background:'none',
  border:'none', cursor:'pointer', textDecoration:'underline', fontFamily:'inherit' }
```

---

### 4.6 Section-Labels

```javascript
{
  fontSize: 8, fontWeight: 800, color: '#a8a29e',
  textTransform: 'uppercase', letterSpacing: '.1em',
  padding: '2px 0 6px'
}
```
Section-Labels stehen **außerhalb** der Karte, direkt über ihr. Sie strukturieren die Seite in benannte Blöcke.

---

### 4.7 Karten-Zeilen (Rows)

Alle Zeilen innerhalb weißer Karten folgen diesem Pattern:

```javascript
// Standard-Zeile (mit Trennlinie)
{ padding: '10px 14px', borderBottom: '1px solid #f0eeec' }

// Letzte Zeile (ohne Trennlinie)
{ padding: '10px 14px' }

// Edit-Zeile (etwas kleiner padding für Input)
{ padding: '9px 14px', borderBottom: '1px solid #f0eeec' }
```

> **Regel:** Trennlinien innerhalb weißer Karten immer `#f0eeec` (nicht #e7e5e4 — zu dunkel innerhalb weiß).

---

### 4.8 Felder-Labels (über jedem Input)

```javascript
{
  fontSize: 9, fontWeight: 700, color: '#a8a29e',
  textTransform: 'uppercase', letterSpacing: '.05em',
  marginBottom: 3
}
// Pflichtfeld-Marker: <span style={{color:'#e11d48'}}>*</span>
```

---

### 4.9 Inputs & Selects

**Text-Input:**
```javascript
{
  border: '1.5px solid #e7e5e4',
  borderRadius: 10,
  padding: '9px 12px',
  fontSize: 13, fontWeight: 600,
  outline: 'none',
  background: '#fafaf8',            // IMMER #fafaf8 für Inputs (nicht e8e5e1!)
  color: '#1c1917',
  fontFamily: 'inherit',
  width: '100%'
}
// Mit Fehler: { border:'1.5px solid #fca5a5', background:'#fff1f2' }
```

**Select (immer mit Chevron):**
```javascript
// Select: gleich wie Input + { appearance:'none', paddingRight:28 }
// Wrapper: { position:'relative' }
// Chevron: <svg style={{position:'absolute',right:10,top:'50%',
//   transform:'translateY(-50%)',pointerEvents:'none'}}
//   width="11" height="11" stroke="#a8a29e" strokeWidth="2.5">
//   <polyline points="6 9 12 15 18 9"/></svg>
```

**Textarea:**
```javascript
{ ...Input, resize:'none', minHeight:70 }
```

---

### 4.10 Segmented Controls

```javascript
// Container
{ display:'flex', padding:2, background:'#e7e5e4', borderRadius:9, gap:1 }

// Button aktiv
{
  flex:1, padding:'7px', borderRadius:7,
  background:'#1c1917', color:'#fff',
  fontSize:10, fontWeight:700,
  border:'none', cursor:'pointer', fontFamily:'inherit',
  transition:'all .15s'
}

// Button inaktiv
{ background:'transparent', color:'#78716c' }
```
Für farbige Segmented Controls (z.B. Schweregrad): aktiv = jeweilige Severity-Farbe (bg/text).

---

### 4.11 Badges / Pills

```javascript
{
  display: 'inline-flex', alignItems: 'center',
  padding: '2px 7px',
  borderRadius: 999,
  fontSize: 9, fontWeight: 700,
  whiteSpace: 'nowrap'
}
```
Farben je nach Kontext (Severity, Status, Kategorie) — immer mit passendem border.

---

### 4.12 Sticky Save-Bar

```javascript
// Wrapper
{
  position: 'sticky', bottom: 0,
  background: '#fff',
  borderTop: '1px solid #e7e5e4',
  padding: '10px 12px',
  display: 'flex', gap: 8,
  paddingBottom: 'calc(10px + env(safe-area-inset-bottom,0px))'
}
// Speichern: { flex:2, ...Primär-Button }
// Abbrechen: { flex:1, ...Sekundär-Button }
```

---

### 4.13 Löschen-Bestätigung (Bottom-Sheet — KEIN Modal)

```javascript
// Overlay
{
  position: 'fixed', inset: 0,
  background: 'rgba(0,0,0,.45)', zIndex: 60,
  display: 'flex', alignItems: 'flex-end',
  justifyContent: 'center', padding: 12
}

// Sheet (stopPropagation auf click)
{
  background: '#fff',
  borderRadius: 18,
  width: '100%', maxWidth: 400,
  padding: 20
}
```

---

### 4.14 Suchfeld

```javascript
// Wrapper: { position:'relative' }
// Icon:    <svg style={{position:'absolute',left:10,top:'50%',transform:'translateY(-50%)'}}>
// Input:   { ...Input, padding:'9px 12px 9px 32px' }  // extra padding links für Icon
```

---

### 4.15 Trennlinien & Abstandsregeln

```
Karten-Abstand (gap): 9–10px
Row-Trennlinie:  1px solid #f0eeec  (innerhalb weißer Karte)
Header-Trennlinie: 2px solid #e7e5e4  (Header-Unterseite — immer 2px)
Section-Abstand: 10px gap zwischen Sections
Body-Padding:    12px ringsum (Scroll-Bereiche)
```

---

### 4.16 Banners (Flow / Info / Fehler)

**Flow-Banner (amber — Workflow-Reihenfolge):**
```javascript
{
  background:'#fffbeb', border:'1px solid #fde68a',
  borderRadius:12, padding:'10px 12px'
}
// Titel: fontSize:8, fontWeight:800, color:'#92400e', textTransform:'uppercase'
// Text:  fontSize:10, color:'#92400e', lineHeight:1.5
```

**Info-Banner (blau — Erklärungen):**
```javascript
{
  display:'flex', alignItems:'flex-start', gap:9,
  background:'#eff6ff', border:'1px solid #bfdbfe',
  borderRadius:12, padding:'10px 12px',
  fontSize:10, color:'#1e40af', lineHeight:1.55
}
// Icon: info-circle, stroke:#3b82f6
// WICHTIG: Text als JSX-Children (nie dangerouslySetInnerHTML mit HTML-Tags!)
```

**Fehler-Banner (rot):**
```javascript
{
  display:'flex', alignItems:'center', gap:8,
  background:'#fff1f2', border:'1px solid #fecdd3',
  borderRadius:12, padding:'10px 13px',
  fontSize:11, fontWeight:700, color:'#e11d48'
}
```

---

### 4.17 Formular-Standard-Struktur

```
1. Sticky Header (Zurück + Titel)
2. FlowBanner [amber]   — nur bei Datenbank-Formularen
3. Section A → Section-Label + Karte mit Zeilen (Label → Feld)
4. InfoBanner [blau]    — direkt vor erklärungsbedürftigem Abschnitt
5. Section B → Section-Label + Karte
6. Fehler-Banner [rot]  — nur wenn Pflichtfelder fehlen
7. Sticky Save-Bar
```

---

### 4.18 Listen-Standard-Struktur

```
1. Sticky Header (Zurück + Titel + Plus-Button)
2. Suchfeld (im body-Padding)
3. Counter-Label (Section-Label-Stil, "3 Einträge")
4. Karten-Liste (gap:10px)
   Karte:
   ├─ Inhalt-Bereich (Name, Badges, Meta)
   └─ Fußzeile (padding:8px 13px, borderTop:1px solid #f0eeec)
      ├─ Links: Meta-Angaben (Zähler, Verwendungen)
      └─ Rechts: Stift + Löschen Icon-Buttons
5. Leer-Zustand: weiße Karte, Text + optionaler CTA
```

---

### 4.19 Render-Funktionen — ZWINGEND

Babel Standalone crasht wenn JSX-Komponenten innerhalb anderer mit `const X = () =>` definiert werden.

```javascript
// FALSCH → Whitescreen:
const FlowBanner = ({ step }) => (<div>...</div>);

// RICHTIG:
const renderFlowBanner = (step) => (<div>...</div>);
// Aufruf: {renderFlowBanner(2)}
```

---

### 4.20 Datenbank-Workflow (Reihenfolge — überall konsistent)

```
Schritt 1 → Diagnosen anlegen
Schritt 2 → Medikamente anlegen + mit Diagnosen verknüpfen
Schritt 3 → Behandlungsvorlagen bauen
Schritt 4 → Behandlung am Igel anwenden
```

---

### 4.21 Igel-Farbpalette (Karten-Banner)

```javascript
const IGEL_COLORS = ['#5c5248','#6b4f38','#4a6352','#5c4a6b','#7a5c34','#4a5568','#5a4a3a','#3d5a4a'];
const COLOR_NAMES = ['Kakao','Kastanie','Salbei','Pflaume','Umber','Schiefer','Mokka','Moos'];
```
Banner immer mit `color:'#fff'` auf diesen Hintergründen.

---

### 4.22 Severity / Status Farben

**Severity-Badges:**
```
Leicht:  bg:#dcfce7  text:#166634  border:#86efac
Mittel:  bg:#fef3c7  text:#92400e  border:#fde68a
Schwer:  bg:#fee2e2  text:#dc2626  border:#fca5a5
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

**Timeline-Zustände:**
```javascript
const TL_SEG  = {'done-open':'#f0fdf4','done-locked':'#f0fdf4','due':'#fefce8','overdue-locked':'#fff1f2','pending':'#fafaf8'};
const TL_ICOL = {'done-open':'#166634','done-locked':'#166634','due':'#ca8a04','overdue-locked':'#e11d48','pending':'#d6d3d1'};
const TL_LOCKED = {'done-locked':true,'overdue-locked':true};
const TL_CAN    = {'done-open':true,'due':true};
```


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


### 5.2a Firestore Security Rules

Die Rules-Datei `firestore.rules` muss in Firebase Console unter **Firestore → Rules** eingefügt werden.

**Wichtig für Anwesenheitsplan:** Die `anwesenheit` Collection braucht diese Regel:
```
match /anwesenheit/{docId} {
  allow read: if isAuthenticated();
  allow create, update: if isActiveUser() &&
    request.resource.data.userId == request.auth.uid;
  allow delete: if isAdmin();
}
```

Ohne diese Regel → `Missing or insufficient permissions` beim Speichern.

**Alle Collections in firestore.rules:**
- `hedgehogs` — read: auth, write: activeUser
- `users` — read: auth, write: admin || eigener Doc
- `diagnosisDatabase`, `medicationDatabase`, `treatmentDatabase` — read: auth, write: activeUser
- `anwesenheit` — read: auth, write: activeUser (nur eigene userId)
- `planConfig`, `feiertage`, `planVorlage` — read: auth, write: admin
- `app_todos`, `invites` — read: auth, write: admin
- `auditLog` — read: admin, create: auth, update/delete: false

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

### 5.5 str_replace — Sicherheitsregeln (PFLICHT)

Jede `str_replace`-Operation an `index.html` muss folgende Verifikationsschritte durchlaufen, bevor die Änderung als fertig gilt:

**Vor dem Replace:**
1. Mit `grep -n` oder `view` prüfen: Kommt der `old_str` **genau einmal** vor? Bei mehrfachem Vorkommen schlägt das Replace fehl oder trifft die falsche Stelle.
2. Den Kontext um die Zielstelle lesen — sicherstellen dass kein benachbarter Code unbeabsichtigt entfernt wird.

**Nach jedem Replace sofort ausführen:**
```python
# Balance-Check (Pflicht nach jeder Änderung)
python3 -c "
import re
with open('index.html','r') as f: c=f.read()
s=re.search(r'<script type=\"text/babel\">(.*?)</script>',c,re.DOTALL).group(1)
print('Braces: %d, Parens: %d' % (s.count('{')-s.count('}'), s.count('(')-s.count(')')))
"
# Beide müssen 0 sein — sonst sofort rückgängig machen

# State-Vollständigkeits-Check nach State-Änderungen:
python3 -c "
with open('index.html','r') as f: c=f.read()
states = ['showDesignSpec','showBatchBearbeitung','showDatenbankHub','showMedikamentDB',
          'showDiagnoseDB','showTreatmentDB','showUserMgmt','showSettings','showChangelog',
          'showTodoList','showProfile','showAddForm','showQRScanner','showPflegeplan','showBestand']
for s in states:
    ok = ('const ['+s) in c
    print(('OK' if ok else 'FEHLT!'), s)
"
```

**Kritische Fallen bei str_replace:**

| Situation | Risiko | Gegenmaßnahme |
|-----------|--------|---------------|
| State A ersetzen durch State B | State A-Setter noch in closeAll/popstate → ReferenceError | Immer **ergänzen**, nie ersetzen; alten State behalten |
| `old_str` kommt mehrfach vor | Falsches Replace | vorher `grep -c` zählen |
| Langer `old_str` mit Sonderzeichen | Match schlägt lautlos fehl | Immer mit kurzem, eindeutigem Anker arbeiten |
| State aus `_backState` entfernen aber Setter bleibt | Stale-Closure-Warnung | State + alle Setter + _backState-Eintrag + popstate-Eintrag + closeAll-Eintrag zusammen ändern |

**Goldene Regel:** Wenn ein State-Name neu eingeführt wird, niemals den Replace auf eine Zeile beschränken die auch einen anderen State-Namen enthält. Immer **addieren**, nie substituieren.

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
9. **State-Setter referenced but undeclared?** → Nach jedem State-Refactoring alle `set*`-Aufrufe in closeAll, closeAllExceptMenu, _backState, popstate gegen deklarierte States abgleichen (v2.4.13-Bug)

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

### 8.16 BatchBearbeitung (v2.4.10+)

**Zweck:** Massenbearbeitung mehrerer Igelkarten gleichzeitig. Nur für Admins zugänglich.

**Props:** `{ userData, users, hedgehogs, onClose }`

**States:**
```javascript
step          'overview' | 'select' | 'configure' | 'result'
selectedIds   Set<string>  — ausgewählte Igel-IDs
chosenAction  'pfleger' | 'status' | 'notiz' | 'delete'
configValue   String — neuer Wert (Pfleger-Name / Status-Key / Notiz-Text)
statusFilter  'active' | 'all'  — Filterung der Auswahl-Liste
search        String
saving        bool
result        { ok, fail, action, value } | null
```

**Verfügbare Aktionen:**
```
pfleger  → batch.update: betreuer + changeHistory-Eintrag
status   → batch.update: status + statusHistory + changeHistory
notiz    → batch.update: notizen (append mit ---\n Trennlinie)
delete   → batch.delete (permanent, kein Rollback)
```

**Firestore-Schreibweise:** Firestore `batch()` — alle Igel in einem Atomic-Write. `changeHistory` via `arrayUnion()`. `statusHistory` via `arrayUnion()`. `serverTimestamp()` NICHT in Arrays → `new Date().toISOString()`.

**Menü-Integration:**
- HTML-Kachel `ms-batch-admin` → `display:flex` wenn isAdmin, sonst `display:none`
- HTML-Kachel `ms-batch-locked` → `display:flex` wenn NICHT isAdmin (ausgegraut + Schloss)
- Window-Global: `window.__igelBatch()` → `__igelCloseAll()` + `setShowBatchBearbeitung(true)` + `history.pushState`
- popstate: `s.showBatchBearbeitung → setShowBatchBearbeitung(false) + Menü öffnen`

**Fallstricke:**
- `dangerouslySetInnerHTML={{__html:a.iconPath}}` für SVG-Pfade in Action-Kacheln — Babel-safe weil kein `<tag>` in Template-Literal
- `selectedHedgehogs` muss aus `hedgehogs.filter(h=>selectedIds.has(h.id))` kommen — nicht aus `displayHedgehogs` (die sind gefiltert!)
- Bei `delete`: kein `configValue` nötig — Button trotzdem aktiv

**Pfade:**
```
Menü-Kachel (Admin) → BatchBearbeitung Übersicht
  → Aktion klicken → Igel auswählen (Step select)
  → Weiter → Konfigurieren (Step configure)
  → Anwenden → Ergebnis (Step result)
  → Fertig → onClose() → Menü
```

---

## Menü-Struktur (ab v2.4.10)

| Kachel | Sichtbar für | Aktion |
|--------|-------------|--------|
| Stammdaten | alle | DatenbankHub (früher: „Datenbank") |
| Benutzer | alle (Funktion nur Admin) | UserManagement |
| Einstellungen | alle | SettingsDialog |
| Changelog | alle | Changelog |
| To-Do | nur Admin | TodoList |
| Sammelbearbeitung | Admin: amber aktiv; andere: ausgegraut | BatchBearbeitung |
| ~~App-Spezifikation~~ | permanent ausgeblendet | — |

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
| 2.5.50 | ICS floating time; Routing Back korrekt; window.__batchSetStep |
| 2.5.49 | ICS Google-fix; rote Überschrift; Zurück-Button fix |
| 2.5.48 | anwKalender Subpage; kein Composite Index; eine Kalender-Kachel |
| 2.5.47 | ICS+Cleanup als interne Steps; kein doppeltes Komplettbackup; Header→__igelBatchExport |
| 2.5.46 | Fix: onOpenAnwExport Prop; Header window.__igelDatenbank; Anwesenheitsplan vor Komplettbackup |
| 2.5.45 | Fix Whitescreen: ICS+Cleanup in MainApp; Kacheln in Daten-Export |
| 2.5.44 | Kalender-Export (.ics) + Bereinigung + Absprung aus Anwesenheitsplan |
| 2.5.43 | Notiz-Bereich aus Edit-View entfernt |
| 2.5.42 | Pill Geplant dunkelgrau; Track: Geplant abwesend |
| 2.5.41 | Fix: absent/Geplant wurde in saveEntry gelöscht statt gespeichert |
| 2.5.40 | Geplant: grauer Vollbalken #d8d5d2 mit Text |
| 2.5.39 | absent: #d8d5d2 dunkler grau + A, kein Schraffur |
| 2.5.38 | Fix: absent Priorität 1 in Team-Grid; u.id als userId-Key |
| 2.5.37 | Pill Abwesend→Geplant; openEditFor via getMyDayEntry; matchUser() robuster |
| 2.5.36 | Urlaub-Modus fix (matchMe); Hint-Texte entfernt; absent in Früh+Spät |
| 2.5.35 | Urlaub-Vorauswahl fix; Tag-Anzeige ohne Kalender; cross-shift Abweichung gelb in beiden Schichten |
| 2.5.34 | Edit: Mehrfachauswahl-Toggle; Kalender nur bei Ja; Modus-Vorauswahl korrekt |
| 2.5.33 | Team Zeit zweizeilig; Multi-Select schwarz/weiß; openEditFor Abwesenheits-Modus-Fix |
| 2.5.32 | Meine Woche: Chip Variante 1 monochrom+Heute schwarz; Früh/Spät als Bubbles |
| 2.5.31 | Team: ①leer grau ②geplant+◇ ③abw Zeitbadge ④Legende ohne Früh/Spät |
| 2.5.30 | Team: Bubble-Dot vor Frühschicht/Spätschicht entfernt |
| 2.5.29 | Meine Woche: 1:1 Farb-Mapping (Team-Zellen), kein Chip-Border, ◇ Geplant, amber Zeitbadge, Schicht-Labels |
| 2.5.28 | Einstellungen: Anwesenheitsplan-Kachel; adminOrigin-Routing; Gelb #fde68a vereinheitlicht |
| 2.5.27 | Fix: History Sheet bottom über BottomBar (62px); Infotext Verlauf unter Legende |
| 2.5.26 | Abweichung gelb (Balken + Legende); History-Sheet scrollbar; Meine Woche Legende aktualisiert |
| 2.5.25 | Fix: History orderBy entfernt; Team absent→Früh/Spät; Kalender Farbcodierung; Firestore delete eigene Einträge |
| 2.5.24 | Firestore Rules: anwesenheit_history (read=auth, create=activeUser+own, update/delete=false) |
| 2.5.23 | Team-Übersicht: Konzept A (Datum-Chips) + Verlauf-Sheet; anwesenheit_history Collection; saveEntry schreibt History |
| 2.5.22 | Fix: Anwesenheit auf Feiertag sichtbar; chipStyle priorisiert Entry über ft; !ft-Guards in Track entfernt; Bundesland-Dropdown (openholidaysapi); planConfig.bundesland |
| 2.5.21 | Feiertage editierbar: Edit-Kalender + Zeitband-Klick; Admin Feiertagskalender-Sektion |
| 2.5.20 | Meine Woche: Konzept B — farbiger Datum-Chip (50px), Status-Dot-Zeile entfernt, Track height:32 |
| 2.5.19 | Edit-View: Mobile-Layout-Fix; sticky Save-Bar + marginBottom; Kalender height:36 |
| 2.5.18 | Edit-View Konzept B: Kalender+Multi-Select, Anwesend/Abwesend-Kacheln, Akkordeon-Schichten, Pill-Chips |
| 2.5.17 | Fix: Spinner renderTeamGrid — 3 überflüssige </div>-Tags; div-Balance-Check eingeführt |
| 2.5.16 | Team: F/S-Buchstaben entfernt; Frühschicht/Spätschicht-Label; Multi-Tage überschreibt immer |
| 2.5.15 | Team: Coverage als Karte; Du-Legende entfernt |
| 2.5.14 | Abwesend-Kategorie (löscht Eintrag); Team Du-Band; Stat-Kacheln größer |
| 2.5.13 | Zeitband 0–24h; Edit-Button entfernt; Schicht-Start/End-Linien |
| 2.5.12 | Fix: renderTeamGrid </div>; Schraffur weg; vertikale Trennlinie |
| 2.5.11 | UI-Fixes: Ist-Stunden kein h; Admin-Einstellungen overflow-fix; Time-Badge schwarz |
| 2.4.18 | Export: showSaveFilePicker, Speicherort-Karte, Fehler-Toast, 8s, HH-MM-SS Timestamp |
| 2.4.17 | Export: grüner Toast nach Download, withExportConfirm(), auto-dismiss 4s |
| 2.4.16 | Export-Seite: Info-Banner, Igelkarten/Stammdaten/Komplettbackup, Import-Platzhalter |
| 2.4.15 | Sammelbearbeitung: Behandlung starten + Export-Sektion | batchTreatmentDB, downloadCSV, 5 Export-Funktionen, behandlung in applyAction |
| 2.4.14 | Sicherheit AdminSetup: Race-Condition + Doppelprüfung | null statt false bei Fehler/Timeout, strict equality, Gegencheck vor Account-Anlage |
| 2.4.13 | Fix: showDesignSpec entfernt statt ergänzt → ReferenceError → Whitescreen | str_replace-Sicherheitsregeln in Abschnitt 5.5 dokumentiert |
| 2.4.12 | Fix: Header als Inline-Komponente → renderHeader() render-Funktion |
| 2.4.11 | Fix: dangerouslySetInnerHTML iconPath-Strings → renderActionIcon() |
| 2.4.10 | Sammelbearbeitung + Menü | BatchBearbeitung-Komponente, Menü Datenbank→Stammdaten, DesignSpec ausgeblendet, Batch-Aktionen Pfleger/Status/Notiz/Löschen |
| 2.4.09 | Option D: Kontrast-Redesign global — NEUER STANDARD | Seitenhintergründe #e8e5e1, Karten 1.5px #c9c5c1, Shadow 0 8px 28px .18, Design-System Abschnitt 4 vollständig überarbeitet | | Seitenhintergründe #e8e5e1, Karten-Border 1.5px #c9c5c1, Shadow 0 8px 28px .18 auf allen Seiten |
| 2.4.08 | Fix: Info-Tab Whitescreen — `React.useState` in JSX-IIFE → State + validateAndSave nach Top-Level gehoben |
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

*Zuletzt aktualisiert: März 2026 · v2.4.08*

---

## Konzept: Anwesenheitsplan (v2.5.x)

**Konzept-Dateien:** `konzept_anwesenheitsplan.html`, `konzept_anwesenheit_v1.html`, `KONZEPT_ANWESENHEITSPLAN.md`

**Gewähltes Design:** Kombination A+B — Zeitband (Meine Woche) + Grid (Team-Übersicht) + Karten (Detail/Edit)

**Firestore Collections:**
- `anwesenheit` — Dokument-ID: `{userId}_{date}_{shift}` · Felder: userId, date, shift, status, timeFrom, timeTo, note, updatedAt
- `planConfig/settings` — Schichtzeiten, Mindestbesetzung, Vorlaufzeit, Bundesland, Feiertage
- `feiertage/{year}_{bundesland}` — gecachte Feiertage von openholidaysapi.org
- `planVorlage/standard` — wöchentliche Vorlage je Pfleger

**MainApp-Integration:**
- State: `const [showAnwesenheit, setShowAnwesenheit] = useState(false);`
- _backState Priorität: nach showBatchBearbeitung, vor showUserMgmt
- Global: `window.__igelAnwesenheit()`
- Menü: neue Kachel „Anwesenheit"

**Versionsplanung:** v2.5.00 (Grundgerüst) → v2.5.07 (Polish)

**Offene Entscheidungen vor Start:**
1. BottomBar-Button oder nur Menü?
2. Selbsteintragung durch alle Pfleger oder nur Admin?
3. Sperr-Logik ab X Stunden vor Schicht
4. Wochenende: immer gesperrt oder optional?
5. Plan-Vorlage wird vorausgefüllt?

