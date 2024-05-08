#!/bin/sh
# This script needs to be executed via npm.

script_path="$(readlink -f ${0})"
script_dir="$(dirname ${script_path})"
project_dir="$(dirname ${script_dir})"

echo "Validate asyncapi.yaml"
cd ${project_dir} \
  && asyncapi validate --fail-severity=warn asyncapi.yaml \
  || exit 1
