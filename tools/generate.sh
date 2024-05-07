#!/bin/sh

ASYNCAPI_HTML_TEMPLATE_VERSION=0.28.4

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
echo ""

echo "Validate asyncapi.yaml"
(cd ${project_dir} \
  && asyncapi validate --fail-severity=warn asyncapi.yaml \
  || exit 1
)

echo "Generate AsyncAPI site"
(cd ${project_dir} \
  && asyncapi generate fromTemplate \
    asyncapi.yaml \
    @asyncapi/html-template@${ASYNCAPI_HTML_TEMPLATE_VERSION} \
    -o ${project_dir}/dist/asyncapi \
    --force-write \
    -p sidebarOrganization=byTags \
)

echo "Validate openapi.yaml"
(cd ${project_dir} \
  && openapi-generator-cli validate --fail-severity=warn -i openapi.yaml \
  || exit 1
)
echo ""

echo "Generate UI"
./tools/generateSwaggerUi.sh
