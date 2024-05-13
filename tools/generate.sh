#!/bin/sh

# SPDX-FileCopyrightText: 2024 2024 Weidmueller Interface GmbH & Co. KG <oss@weidmueller.com>
#
# SPDX-License-Identifier: MIT

ASYNCAPI_HTML_TEMPLATE_VERSION=0.28.4

script_path="$(readlink -f ${0})"
script_dir="$(dirname ${script_path})"

${script_dir}/generate_json_schemas.sh

${script_dir}/validate_asyncapi.sh

${script_dir}/generate_asyncapi.sh

${script_dir}/validate_openapi.sh

${script_dir}/generate_swagger_ui.sh
