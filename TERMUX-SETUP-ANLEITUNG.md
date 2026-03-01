# Termux Deploy-Setup — Igelpflegestation Pro
## Einmalige Einrichtung (~5 Minuten)

---

## SCHRITT 1 — Termux installieren

- **Termux** aus dem **F-Droid Store** installieren (NICHT aus dem Play Store — die Play-Version ist veraltet!)
- F-Droid: https://f-droid.org
- Termux in F-Droid suchen und installieren

---

## SCHRITT 2 — Termux einrichten (einmalig)

Termux öffnen, diese Befehle nacheinander eingeben:

```
# Pakete aktualisieren
pkg update && pkg upgrade -y

# Git installieren
pkg install git -y

# Speicherzugriff erlauben (damit Termux auf Downloads zugreifen kann)
termux-setup-storage
```

Bei `termux-setup-storage` erscheint ein Android-Dialog → "Erlauben" tippen.

---

## SCHRITT 3 — GitHub Token erstellen

Termux braucht ein Token um auf GitHub schreiben zu dürfen:

1. GitHub.com öffnen → Einloggen
2. Oben rechts: Profilbild → **Settings**
3. Ganz unten links: **Developer settings**
4. **Personal access tokens** → **Tokens (classic)**
5. **Generate new token (classic)**
6. Note: `Igelpflege Deploy`
7. Expiration: **No expiration** (oder 1 Jahr)
8. Haken setzen bei: **repo** (alle Unteroptionen)
9. **Generate token** → Token kopieren und sicher aufbewahren!

---

## SCHRITT 4 — Repo klonen

In Termux:

```
# In den Download-Ordner wechseln
cd ~/storage/download

# Repo klonen — TOKEN und USERNAME einsetzen!
git clone https://DEIN_TOKEN@github.com/dstindl/IGELSTATION_nei.git igelstation
```

Beispiel:
```
git clone https://ghp_xxxxxxxxxxxxx@github.com/dstindl/IGELSTATION_nei.git igelstation
```

---

## SCHRITT 5 — Git konfigurieren

```
cd ~/storage/download/igelstation
git config user.name "dstindl"
git config user.email "denis.stindl@gmail.com"
```

---

## SCHRITT 6 — Deploy-Script einrichten

Das Script `deploy.sh` aus dem ZIP in den `igelstation`-Ordner kopieren.
Dann ausführbar machen:

```
chmod +x ~/storage/download/igelstation/deploy.sh
```

---

## AB JETZT — JEDES UPDATE NUR NOCH SO:

1. ZIP von Claude herunterladen
2. ZIP entpacken (Dateimanager → Entpacken)
3. Alle Dateien aus dem ZIP in den Ordner `Downloads/igelstation/` kopieren
4. Termux öffnen und eintippen:

```
cd ~/storage/download/igelstation && ./deploy.sh
```

**Fertig.** GitHub wird automatisch aktualisiert, GitHub Pages deployt innerhalb ~30 Sekunden.

---

## TROUBLESHOOTING

| Problem | Lösung |
|---|---|
| `Permission denied` beim deploy.sh | `chmod +x deploy.sh` nochmal ausführen |
| `remote: Invalid username or password` | Token abgelaufen → neues Token erstellen (Schritt 3) |
| `git: command not found` | `pkg install git -y` nochmal ausführen |
| Kein Zugriff auf Downloads | `termux-setup-storage` nochmal ausführen |
