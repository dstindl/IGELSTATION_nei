#!/bin/bash
# update.sh — Kopiert Dateien aus Download/igelstation/ und deployt

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

DOWNLOAD_DIR="$HOME/storage/downloads/igelstation"
REPO_DIR="$HOME/igelstation"

echo ""
echo "Kopiere Dateien aus Download/igelstation/..."

if [ ! -d "$DOWNLOAD_DIR" ]; then
  echo -e "${RED}FEHLER: Ordner Download/igelstation/ nicht gefunden.${NC}"
  echo "Bitte ZIP als 'igelstation.zip' in Download/ entpacken."
  exit 1
fi

cp "$DOWNLOAD_DIR"/*.html "$REPO_DIR/" 2>/dev/null
cp "$DOWNLOAD_DIR"/*.json "$REPO_DIR/" 2>/dev/null
cp "$DOWNLOAD_DIR"/*.js "$REPO_DIR/" 2>/dev/null
cp "$DOWNLOAD_DIR"/*.png "$REPO_DIR/" 2>/dev/null
cp "$DOWNLOAD_DIR"/*.md "$REPO_DIR/" 2>/dev/null

echo -e "${GREEN}Dateien kopiert.${NC}"
echo ""

cd "$REPO_DIR" && ./deploy.sh
