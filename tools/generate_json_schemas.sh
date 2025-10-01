#!/bin/sh

# SPDX-FileCopyrightText: 2024 - 2025 Weidmueller Interface GmbH & Co. KG <oss@weidmueller.com>
#
# SPDX-License-Identifier: MIT

script_path="$(readlink -f ${0})"
script_dir="$(dirname ${script_path})"
project_dir="$(dirname ${script_dir})"

echo "Generate JSON schemas"
rm -rf ${project_dir}/jsonschemas/messages
flatc --jsonschema \
  -o ${project_dir}/jsonschemas/messages \
  ${project_dir}/flatbuffers/messages/*

for f in ${project_dir}/jsonschemas/messages/*.schema.json; do
  [ -f "${f}" ] || continue
  echo "Optimize $f"
  cat ${f} \
    | jq '."$ref"[2:] as $ref
      | del(."$ref")
      | . + getpath($ref / "/")
      | delpaths([$ref / "/"])' > ${f}.tmp \
    && mv ${f}.tmp ${f}
done
