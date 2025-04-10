#!/bin/sh

# SPDX-FileCopyrightText: 2024 Weidmueller Interface GmbH & Co. KG <oss@weidmueller.com>
#
# SPDX-License-Identifier: CC0-1.0

echo "Provide UI"

echo "Copy OpenAPI site und yaml file"
(rm -rf dist/openapi \
  && mkdir -p dist/openapi \
  && pathSwaggerDist=$(node tools/swagger.js) \
  && cp $pathSwaggerDist/* dist/openapi \
  && cp variable-http-openapi.yaml dist/openapi \
)

# It is currently not possible to customize the URL with a simple command using the swagger-ui-dist-package. 
# Therefore, the workaround with the replacement is often used.
# https://github.com/swagger-api/swagger-ui/issues/9237
echo "Replace url"
sed -i 's#https://petstore.swagger.io/v2/swagger.json#variable-http-openapi.yaml#g' dist/openapi/swagger-initializer.js

echo "Replace Layout"
sed -i 's#StandaloneLayout#BaseLayout#g' dist/openapi/swagger-initializer.js

echo "Replace Title"
sed -i 's#Swagger UI#u-OS HTTP API#g' dist/openapi/index.html
