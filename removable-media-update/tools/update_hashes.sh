#!/bin/bash
set -euo pipefail

# This script updates the SHA256 hashes in the recipe.json file for the removable-media-update project.

# Usage: ./update_hashes.sh <path_to_recipe.json> [gpg_key_fingerprint]
if [ $# -eq 0 ]; then
    echo "Error: No path to recipe.json provided."
    echo "Usage: $0 <recipe.json> [gpg_key_fingerprint]"
    exit 1
fi

RECIPE_FILE="$1"
GPG_FINGERPRINT="${2:-}"
DIR=$(dirname "$RECIPE_FILE")
echo "Recipe file: $RECIPE_FILE"
echo "Updating hashes for removable-media-update"

# Get the number of steps in the recipe.json file
count=$(jq '.steps | length' "$RECIPE_FILE")

# Use an associative array to track seen paths and detect duplicates
declare -A path_steps

# Loop through each step, calculate the SHA256 hash of the file at the specified path, and update the recipe.json file
for i in $(seq 0 $((count - 1))); do
    path=$(jq -r ".steps[$i].path" "$RECIPE_FILE")

    # Track which steps use this path
    if [[ -v "path_steps[$path]" ]]; then
        path_steps[$path]="${path_steps[$path]}, $((i + 1))"
    else
        path_steps[$path]="$((i + 1))"
    fi

    # Calculate the SHA256 hash of the file at the specified path
    hash=$(sha256sum "$DIR/$path" | awk '{print $1}')
    echo "Step $((i + 1)): $path -> $hash"

    # Update the recipe.json file with the new hash
    updated=$(jq ".steps[$i].sha256 = \"$hash\"" "$RECIPE_FILE")
    echo "$updated" > "$RECIPE_FILE"
done

# Print warnings for duplicate paths
for path in "${!path_steps[@]}"; do
    if [[ "${path_steps[$path]}" == *","* ]]; then
        echo "Warning: '$path' is used in multiple steps (Steps ${path_steps[$path]})."
    fi
done

# Sign the recipe.json file if a GPG key fingerprint is provided
if [ -n "$GPG_FINGERPRINT" ]; then
    echo "Signing recipe with GPG key: $GPG_FINGERPRINT"
    gpg -u "$GPG_FINGERPRINT" -b "$RECIPE_FILE"
    echo "Signature created: ${RECIPE_FILE}.sig"
else
    echo "No GPG key fingerprint provided. Skipping signing."
fi

echo "Done."