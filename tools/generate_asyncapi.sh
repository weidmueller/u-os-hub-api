#!/bin/sh
# This script needs to be executed via npm.

script_path="$(readlink -f ${0})"
script_dir="$(dirname ${script_path})"
project_dir="$(dirname ${script_dir})"

echo "Generate AsyncAPI site"
cd ${project_dir} \
  && asyncapi generate fromTemplate \
    asyncapi.yaml \
    @asyncapi/html-template@${ASYNCAPI_HTML_TEMPLATE_VERSION} \
    -o ${project_dir}/dist/asyncapi \
    --force-write \
    -p sidebarOrganization=byTags \
