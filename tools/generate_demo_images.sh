#!/bin/zsh

# Generates the image assets referenced by the demo content migration.
set -euo pipefail

readonly model='gemini-3.1-flash-image'
readonly output_dir="${1:-/var/folders/sw/t7jz0qls2_x46yk8vm64ltsc0000gn/T/opencode/whisky-hikes-demo-images}"
readonly api_key="$(security find-generic-password -a "$USER" -s "whisky-hikes-google-ai" -w)"

mkdir -p "$output_dir"

generate_image() {
  local filename="$1"
  local prompt="$2"
  local response_file

  response_file="$(mktemp)"

  curl --fail --silent --show-error \
    --request POST \
    --header "x-goog-api-key: $api_key" \
    --header 'Content-Type: application/json' \
    --data "$(jq -n \
      --arg model "$model" \
      --arg prompt "$prompt" \
      '{
        model: $model,
        input: [{type: "text", text: $prompt}],
        response_format: {
          type: "image",
          mime_type: "image/jpeg",
          aspect_ratio: "16:9",
          image_size: "1K"
        }
      }')" \
    'https://generativelanguage.googleapis.com/v1beta/interactions' \
    > "$response_file"

  jq -er '
    [.steps[].content[]? | select(.type == "image") | .data] | last
  ' "$response_file" | base64 --decode > "$output_dir/$filename"
  rm -f "$response_file"
}

generate_image \
  'schwarzwald-fasspfad-01.jpg' \
  'Photorealistic editorial travel photograph of a hiking trail through the Black Forest near Baden-Baden in early autumn, tall fir trees, warm morning sunlight, a subtle old oak whisky barrel beside the path, no people, no labels, no logos, wide landscape composition.'
generate_image \
  'schwarzwald-fasspfad-02.jpg' \
  'Photorealistic travel photograph of a misty Black Forest valley with a clear hiking path, mossy granite, amber autumn leaves and a distant traditional German timber-frame shelter, no people, no text, no logos, wide landscape composition.'
generate_image \
  'schwarzwald-fasspfad-03.jpg' \
  'Photorealistic close travel photograph of a wooden forest rest bench in the Black Forest, a closed unbranded amber whisky sample bottle and small tasting glass on the bench, mountains and firs softly blurred behind, no people, no text, no logos, wide landscape composition.'

generate_image \
  'mosel-schieferweg-01.jpg' \
  'Photorealistic editorial travel photograph of a sunlit hiking trail above the Moselle river in Germany, steep slate vineyards, a sweeping river bend and a small medieval village far below, late afternoon golden light, no people, no text, no logos, wide landscape composition.'
generate_image \
  'mosel-schieferweg-02.jpg' \
  'Photorealistic travel photograph of a narrow slate path through Moselle vineyards, dry stone walls, deep blue river glimpsed through vines, crisp autumn day, no people, no text, no logos, wide landscape composition.'
generate_image \
  'mosel-schieferweg-03.jpg' \
  'Photorealistic close travel photograph of a weathered vineyard picnic table overlooking the Moselle valley, an unbranded amber whisky sample bottle and tulip tasting glass, no people, no text, no logos, wide landscape composition.'

generate_image \
  'harz-hexenstieg-01.jpg' \
  'Photorealistic dramatic travel photograph of a rocky hiking trail in the Harz mountains near the Brocken, wind-bent spruce trees, granite boulders, low clouds and atmospheric cool light, no people, no text, no logos, wide landscape composition.'
generate_image \
  'harz-hexenstieg-02.jpg' \
  'Photorealistic travel photograph of a wooden boardwalk crossing a wild Harz moor, golden grass, dark pool water and rolling mist, hiking adventure atmosphere, no people, no text, no logos, wide landscape composition.'
generate_image \
  'harz-hexenstieg-03.jpg' \
  'Photorealistic travel photograph of a historic stone shelter on a high Harz hiking route at blue hour, warm light in a small window, wet granite and clouds, no people, no text, no logos, wide landscape composition.'

generate_image \
  'allgaeu-alpenglut-01.jpg' \
  'Photorealistic editorial travel photograph of an alpine hiking path in the Allgaeu Alps, lush green meadows, dramatic limestone peaks and an alpine hut in warm evening sun, no people, no text, no logos, wide landscape composition.'
generate_image \
  'allgaeu-alpenglut-02.jpg' \
  'Photorealistic travel photograph of a clear alpine lake in the Allgaeu, a rocky hiking trail leading beside turquoise water toward high limestone mountains, bright summer morning, no people, no text, no logos, wide landscape composition.'
generate_image \
  'allgaeu-alpenglut-03.jpg' \
  'Photorealistic travel photograph from an Allgaeu mountain summit, layered alpine ridges in soft sunset light, a wooden trail marker in foreground, no people, no text, no logos, wide landscape composition.'

generate_image \
  'ruegen-kuestenmalz-01.jpg' \
  'Photorealistic editorial travel photograph of a coastal hiking path on Rugen island, tall white chalk cliffs above the Baltic Sea, beech forest and bright coastal sky, no people, no text, no logos, wide landscape composition.'
generate_image \
  'ruegen-kuestenmalz-02.jpg' \
  'Photorealistic travel photograph of a tranquil Baltic beach below white chalk cliffs on Rugen, driftwood, gentle waves and a footpath entering a beech forest, no people, no text, no logos, wide landscape composition.'
generate_image \
  'ruegen-kuestenmalz-03.jpg' \
  'Photorealistic travel photograph of a coastal forest viewpoint on Rugen overlooking the Baltic Sea at sunrise, soft fog, ancient beech trees, no people, no text, no logos, wide landscape composition.'

print "Generated 15 images in $output_dir"
