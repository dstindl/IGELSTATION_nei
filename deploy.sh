#!/bin/bash
# ============================================================
# deploy.sh — Igelpflegestation Pro
# Automatisches Deploy auf GitHub Pages via Termux (Android)
# Nutzung: cd ~/storage/downloads/igelstation && ./deploy.sh
# ============================================================

# Farben fuer Terminal-Ausgabe
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo ""
echo "============================================"
echo "  Igelpflegestation Pro — Deploy Script"
echo "============================================"
echo ""

# In das Repo-Verzeichnis wechseln
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# Prüfen ob .git vorhanden
if [ ! -d ".git" ]; then
  echo -e "${RED}FEHLER: Kein Git-Repository gefunden.${NC}"
  echo "Stelle sicher dass du im richtigen Ordner bist."
  echo "Aktueller Ordner: $SCRIPT_DIR"
  exit 1
fi

# Prüfen ob index.html vorhanden
if [ ! -f "index.html" ]; then
  echo -e "${RED}FEHLER: index.html nicht gefunden.${NC}"
  echo "Bitte zuerst die Dateien aus dem ZIP in diesen Ordner kopieren."
  exit 1
fi

# Version aus index.html auslesen
VERSION=$(grep -o 'v[0-9]\+\.[0-9]\+\.[0-9]\+[^ ]*' index.html | head -1)
echo -e "Erkannte Version: ${GREEN}$VERSION${NC}"
echo ""

# Git Status anzeigen
echo "Geaenderte Dateien:"
git status --short
echo ""

# Alle Aenderungen stagen
git add -A

# Prüfen ob es Aenderungen gibt
if git diff --cached --quiet; then
  echo -e "${YELLOW}Keine Aenderungen gefunden. Deploy nicht noetig.${NC}"
  exit 0
fi

# Commit mit Versionsnummer
COMMIT_MSG="Deploy $VERSION - $(date '+%d.%m.%Y %H:%M')"
git commit -m "$COMMIT_MSG"

if [ $? -ne 0 ]; then
  echo -e "${RED}FEHLER: Commit fehlgeschlagen.${NC}"
  exit 1
fi

echo ""
echo "Pushing zu GitHub..."
git push origin main

if [ $? -eq 0 ]; then
  echo ""
  echo -e "${GREEN}============================================${NC}"
  echo -e "${GREEN}  Erfolgreich deployed!${NC}"
  echo -e "${GREEN}  $COMMIT_MSG${NC}"
  echo -e "${GREEN}============================================${NC}"
  echo ""
  echo "GitHub Pages aktualisiert sich in ~30 Sekunden."
  echo "URL: https://dstindl.github.io/IGELSTATION_nei/"
  echo ""
else
  echo -e "${RED}FEHLER: Push fehlgeschlagen.${NC}"
  echo "Token abgelaufen? Neues Token erstellen und Repo neu klonen."
  exit 1
fi
