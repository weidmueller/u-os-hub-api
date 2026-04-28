#!/bin/bash
set -euo pipefail

# This script validates, updates, and signs a recipe.json for the removable-media-update project.
#
# Workflow:
#   1. Schema validation: Checks the recipe.json against the referenced JSON schema.
#   2. Recipe validation: Checks for duplicate entries, existence of referenced files, etc.
#   3. SHA256 update: Calculates and updates the SHA256 hashes of all referenced files.
#   4. (Optional) GPG signing: Signs the recipe.json with the given GPG key (passphrase supported).
#
# Usage:
#   ./recipe_tool.sh <path_to_recipe.json> [gpg_key_fingerprint]
#
#   <path_to_recipe.json>   Path to the recipe.json
#   [gpg_key_fingerprint]   Optional: GPG key for signing (must be in the keyring)
#
# Note: The script should be in the same directory as validate_recipe.py or the path must be adjusted.


if [ $# -eq 0 ]; then
	echo "Error: No path to recipe.json provided."
	echo "Usage: $0 <recipe.json> [gpg_key_fingerprint]"
	exit 1
fi

RECIPE_FILE="$1"
GPG_FINGERPRINT="${2:-}"
DIR=$(dirname "$RECIPE_FILE")
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
echo "Recipe file: $RECIPE_FILE"

# Validate recipe.json against its $schema
if ! python3 "$SCRIPT_DIR/validate_recipe.py" "$RECIPE_FILE"; then
	echo "Error: Recipe schema validation failed. Aborting."
	exit 1
fi

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

	# Check if the file exists and is a regular file
	if [[ ! -f "$DIR/$path" ]]; then
		echo "Warning: Step $((i + 1)): File not found or not a regular file: $DIR/$path. Skipping."
		continue
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
	step_list="${path_steps[$path]}"
	# If the step list contains a comma, the path is used in multiple steps
	if [[ "$step_list" == *,* ]]; then
		echo "Warning: '$path' is used in multiple steps (Steps $step_list)."
	fi
done

# Sign the recipe.json file if a GPG key fingerprint is provided
if [ -n "$GPG_FINGERPRINT" ]; then
	echo "Signing recipe with GPG key: $GPG_FINGERPRINT"

	# Remove any existing signature file so GPG does not fail on a second run.
	rm -f "${RECIPE_FILE}.sig"

	gpg --pinentry-mode loopback \
		--default-key "$GPG_FINGERPRINT" --detach-sign "$RECIPE_FILE"
	echo "Signature created: ${RECIPE_FILE}.sig"
else
	echo "No GPG key fingerprint provided. Skipping signing."
fi

echo "Done. Updated hashes in $RECIPE_FILE"
