# Igelpflegestation Pro — Projektdokumentation
**Stand:** 28.03.2026 · **Version:** v2.5.85

---

## Stack
- React 18 + Babel Standalone (kein Build-Step)
- Firebase 10.7.1 compat
- Tailwind CSS CDN · DM Sans + DM Mono
- jsQR für QR-Scanner

## Kritische Regeln

### Spinner-Vermeidung
1. Keine inline Komponenten in render(): `const X = () =>` → Remount-Loop
2. Kein triple-brace in JSX → Babel-Parse-Fehler
3. useState VOR useEffect/useRef — Hook-Violation
4. Kein Syntax-Müll nach useState
5. padStart VERBOTEN in Template-Literals
6. Fehlende schliessende Klammern in verschachtelten Blöcken

### 5 Versionsstellen bei jedem Bump
1. Changelog array im Code
2. msheet-version im HTML-Menü
3. Changelog-Header-Text
4. LoadingScreen version
5. Service Worker cache name

## Anwesenheit (v2.5.80+)
- 3 Radio-Buttons: Früh / Spät / Individuell
- Früh/Spät: feste Plan-Zeiten, nicht editierbar
- Individuell: Von/Bis frei wählbar
- Speichern überschreibt alle Einträge des Tages
- Krank/Urlaub: grau in allen Ansichten
- shift-Werte: fruh | spat | indiv | absent

## Dashboard (v2.5.71+)
- Sektionen: IGELBESTAND / PFLEGESTATUS HEUTE / ANWESENHEIT
- Anwesenheits-Kachel mit Expand-View, KW-Navigation
- dashAnwesenheiten per onSnapshot live

---

## Changelog

### v2.5.85 — Fix: Meine Woche Klick öffnet Edit
- if(!we) Guard entfernt — Klick auch an Wochenend-Tagen erlaubt
- openEditFor läuft immer durch

### v2.5.84 — Fix: Team-Grid alle grün + Meine Woche Edit
- Team-Grid: indiv-Block war if statt else if → überschrieb alle Farben mit grün
- Meine Woche: Klick auf Werktag öffnet Edit-View korrekt

### v2.5.83 — Fix: Syntax-Debris in Edit-View
- planSpatBis hatte }; Anhang vom alten renderAccordionRow → Babel-Fehler

### v2.5.82 — Fix: saveEntry fehlende } in for-Loop
- else + for hatten nur eine schließende Klammer → Babel-Syntax-Fehler → Spinner

### v2.5.81 — Fix: RadioRow inline-Komponente entfernt
- const RadioRow = () => in render() verursachte Remount-Loop → direkt JSX

### v2.5.80 — Anwesenheit: Radio-Schicht + Individuell + Krank/Urlaub grau
- 3 Radio-Buttons: Früh/Spät/Individuell (Radio-Verhalten)
- Früh+Spät zeigen feste Plan-Zeiten
- Individuell: Von/Bis frei, Überlappungs-Anzeige
- saveEntry: überschreibt alle Einträge des Tages
- getShiftPresent: indiv-Einträge berücksichtigt
- Team-Kalender: indiv grün/gelb je Coverage
- Krank/Urlaub: grau in Meine Woche + Team-Kalender
- Legende aktualisiert

### v2.5.79 — Dashboard: Team-Label öffnet Anwesenheit
- Klick auf "Team" Headline öffnet Anwesenheits-Ansicht
- Expand-View in Kachel bleibt erhalten

### v2.5.78 — Dashboard: Team-Kachel öffnet Anwesenheit
- Klick auf Team-Kachel öffnet direkt die Anwesenheits-Ansicht

### v2.5.77 — Fix: Anwesenheit-Edit Radio-Logik
- Checkbox Früh/Spät: nur eine Schicht gleichzeitig aktiv
- Freie Zeitangabe (VON/BIS) bleibt möglich

### v2.5.76 — Fix: Filter + Anwesenheit-Edit
- Pflegestatus-Filter nicht mehr im Igelbestand-Filter angezeigt
- Anwesenheit-Edit: nur Früh/Spät Checkbox, keine freien Zeiten

