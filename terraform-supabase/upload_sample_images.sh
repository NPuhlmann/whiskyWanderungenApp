#!/bin/bash

# Skript zum Hochladen der Sample Images in den Supabase Storage
# Verwendet curl für HTTP-Requests an die Supabase Storage API

set -e  # Beende bei Fehlern

# Farben für bessere Ausgabe
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funktionen
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Prüfe Umgebungsvariablen
if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_SERVICE_ROLE_KEY" ]; then
    log_error "SUPABASE_URL und SUPABASE_SERVICE_ROLE_KEY müssen gesetzt sein"
    exit 1
fi

# Extrahiere Projekt-Referenz aus der URL
PROJECT_REF=$(echo "$SUPABASE_URL" | sed 's|https://||' | sed 's|\.supabase\.co||')

log_info "🚀 Starte Upload der Sample Images für Projekt: $PROJECT_REF"

# Pfad zu den Sample Images
SAMPLE_IMAGES_DIR="$(dirname "$0")/sample_images"

if [ ! -d "$SAMPLE_IMAGES_DIR" ]; then
    log_error "Verzeichnis $SAMPLE_IMAGES_DIR existiert nicht"
    exit 1
fi

# Sammle alle JPEG-Bilder
IMAGE_FILES=($(find "$SAMPLE_IMAGES_DIR" -name "*.jpg" -type f))

if [ ${#IMAGE_FILES[@]} -eq 0 ]; then
    log_error "Keine JPEG-Bilder im sample_images Verzeichnis gefunden"
    exit 1
fi

log_info "📁 Gefunden: ${#IMAGE_FILES[@]} Bilder"

# Liste der Beispielwanderungen
HIKES=(
    "Whisky Trail Highlands"
    "Speyside Whisky Experience"
    "Islay Coastal Adventure"
    "Lowlands Whisky Discovery"
    "Campbeltown Heritage Trail"
    "Glenfiddich Explorer"
    "Talisker Skye Journey"
    "Aberlour Riverside Walk"
)

# Funktion zum Hochladen eines Bildes
upload_image() {
    local image_path="$1"
    local hike_name="$2"
    
    # Erstelle einen eindeutigen Dateinamen
    local filename=$(echo "$hike_name" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')_$(basename "$image_path" .jpg).jpg
    
    log_info "📤 Lade hoch: $(basename "$image_path") -> $filename"
    
    # Lade das Bild hoch
    local response=$(curl -s -w "%{http_code}" \
        -X POST \
        -H "Authorization: Bearer $SUPABASE_SERVICE_ROLE_KEY" \
        -H "Content-Type: image/jpeg" \
        --data-binary "@$image_path" \
        "$SUPABASE_URL/storage/v1/object/hike-images/$filename")
    
    local http_code="${response: -3}"
    local response_body="${response%???}"
    
    if [ "$http_code" -eq 200 ] || [ "$http_code" -eq 201 ]; then
        log_success "Hochgeladen: $filename"
        # Generiere die öffentliche URL
        echo "$SUPABASE_URL/storage/v1/object/public/hike-images/$filename"
    else
        log_error "Fehler beim Hochladen von $filename: HTTP $http_code"
        log_error "Response: $response_body"
        echo ""
    fi
}

# Hauptlogik
log_info "🔄 Verteile Bilder auf Wanderungen..."

# Erstelle temporäre Datei für die Ergebnisse
TEMP_RESULTS=$(mktemp)
trap "rm -f $TEMP_RESULTS" EXIT

# Initialisiere Ergebnisse
for hike in "${HIKES[@]}"; do
    echo "$hike:" >> "$TEMP_RESULTS"
done

# Verteile die Bilder zufällig auf die Wanderungen (3-4 Bilder pro Wanderung)
shuf -e "${IMAGE_FILES[@]}" | while read -r image_path; do
    # Wähle zufällig eine Wanderung
    local hike_index=$((RANDOM % ${#HIKES[@]}))
    local hike_name="${HIKES[$hike_index]}"
    
    # Lade das Bild hoch
    local public_url=$(upload_image "$image_path" "$hike_name")
    
    if [ -n "$public_url" ]; then
        # Füge die URL zu den Ergebnissen hinzu
        sed -i.bak "/^$hike_name:/a\\  - $public_url" "$TEMP_RESULTS"
        rm -f "$TEMP_RESULTS.bak"
    fi
    
    # Kurze Pause zwischen Uploads
    sleep 1
done

# Zeige Zusammenfassung
log_success "📊 Upload abgeschlossen!"
echo ""
log_info "📋 Zusammenfassung der hochgeladenen Bilder:"
echo ""

# Zeige Ergebnisse
while IFS= read -r line; do
    if [[ $line == *":" ]]; then
        hike_name="${line%:}"
        echo -e "${BLUE}🏔️  $hike_name${NC}"
    elif [[ $line == *"-"* ]]; then
        url="${line#*  - }"
        echo -e "  📸 $url"
    fi
done < "$TEMP_RESULTS"

echo ""
log_info "🎯 Nächste Schritte:"
echo "1. Führe das SQL-Skript '10_update_hike_images.sql' aus"
echo "2. Die Bilder werden automatisch mit den Wanderungen verknüpft"

# Speichere Ergebnisse in JSON-Format für das SQL-Skript
log_info "💾 Erstelle JSON-Datei für SQL-Update..."
echo "{" > uploaded_images.json
echo "  \"hikes\": {" >> uploaded_images.json

first_hike=true
while IFS= read -r line; do
    if [[ $line == *":" ]]; then
        hike_name="${line%:}"
        if [ "$first_hike" = true ]; then
            first_hike=false
        else
            echo "," >> uploaded_images.json
        fi
        echo "    \"$hike_name\": [" >> uploaded_images.json
        first_url=true
    elif [[ $line == *"-"* ]]; then
        url="${line#*  - }"
        if [ "$first_url" = true ]; then
            first_url=false
        else
            echo "," >> uploaded_images.json
        fi
        echo "      \"$url\"" >> uploaded_images.json
    fi
done < "$TEMP_RESULTS"

echo "    ]" >> uploaded_images.json
echo "  }" >> uploaded_images.json
echo "}" >> uploaded_images.json

log_success "📄 Ergebnisse gespeichert in: uploaded_images.json"
