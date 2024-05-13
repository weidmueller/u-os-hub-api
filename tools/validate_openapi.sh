#!/bin/sh

# SPDX-FileCopyrightText: 2024 2024 Weidmueller Interface GmbH & Co. KG <oss@weidmueller.com>
#
# SPDX-License-Identifier: MIT

# This script needs to be executed via npm.

script_path="$(readlink -f ${0})"
script_dir="$(dirname ${script_path})"
project_dir="$(dirname ${script_dir})"

echo "Validate openapi.yaml"
cd ${project_dir} \
  && spectral lint --fail-severity=warn openapi.yaml --ruleset ./tools/spectral.json \
  || exit 1
