# SPDX-FileCopyrightText: 2025 Weidmueller Interface GmbH & Co. KG <oss@weidmueller.com>
#
# SPDX-License-Identifier: MIT

set -euo pipefail

script_path="$(readlink -f ${0})"
script_dir="$(dirname ${script_path})"
project_dir="$(dirname ${script_dir})"

current_year=$(date +'%Y')
copyright="Weidmueller Interface GmbH & Co. KG <oss@weidmueller.com>"

set -x

reuse annotate --license MIT --copyright "$copyright" --year $current_year --merge-copyrights --recursive --skip-unrecognised "$project_dir"

# # annotate fbs files separately with explicit C style
reuse annotate --license MIT --copyright "$copyright" --year $current_year --merge-copyrights --recursive --style c "$project_dir/flatbuffers"