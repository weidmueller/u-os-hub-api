#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2026 Weidmueller Interface GmbH & Co. KG <oss@weidmueller.com>
#
# SPDX-License-Identifier: MIT

import json
import os
import sys
from urllib.request import urlopen
from urllib.error import URLError, HTTPError
from jsonschema import Draft202012Validator


def format_path(error):
    return " -> ".join(str(p) for p in error.path) or "root"


def print_error(error, index):
    path = format_path(error)

    # Give normal Error message if it's not a oneOf error (which is the most common case)
    if error.validator != "oneOf":
        print(f"Error {index} at [{path}]: {error.message}", file=sys.stderr)
        return

    # oneOf: simply take the first meaningful sub-error
    for sub in error.context:
        if sub.validator in ("required", "type", "additionalProperties", "const", "enum"):
            msg = sub.message

            # required: display the missing field in a cleaner way
            if sub.validator == "required":
                field = msg.split("'")[1]
                msg = f"Missing field: {field}"

            # const/enum: if the error is about the "type" field, it's likely that the step type is invalid (not TASK or SWU)
            if sub.validator in ("const", "enum") and "type" in sub.schema_path:
                msg = "Invalid step type"

            print(f"Error {index} at [{path}]: {msg}", file=sys.stderr)
            return

    # Fallback
    print(f"Error {index} at [{path}]: {error.message}", file=sys.stderr)


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 validate_recipe.py <recipe.json>", file=sys.stderr)
        sys.exit(1)

    recipe_path = sys.argv[1]

    # Load the recipe file
    try:
        with open(os.path.abspath(recipe_path), "r", encoding="utf-8") as f:
            recipe = json.load(f)
    except Exception as e:
        print(f"Error reading recipe: {e}", file=sys.stderr)
        sys.exit(1)

    schema_url = recipe.get("$schema")
    if not schema_url:
        print("Error: No $schema field found.", file=sys.stderr)
        sys.exit(1)

    # Load the schema
    try:
        with urlopen(schema_url) as response:
            schema = json.loads(response.read().decode("utf-8"))
    except (HTTPError, URLError) as e:
        print(f"Error loading schema: {e}", file=sys.stderr)
        sys.exit(1)

    # Validate the recipe
    validator = Draft202012Validator(schema)
    errors = sorted(validator.iter_errors(recipe), key=lambda e: e.path)

    if not errors:
        print("Recipe schema validation passed.")
        sys.exit(0)

    print(f"Recipe validation failed. Found {len(errors)} error(s):\n", file=sys.stderr)

    for i, error in enumerate(errors, 1):
        print_error(error, i)

    sys.exit(1)


if __name__ == "__main__":
    main()