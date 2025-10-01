#!/bin/bash

# SPDX-FileCopyrightText: 2025 Weidmueller Interface GmbH & Co. KG <oss@weidmueller.com>
#
# SPDX-License-Identifier: MIT

set -euo pipefail
set -x

if [ "${GITHUB_ACTIONS:-}" = "true" ]; then
  echo "Skipping postCreateCommand in GitHub Actions CI."
  exit 0
fi

npm ci --ignore-optional
npm run build