### v2.5.75 — Fix: Meine Woche + Team-Farben + Pills
- useEffect Anwesenheiten korrekt platziert (Hook-Violation behoben)
- Meine Woche: onSnapshot lädt eigene Schichten live
- Team-Kachel: Schicht-Text rot/gelb je Besetzung
- Kachel-Icon: rot wenn none, gelb wenn warn
- Pills: farbig hervorheben wenn count > 0

### v2.5.74 — Fix: Triple-Braces im Dashboard
- SEK_STYLE + CARD_STYLE hatten {{{ statt {{ → Babel-Spinner
- Alle 4 Vorkommen behoben

### v2.5.73 — Fix: SvgCheck inline-Komponente → direktes SVG
- const SvgCheck = () => in render() verursachte Remount-Loop → Spinner
- SVG jetzt direkt eingebettet

### v2.5.73 — Fix: Hook-Reihenfolge — useEffect nach allen useState
- useEffect für dashAnwesenheiten war zwischen useState-Definitionen eingefügt → Spinner
- Jetzt korrekt nach _lastBackMs useRef platziert
- 0 Hook-Violations

### v2.5.72 — Fix: Syntax-Fehler + useEffect Anwesenheit Dashboard
- Syntax-Müll nach dashAnwMwSel useState entfernt
- useEffect für dashAnwesenheiten und dashPlanConfig ergänzt

### v2.5.71 — Dashboard: Sektions-Labels, Pills, Nächste Behandlungen, Anwesenheits-Kachel live
- Gruppe-Labels: Igelbestand / Pflegestatus Heute / Anwesenheit
- Pills statt Kacheln für Fällig/Überfällig/Erledigt
- Nächste Behandlungen im Pflegestatus
- Anwesenheits-Kachel: Team + Meine Woche mit Expand-View
- KW-Navigation, Detailview auf Klick
- Schnellzugriff-Buttons entfernt

### v2.5.71 — Debug-Screen entfernt
- LoadingScreen: Phasen-Anzeige entfernt — nur noch Spinner sichtbar

### v2.5.64 — Routing origin-bewusst: Meine Woche→MeineWoche, Sammelbearbeitung→Daten-Export
- batchOrigin State: anwesenheit|menu
- popstate + onClose + __batchBack: origin-gesteuert
- anwKalender Back: initialStep=anwKalender→onClose, sonst→setStep(export)

### v2.5.54 — Fix: user.uid an BatchBearbeitung für ICS Export
- BatchBearbeitung: userData={{...userData, uid:user.uid}} statt userData

### v2.5.53 — ICS führend Igelstation + Back Meine Woche fix
- ICS Summary: Igelstation - Fruehschicht Anwesend
- BatchBearbeitung onClose: kein Menü wenn showAnwesenheit=true
- popstate: kein window.igelMenuOpen wenn Anwesenheit offen

### v2.5.52 — Löschbutton mehrere Tage + Back-Routing Fix
- Löschbutton: alle editCalSelected Tage löschen
- Confirm-Text für mehrere Tage
- window.__batchGetStep für popstate-Routing
- popstate: batchStep=anwKalender → export statt Menü

### v2.5.51 — 4 Fixes: Step-Reset, Wochenstart, Löschbutton, ICS MIME
- Fix 2: BatchBearbeitung step-Reset via useEffect(initialStep)
- Fix 3: week-preset Montag-Start: (getDay()+6)%7
- Fix 4: Löschbutton im Edit-SaveBar + deleteEntry + Confirm-Popup
- ICS: MIME-Type ohne charset, Dateiname vereinfacht

### v2.5.50 — Routing fix + ICS floating time
- ICS: DTSTART/DTEND ohne TZID (floating local time), kein VTIMEZONE nötig
- window.__batchSetStep + goToAnwKalender + history.pushState
- popstate: batchAnwKalender → step=export; BatchBearbeitung Back behält Anwesenheit

### v2.5.49 — 3 Fixes: ICS Google-kompatibel, Überschrift rot, Zurück-Button
- ICS: DTSTAMP, DTEND+1Tag Ganztag, TZID=Europe/Berlin, METHOD:PUBLISH
- Alte Einträge Überschrift: rot
- Zurück aus BatchExport: showAnwesenheit bleibt erhalten

### v2.5.48 — Kalender-Subpage: Export+Löschen auf einer Seite; kein Composite Index
- Step anwKalender: ICS Export + Bereinigung auf einer Seite
- Firestore: nur userId-Query + client-seitige Date-Filterung (kein Index nötig)
- Eine Kachel Kalender statt zwei
- __igelBatchExport öffnet direkt anwKalender

### v2.5.47 — Fix: ICS+Cleanup als Steps in BatchBearbeitung; Header→BatchExport
- Steps anwIcs+anwCleanup innerhalb BatchBearbeitung
- Kein doppeltes Komplettbackup mehr
- window.__igelBatchExport öffnet BatchBearbeitung auf step=export
- Header-Button Anwesenheitsplan → __igelBatchExport

### v2.5.46 — Fix: Kacheln via onOpenAnwExport Prop; Header window.__igelDatenbank
- BatchBearbeitung: onOpenAnwExport Prop; Kacheln VOR Komplettbackup
- Header Export-Button: window.__igelDatenbank statt direkter State-Setter

### v2.5.45 — Fix: ICS+Cleanup in MainApp, Kacheln in Daten-Export
- States + Sub-Views in MainApp (nicht DataExport)
- Kacheln in Daten-Export nach Komplettbackup
- DatenbankHub whitescreen behoben
- popstate für anwExportIcs + anwExportCleanup

### v2.5.44 — Kalender-Export + Bereinigung + Anwesenheitsplan-Header
- Export-Icon (blau) im Anwesenheitsplan-Header für alle User
- hubBack: anwesenheit-origin zurück zu Anwesenheitsplan
- DatenbankHub: neue Sektion Anwesenheitsplan mit 2 Kacheln
- ICS Export: Zeitraum-Picker, .ics Generator, Confirm-Popup
- Bereinigung: Slider, Zählen, Batch-Delete, Confirm-Popup

### v2.5.43 — Notiz-Bereich im Bearbeitungsmodus entfernt
- Notiz-Textarea und Label aus Edit-View entfernt

### v2.5.42 — Pill Geplant dunkelgrau + Track Text Geplant abwesend
- Pill Geplant: #d8d5d2 statt grün
- Track Meine Woche: Geplant abwesend statt Geplant

### v2.5.41 — Fix: Geplant (absent) wurde gelöscht statt gespeichert
- saveEntry: editAbwGrund===absent löschte den Eintrag — jetzt alle 3 Gründe gespeichert

### v2.5.40 — Geplant: grauer Vollbalken wie Krank/Urlaub
- Meine Woche: absent=Geplant als grauer Vollbalken #d8d5d2 mit Text Geplant
- Analog zu Krank (rot) und Urlaub (blau)

### v2.5.39 — absent: dunkleres Grau #d8d5d2 + A statt Schraffur
- Meine Woche + Team: absent = #d8d5d2 (dunkler als leer #f0f0ef) + A
- Kein Schraffur-Muster mehr
- Legende: Abwesend #d8d5d2
- Kalender Edit-View: absent dunkleres Grau

### v2.5.38 — Fix: absent Priorität 1 in Team-Grid — zeigt in beiden Schichten
- absent VOR shift-Lookup geprüft (Priorität 1)
- u.id als primärer userId-Key (doc ID = Firebase Auth UID)
- abw-Check nur noch auf shiftEntry/crossEntry — absent hat keine Abweichung

### v2.5.37 — Pill Abwesend→Geplant + absent beide Schichten + openEditFor fix
- Pill Abwesend → Geplant (grün #dcfce7, status:absent unverändert)
- Kachel-Untertitel: Krank · Urlaub · Geplant
- openEditFor: getMyDayEntry als Quelle für Modus-Bestimmung
- Team: matchUser() robuster für u.uid/u.id

### v2.5.36 — 3 Fixes: Urlaub-Modus, Hint entfernt, absent beide Schichten
- openEditFor: userId matchMe() mit uid+id Fallback
- Hint-Texte Tippen zum Eintragen aus Tracks entfernt
- Team: absentEntry explizit vor shift-Lookup → Krank/Urlaub/Abwesend in Früh+Spät

### v2.5.35 — 3 Fixes: Urlaub-Vorauswahl, Tag-Anzeige, Cross-Shift Coverage
- Urlaub: abwGrund vor editMode setzen, defensive Lesart
- Toggle Aus: Tag-Anzeige (schwarze Kachel mit Datum)
- Cross-Shift: Abweichung die beide Schichten überspannt → beide Zellen gelb
- Coverage: cross-shift Einträge zählen für beide Schichten
- getShiftPresent: toMin inline definiert

### v2.5.34 — Edit-View: Mehrfachauswahl-Toggle + Modus-Vorauswahl
- Toggle Mehrfachauswahl (Standard: Nein) — Kalender nur bei Ja sichtbar
- Bei Einzeltag: Anwesend/Abwesend + Parameter sofort korrekt vorbelegt
- Bei Mehrfachauswahl: Modus zuerst wählen, dann Parameter sichtbar
- openEditFor: editMultiMode=false beim Öffnen

### v2.5.33 — 3 Fixes: Abweichung Zeit zweizeilig, Multi-Select schwarz, openEditFor Modus-Fix
- Team: Abweichung Zeit in 2 Zeilen (Von/Bis übereinander)
- Multi-Select Bubble: schwarz (#1c1917) mit weißer Schrift
- openEditFor: alle 3 Abwesenheits-Typen korrekt als Abwesenheitsmodus erkannt

### v2.5.32 — Meine Woche: Chip Variante 1 + Früh/Spät Bubbles
- Chip Variante 1: alle Chips grau, nur Heute schwarz (#1c1917)
- Keine Status-Farbe mehr im Chip — nur aus Balken lesbar
- Früh/Spät Achsen-Bubbles: grünes Badge wie Zeitbadge (DM Mono, rgba-Hintergrund)

### v2.5.31 — Team-Übersicht: Konzept umgesetzt
- ① leer=#f0f0ef statt transparent; eigene Zeile #e8e6e4
- ② geplant=gleiche Schichtfarbe+◇ statt grau
- ③ Abweichung: Zeit in Zelle (fontSize:5.5)
- ④ Legende: Früh+Spät entfernt; ◇ Geplant ergänzt

### v2.5.30 — Team-Übersicht: Bubble-Dot vor Schicht-Label entfernt
- Grüner Dot-Marker vor Frühschicht/Spätschicht entfernt

### v2.5.29 — Meine Woche: 1:1 Farb-Mapping aus Team-Übersicht
- Chips: exakt dieselben Farben wie Team-Zellen, kein Border/Außenkontur
- Leer = #f0f0ef, geschlossen opacity .35
- Geplant = gleiche Schichtfarbe + ◇ im Chip + gestrichelter Balken
- Abweichung = #fde68a, amber Zeitbadge statt weiß
- Schicht-Linien: grün (#16a34a .3) statt schwarz
- Zeitachse: Schicht-Labels Früh/Spät unter Uhrzeiten
- Legende: Früh+Spät entfernt, Geplant(◇)+Abwesend ergänzt

### v2.5.28 — Einstellungen: Anwesenheitsplan-Kachel + Gelb vereinheitlicht
- SettingsDialog: Kachel Anwesenheitsplan/Plan-Einstellungen (nur Admin)
- adminOrigin: Zurück-Ziel je nach Aufruf (Einstellungen vs. Anwesenheitsplan)
- AnwesenheitsplanMain: initialAdminSettings+onAdminClose Props
- Gelb vereinheitlicht: #fde68a überall für Abweichung

### v2.5.27 — Fix: History Sheet über BottomBar + Infotext
- History-Sheet: bottom=calc(62px+safe-area) → nicht mehr von BottomBar verdeckt
- maxHeight von 78vh auf 72vh reduziert
- Infotext unter Legende: Hinweis auf Tippen→Verlauf-Funktion

### v2.5.26 — UI: Abweichung gelb, History scrollbar, Legende
- Meine Woche + Team: Abweichungsbalken gelb (#fef08a)
- Team-Legende: Abweichung gelb ergänzt
- Meine Woche Legende: Früh/Spät/Abweichung/Urlaub/Krank/Feiertag
- History-Sheet: Body minHeight:0+paddingBottom → voll scrollbar

### v2.5.25 — Fix: History schreiben, Team-Übersicht Einträge, Kalender Farben
- History: orderBy entfernt → kein Composite-Index nötig, client-seitig sortiert
- Team-Grid: absent-Einträge (Urlaub/Krank) auch in Früh/Spät-Rows sichtbar
- Kalender Edit-View: Tage farblich nach Eintrag (grün=Früh/Spät, blau=Urlaub, rot=Krank, amber=Abweichung)
- Firestore: delete für eigene Anwesenheits-Einträge erlaubt

### v2.5.24 — Firestore Rules: anwesenheit_history Collection
- anwesenheit_history: read=authenticated, create=activeUser+eigene userId, update/delete=false
- Unveränderliche Audit-Spur für Anwesenheits-Verlauf

### v2.5.23 — Team-Übersicht: Konzept A + Verlauf-Funktion
- Datum-Chips im Header (wie Meine Woche)
- Zell-Klick öffnet Verlauf-Sheet für Person+Tag
- anwesenheit_history Collection: changeType created/updated/deleted
- saveEntry schreibt History-Einträge automatisch mit
- History-Sheet: Timeline mit Zeitstempel + Benutzer + Status
- Du-Zeile grau hervorgehoben, Verlauf-Dot auf Zellen mit Eintrag

### v2.5.22 — Anwesenheitsplan: Feiertag-Eintrag sichtbar + Bundesland-Feiertagskalender
- Meine Woche: Anwesenheiten an Feiertagen jetzt korrekt im Zeitband sichtbar (chipStyle priorisiert Entry über ft)
- Track: !ft-Guards entfernt — Balken/Labels erscheinen auch an Feiertagen
- Admin-Einstellungen: Bundesland-Dropdown für Feiertagskalender (alle 16 BL, Voreinstellung Berlin)
- Feiertage: automatisch von openholidaysapi.org geladen, Fallback 2026 je Bundesland
- Edit-View Kalender: Feiertage klickbar (lila hervorgehoben, nicht mehr gesperrt)
- planConfig: bundesland-Feld hinzugefügt (Default: BE)

### v2.5.21 — Anwesenheitsplan: Feiertage editierbar + Bundesland-Dropdown
- Feiertage sind jetzt im Edit-Kalender klickbar (lila Markierung)
- Zeitband: Klick auf Feiertag-Tage öffnet Edit-Dialog
- Admin: Feiertagskalender-Sektion mit Bundesland-Dropdown

### v2.5.20 — Meine Woche: Konzept B — farbiger Datum-Chip
- Status-Dot-Zeile entfernt — keine Dopplung mehr
- Datum-Chip (50px): Wochentag + Datum + Status in einem farbigen Element
- Farb-Codierung: grün=anwesend, amber=Abweichung, blau=Urlaub, rot=Krank, grau=leer/gesch., lila=Feiertag
- Track height:32px, Legende zeigt Chip-Farben

### v2.5.19 — Edit-View: Layout-Fixes für Mobile
- Scroll-Strategie: Parent overflowY:auto, kein separater Scroll-Bereich
- Save-Bar: sticky+marginBottom statt fixed — nie mehr verdeckt
- Kalender-Zellen height:36, gap:2, fontSize:12
- Kacheln Anwesend/Abwesend: padding:14px, Icon 32px, Titel fontSize:13
- paddingBottom 170px → dynamisch calc

### v2.5.18 — Anwesenheitsplan: Edit-View Konzept B umgesetzt
- Neues Edit-View: Kalender oben (Multi-Select), Anwesend/Abwesend Kacheln, Früh/Spät Akkordeons
- Frühschicht/Spätschicht als aufklappbare Akkordeon-Rows mit Checkbox
- Abwesend: Krank/Urlaub/Abwesend als Pill-Chips
- saveEntry: schreibt beide Schichten, löscht Widersprüche
- Alter Mehrere-Tage-Button und showMultiDay-Block entfernt

### v2.5.17 — Fix: Spinner durch überflüssige </div> in renderTeamGrid
- renderTeamGrid hatte 3 überzählige </div>-Tags → stiller JSX-Fehler → Spinner
- div-Tag-Balance-Check als Pflicht-Check eingeführt

### v2.5.16 — Team-Übersicht: F/S entfernt, Kachel-Überschrift, Multi-Tage überschreiben
- Team-Bubbles: F/S-Buchstaben entfernt — Schicht aus Kachel erkennbar
- Kachel-Überschrift: Frühschicht/Spätschicht (fontSize:11, fontWeight:800)
- saveMultiDay: überschreibt bestehende Einträge (inkl. Löschen alter Schichtvarianten)

### v2.5.15 — Team-Übersicht: Coverage-Karte, Du-Legende entfernt
- Coverage-Bereich als Karte mit Schatten
- Coverage-Zellen height:18, fontSize:8, anwesend=grün
- Legende: Du-Eintrag entfernt

### v2.5.14 — Anwesenheitsplan: Abwesend-Kategorie, Team-Band, Stat-Kacheln
- Abwesend: dritte Kategorie Abwesend (löscht Eintrag)
- Team-Übersicht: Du-Band statt Outline-Umrandung
- Stat-Kacheln: fontSize:22, padding:12px

### v2.5.13 — Zeitband: 0–24h, Edit-Button entfernt, Schicht-Linien
- timeToPercent auf 0–24h umgestellt
- Zeitachse: 00/06/12/18/24 mit absolutem Positioning
- Schicht-Start/End-Linien (fruhVon, fruhBis, spatBis)
- Edit-Button entfernt — Track direkt klickbar

### v2.5.12 — Anwesenheitsplan: Spinner-Fix + UI-Verbesserungen
- Fix: renderTeamGrid </div>-Überfluss behoben
- Schraffur entfernt, vertikale Trennlinie Früh/Spät
- Stift-Button dunkelgrau, Mehrere-Tage dunkelgrau/weiß

### v2.5.11 — Anwesenheitsplan: UI-Fixes Einstellungen, Badge, Button
- Ist-Stunden Kachel: kein h-Zeichen mehr
- Admin-Einstellungen: overflow:hidden entfernt, Inputs nicht mehr abgeschnitten
- Zeitbalken: Rahmen entfernt
- Time-Badge: schwarz mit weißer Schrift
- Mehrere-Tage-Button: schwarze Schrift

### v2.5.10 — Anwesenheitsplan: Pastell-Grün für Anwesenheitsbalken, Mehrere-Tage-Button
- Zeitband: Anwesenheitsbalken in zartem Pastell-Grün (Früh #dcfce7, Spät #d1fae5)
- Abweichungs-Schraffur: grüne Diagonalstreifen statt schwarz
- Time-Badge im Balken: grün-pastell statt dunkles Overlay
- Stift-Button: grün wenn Eintrag vorhanden
- Team-Grid: F/S-Zellen in Pastell-Grün
- Mehrere-Tage-Button: über Notiz gezogen, grün hervorgehoben

### v2.5.09 — Anwesenheitsplan: Edit-Formular, Ist-Stunden, Öffnungstage, Schicht-Verknüpfung
- Edit-View: Früh/Spät zeigt direkt Zeitpicker (kein Art-Segment mehr), Abwesend zeigt nur Urlaub/Krank
- Ist-Stunden Kachel: nur eingetragene Stunden, grün ≥ Soll, gelb < Soll, pulsierend-rosa bei 0h
- Anwes.-Tage statt Schichten in Meine Woche Stats
- Admin-Einstellungen: Stationsöffnungstage Multi-Select Mo-So
- Admin-Einstellungen: fruhBis und spatVon verknüpft (Änderung synchronisiert)
- Admin-Einstellungen: Soll-Stunden 0 korrekt speicherbar
- isGeschlossen() nutzt offenTage aus planConfig statt fix Wochenende

### v2.5.08 — Anwesenheitsplan: Pastell-Farben, Admin-Einstellungen, Soll-Woche, Rollen-Lock
- Pastell-Töne für Urlaub (blau) + Krank (rot) in Zeitband, Team-Grid, StatusRing, Detail-Sheet
- Admin-Einstellungsseite: Schichtzeiten, Mindestbesetzung, Soll-Stunden je MA
- Soll-Woche Kachel: Ampel grün/gelb/rot je nach Ist-vs-Soll-Stunden
- Menü-Kachel Anwesenheit: Gäste sehen ausgegraute gesperrte Variante
- Header Anwesenheitsplan: Zahnrad-Button öffnet Admin-Einstellungen (nur Admin)
- Detail-Sheet Button über BottomBar: paddingBottom fix

### v2.5.07 — Anwesenheitsplan: Bugfixes Urlaub/Krank/Abwesend im Zeitband + Team-Übersicht
- Zeitband: Urlaub (blau), Krank (rot), Abwesend (schraffiert) als farbige Vollbalken
- Coverage-Zählung: Krank/Urlaub/Abwesend zählen nicht mehr als anwesend
- Team-Übersicht: Urlaub (U blau), Krank (K rot), Abwesend (A schraffiert) sichtbar
- Legende aktualisiert (beide Tabs: +Urlaub, +Krank, +Abwesend)
- Detail-Sheet: Krank/Urlaub/Abwesend mit farbigen Badges, Zeitanzeige nur bei real
- saveEntry: shift=absent erzwingt status=absent
- openEditFor: findet auch Abwesend-Einträge (shift=absent)
- getMyDayEntry: sucht auch in shift=absent für dayStatus + Zeitband

### v2.5.00 — Anwesenheitsplan v1: Zeitband + Team-Grid + Edit
- Changelog aus Menü in Einstellungen verschoben, Version-Karte klickbar
- Menü-Kachel Changelog entfernt
- Daten-Import-Karte aktiviert

### v2.4.20 — Daten-Import vollständig implementiert
- 4-Step-Wizard: Upload → Validierung → Duplikat-Handling → Ergebnis
- CSV-Parser, Typ-Erkennung, Pflichtfeld-Prüfung, Fehler-CSV
- Dry-Run, Firestore-Batch, Import-Log

### v2.4.19 — Fix: Spinner durch doppelte Const-Deklarationen
- downloadCSV, exportIgelkarten u.a. doppelt deklariert → Runtime SyntaxError behoben

### v2.4.18 — Export: Speicherort + showSaveFilePicker + Fehler-Toast
- Speicherort-Karte: Downloads / Immer fragen (File System Access API)
- HH-MM-SS Timestamp, grüner/roter Toast, 8s auto-dismiss

### v2.4.17 — Export: Bestätigung nach Download
- Grüner Toast unter Info-Banner nach jedem Export

### v2.4.16 — Export-Seite + Komplettbackup
- Export auf eigene Seite, Komplettbackup JSON alle Collections, Import-Platzhalter

### v2.4.15 — Sammelbearbeitung: Behandlung starten + Export
- Behandlungsvorlage auf Auswahl starten, CSV-Export Stammdaten

### v2.4.14 — Sicherheit: AdminSetup Race-Condition
- null statt false bei Timeout/Fehler, Doppelprüfung vor Admin-Anlage

### v2.4.13 — Sammelbearbeitung + Menü-Umstrukturierung
- Batch: Pfleger, Status, Notiz, Löschen via Firestore Batch
- Datenbank → Stammdaten, App-Spec ausgeblendet

### v2.4.12 — Fix: Header als Inline-Komponente → renderHeader()
- Inline-Komponente Header → render-Funktion

### v2.4.11 — Fix: dangerouslySetInnerHTML iconPath
- iconPath-Strings → renderActionIcon() render-Funktion

### v2.4.10 — Sammelbearbeitung (Batch) + Menü
- Neue Komponente BatchBearbeitung
- Menü: Datenbank→Stammdaten, DesignSpec ausgeblendet
- Sammelbearbeitung-Kachel: Admin amber, andere ausgegraut

### v2.4.09 — Option D: Kontrast-Redesign global
- Alle Seiten: #fafaf8 → #e8e5e1, Karten 1.5px #c9c5c1, Shadow 0 8px 28px .18

### v2.4.08 — Fix: Info-Tab Whitescreen
- React.useState in JSX-IIFE → nach Top-Level gehoben

### v2.4.07 — Info-Tab Redesign
- Labels, Nominatim Autocomplete, Telefon-Vorwahl, Pflichtfelder, Segmented Geschlecht

### v2.4.06 — Fix: MedikamentDB Whitescreen
- const filtered fehlte vor return

### v2.4.05 — Fix: MedikamentDB dangerouslySetInnerHTML
- renderInfoBanner nimmt JSX-Children statt HTML-String

### v2.4.04 — Fix: MedikamentDB FlowBanner/InfoBanner
- renderFlowBanner()/renderInfoBanner() Funktionen, showNewModal||editingId

### v2.4.03 — MedikamentDB + DiagnoseDB Redesign
- Karten, Badges, FlowBanner, InfoBanner, Segmented Controls, Vollseiten-Formulare

### v2.4.02 — Datenbank: Reihenfolge Diagnose → Medikament
- Diagnosen an erster Stelle im Hub

### v2.4.01 — TreatmentDB Redesign
- warm-stone Karten, Segmented Control, Sub-Karten, Sticky Save-Bar, Bottom-Sheet Löschen

### v2.4.00 — Rücksprung Igelkarte nach Datenbank
- __igelReturnEdit + __igelReturnKachel, initialKachel-Prop

### v2.3.99 — Datenbank-Button in Diagnose-Tab
- __igelDatenbankFromIgelkarte, showDatenbankHub vor selected

### v2.3.98 — Navigation Origin-System für Datenbank
- datenbankHubOrigin, hubBack() je nach Origin

### v2.3.97 — Igelkarte Header: Stift + Uhr amber
- Stift direkt im Header, Uhr amber eingefärbt

### v2.3.96 — Diagnose-Tab: Workflow + Behandlungs-Links
- Links zur Behandlung, × beendet Behandlung, Datenbank-Button

### v2.3.92 — Profil: Passwort ändern
- Reauthentifizierung, Validierung, grünes/rotes Feedback

### v2.3.91 — Redesign: Profil + DB + Einstellungen + Benutzer
- warm-stone, UserProfile neu, Benutzerverwaltung Karten

### v2.3.90 — Menü: Kachel-Grid
- 2×3 Grid, warm-stone, Admin-Kacheln, To-Do-Badge, DM Mono Version

### v2.3.85 — Igelbestand + Dashboard vereinfacht
- Neue IgelBestand-Komponente, Filter, Donut + Heute-Kacheln

### v2.3.82 — Menü als reines Overlay
- Hintergrundseite bleibt offen, kein pushState im Menü

### v2.3.78 — BottomBar + Menü Redesign
- Swipe-Up öffnet Menü, 5 Buttons, warm stone, detailOrigin

### v2.3.77 — Igel erfassen: Design-Refresh
- DM Sans, warm-stone Inputs, Status-Chips statt Select

### v2.3.76 — Pflegeplan: Filter-Dropdown
- Aufklappbarer Filter mit Summary-Chips, Chevron, Zurücksetzen

### v2.3.64 — Timeline-Settings shared localStorage
- igel_settings in localStorage, shared zwischen Pflegeplan + Igelkarte

### v2.3.58 — Igelkarte: Timeline Design F
- Farb-Segmente statt grauem Hintergrund, 5 Zustände

### v2.3.54 — Toleranz-Logik 6 Zustände
- done-open/done-locked/due/overdue-locked/pending, TL_LOCKED, TL_CAN

### v2.3.37 — QR Quick-View Bottom-Sheet
- Bottom-Sheet nach Scan, live Firestore, Med-Toggle reversibel, Gewicht

### v2.3.17 — Session-Management 8 Stunden
- 8h Session, Verlängerung bei Aktivität, Warnung 30 Min. vor Ablauf

### v2.3.00 — Pflegeplan (Phase 4)
- Neue Vollseite: Tagesplan aller aktiven Behandlungen aller Igel

### v2.2.00 — Behandlung starten

### v2.1.00 — Igelkarte: Kachel-Navigation
- 4 Tabs: Behandlung / Gewicht / Diagnose / Info, Info-Strip

### v2.0.00 — Datenbank-Hub + Behandlungsvorlagen
- Hub mit Live-Zählern, TreatmentDB, Multi-Medikament-Formular

### v1.8.93 — Auge in Passwortfeldern
- Login + Benutzerverwaltung: Passwort anzeigen/verstecken

### v1.8.73 — Service Worker: Network-first
- HTML/JS immer frisch vom Server, nur Icons gecacht

### v1.8.61 — Android Systemtaste Zurück
- popstate-Handler, History-Buffer, stale-closure-freier _backState-Ref

### v1.8.48 — BottomBar Navigation + Edge-to-Edge
- BottomBar mit 4 Buttons, Edge-to-Edge safe-area

### v1.8.40 — Medikation — Vollständige Überarbeitung
- Neue Datenbankstruktur, Wizard, Dosisberechnung, Diagnose-Verknüpfung

### v1.8.29 — RBAC + Rollen
- admin / mitarbeiter / gast, Einladungssystem, Gast-Beschränkungen

---
*Generiert am 28.03.2026*
