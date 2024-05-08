#!/bin/sh
# This script needs to be executed via npm.

script_path="$(readlink -f ${0})"
script_dir="$(dirname ${script_path})"
project_dir="$(dirname ${script_dir})"

echo "Validate openapi.yaml"
cd ${project_dir} \
  && openapi-generator-cli validate --fail-severity=warn -i openapi.yaml \
  || exit 1
