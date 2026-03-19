# SPDX-FileCopyrightText: 2025 Weidmueller Interface GmbH & Co. KG <oss@weidmueller.com>
#
# SPDX-License-Identifier: MIT

set -euo pipefail

script_path="$(readlink -f ${0})"
script_dir="$(dirname ${script_path})"
project_dir="$(dirname ${script_dir})"

copyright="Weidmueller Interface GmbH & Co. KG <oss@weidmueller.com>"

set -x

# Only check modified files, ignore deleted files and files with less than 4 lines changed
files=$(git diff --diff-filter=AM -w --numstat origin/main | awk '{if ($1+$2 > 3) print $3}')

reuse annotate --license MIT --copyright "$copyright" --merge-copyrights --recursive --skip-unrecognised $files

unrecognizedFiles=$(echo "$files" | grep '\.fbs$')

if [ -n "$unrecognizedFiles" ]; then
    reuse annotate --copyright="$copyright" --license=MIT --style=c --merge-copyrights $unrecognizedFiles
fi
