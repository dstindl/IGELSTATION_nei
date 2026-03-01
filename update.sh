#!/bin/bash
# update.sh — Synchronisiert, kopiert Dateien und deployt

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

DOWNLOAD_DIR="$HOME/storage/downloads/igelstation"
REPO_DIR="$HOME/igelstation"

cd "$REPO_DIR" || exit 1

# 1. Erst mit GitHub synchronisieren
echo ""
echo "Synchronisiere mit GitHub..."
git pull --rebase
echo ""

# 2. Dann Dateien aus Download kopieren
echo "Kopiere Dateien aus Download/igelstation/..."

if [ ! -d "$DOWNLOAD_DIR" ]; then
  echo -e "${RED}FEHLER: Ordner Download/igelstation/ nicht gefunden.${NC}"
  echo "Bitte igelstation.zip in Download/ entpacken."
  exit 1
fi

cp "$DOWNLOAD_DIR"/*.html "$REPO_DIR/" 2>/dev/null
cp "$DOWNLOAD_DIR"/*.json "$REPO_DIR/" 2>/dev/null
cp "$DOWNLOAD_DIR"/*.js "$REPO_DIR/" 2>/dev/null
cp "$DOWNLOAD_DIR"/*.png "$REPO_DIR/" 2>/dev/null
cp "$DOWNLOAD_DIR"/*.md "$REPO_DIR/" 2>/dev/null

echo -e "${GREEN}Dateien kopiert.${NC}"
echo ""

# 3. Deployen
./deploy.sh
