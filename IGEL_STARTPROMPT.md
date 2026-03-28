# Igelpflegestation Pro — Startprompt v2.5.85

## Projekt-Kontext
- **Stack:** React 18 + Babel Standalone · Firebase 10.7.1 (compat) · Tailwind CDN · DM Sans
- **Deployment:** dstindl.github.io/IGELSTATION_nei
- **Working Directory:** `/home/claude/igel_new/`
- **Aktuelle Version:** v2.5.85

## ZIP-Befehl
```
cd /home/claude/igel_new && rm -f /home/claude/Igelstation.zip && zip /home/claude/Igelstation.zip index.html service-worker.js icon-192.png icon-512.png deploy.sh update.sh PROJEKTDOKU_all.md IGEL_STARTPROMPT.md firestore.rules
```

## Kritische Regeln
- Inline-Komponenten → VERBOTEN in render() — verursacht Remount-Loop/Spinner
- `const X = () =>` innerhalb eines Render-Blocks → immer als direktes JSX inlinen
- `padStart` VERBOTEN in Template-Literals → `(n<10?'0':'')+n`
- SVG camelCase: `strokeWidth`, `strokeLinecap`
- `serverTimestamp()` NIE in Arrays → `new Date().toISOString()`
- Balance-Check nach jeder Änderung: Braces + Parens müssen 0 sein
- **5 Versionsstellen** bei jedem Bump: (1) Changelog array, (2) msheet-version, (3) Changelog header text, (4) LoadingScreen version, (5) Service Worker cache name
- **KRITISCH: Alle `useState` VOR `useEffect`/`useRef`**
- Firestore: IMMER nur `userId`-Query + client-seitige Filterung
- **KEIN `{{{` triple-brace in JSX** — verursacht Babel-Spinner
- **KEIN Syntax-Müll** nach useState (z.B. `};,'erledigt'`) → Parse-Fehler

## Bekannte Spinner-Ursachen
1. `const X = () =>` inline in render() → Remount-Loop
2. `{{{` triple-brace in JSX → Babel-Parse-Fehler
3. useState nach useEffect → Hook-Violation
4. Syntax-Müll nach useState (z.B. `};,'erledigt'`) → Parse-Fehler
5. padStart in Template-Literals → Babel-Fehler
6. Fehlende `}` in verschachtelten Blöcken → Babel-Syntax-Fehler

## Architektur

### Firestore Collections
- `hedgehogs` — Igelkarten
- `anwesenheit` — Anwesenheitseinträge (uid_date_shift als DocId)
  - shift: 'fruh' | 'spat' | 'indiv' | 'absent'
  - status: 'real' | 'planned' | 'urlaub' | 'krank' | 'absent'
  - timeFrom, timeTo: Zeitstrings 'HH:MM'
- `planConfig/settings` — Schicht-Einstellungen
- `users` — Benutzer mit Rollen
- `anwesenheit_history` — Änderungsverlauf

### Anwesenheit-Logik (v2.5.80+)
- **3 Radio-Buttons**: Früh / Spät / Individuell
- Früh/Spät: feste Plan-Zeiten aus planConfig, nicht editierbar
- Individuell: Von/Bis frei, Grenzen frühestes fruhVon bis spätestes spatBis
- Speichern überschreibt ALLE bestehenden Einträge des Tages
- Individuell Coverage: overlaps → gelb, vollständig → grün
- Krank/Urlaub/Abwesend: grau in allen Ansichten

### Dashboard (v2.5.71+)
- Section-Labels: IGELBESTAND / PFLEGESTATUS HEUTE / ANWESENHEIT
- Anwesenheits-Kachel: Team + Meine Woche mit Expand-View
- KW-Navigation (0–4 Wochen voraus)
- dashAnwesenheiten State + useEffect lädt live per onSnapshot

## Versionshistorie (neueste)
- **v2.5.85**: Fix: Meine Woche Klick öffnet Edit
- **v2.5.84**: Fix: Team-Grid alle grün + Meine Woche Edit
- **v2.5.83**: Fix: Syntax-Debris in Edit-View
- **v2.5.82**: Fix: saveEntry fehlende } in for-Loop
- **v2.5.81**: Fix: RadioRow inline-Komponente entfernt
- **v2.5.80**: Anwesenheit: Radio-Schicht + Individuell + Krank/Urlaub grau
- **v2.5.79**: Dashboard: Team-Label öffnet Anwesenheit
- **v2.5.78**: Dashboard: Team-Kachel öffnet Anwesenheit
- **v2.5.77**: Fix: Anwesenheit-Edit Radio-Logik
- **v2.5.76**: Fix: Filter + Anwesenheit-Edit
- **v2.5.75**: Fix: Meine Woche + Team-Farben + Pills
- **v2.5.74**: Fix: Triple-Braces im Dashboard
- **v2.5.73**: Fix: SvgCheck inline-Komponente → direktes SVG
- **v2.5.73**: Fix: Hook-Reihenfolge — useEffect nach allen useState
- **v2.5.72**: Fix: Syntax-Fehler + useEffect Anwesenheit Dashboard
- **v2.5.71**: Dashboard: Sektions-Labels, Pills, Nächste Behandlungen, Anwesenheits-Kachel live
- **v2.5.71**: Debug-Screen entfernt
- **v2.5.64**: Routing origin-bewusst: Meine Woche→MeineWoche, Sammelbearbeitung→Daten-Export
- **v2.5.54**: Fix: user.uid an BatchBearbeitung für ICS Export
- **v2.5.53**: ICS führend Igelstation + Back Meine Woche fix