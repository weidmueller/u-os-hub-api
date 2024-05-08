#!/bin/sh

echo "Provide UI"

echo "Copy OpenAPI site und yaml file"
(rm -rf dist/openapi \
  && mkdir -p dist/openapi \
  && pathSwaggerDist=$(node tools/swagger.js) \
  && cp $pathSwaggerDist/* dist/openapi \
  && cp openapi.yaml dist/openapi \
)

# It is currently not possible to customize the URL with a simple command using the swagger-ui-dist-package. 
# Therefore, the workaround with the replacement is often used.
# https://github.com/swagger-api/swagger-ui/issues/9237
echo "Replace url"
sed -i 's#https://petstore.swagger.io/v2/swagger.json#openapi.yaml#g' dist/openapi/swagger-initializer.js