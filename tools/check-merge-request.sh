#!/bin/bash

# SPDX-FileCopyrightText: 2025 Weidmueller Interface GmbH & Co. KG <oss@weidmueller.com>
#
# SPDX-License-Identifier: MIT

set -euo pipefail
set -x

script_path="$(readlink -f ${0})"
script_dir="$(dirname ${script_path})"
project_dir="$(dirname ${script_dir})"

# Check copyright headers and license files
reuse lint

# Print changelog of openapi spec changes
git show origin/main:variable-http-openapi.yaml | oasdiff changelog - ${project_dir}/variable-http-openapi.yaml

# Check if breaking changes to the openapi spec are being introduced
git show origin/main:variable-http-openapi.yaml | oasdiff breaking - ${project_dir}/variable-http-openapi.yaml -o WARN

#Install dependencies
npm ci

#Audit dependencies
npm audit --audit-level=high --omit=dev

#Run build and linters
npm run build
