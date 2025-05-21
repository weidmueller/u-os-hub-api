#!/bin/bash

set -euo pipefail
set -x

if [ "${GITHUB_ACTIONS:-}" = "true" ]; then
  echo "Skipping postCreateCommand in GitHub Actions CI."
  exit 0
fi

npm ci --ignore-optional
npm run build
