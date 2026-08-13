# SPDX-FileCopyrightText: 2026 Weidmueller Interface GmbH & Co. KG <oss@weidmueller.com>
#
# SPDX-License-Identifier: MIT

mod openapi
mod variable-nats-api

build: variable-nats-api::build

check: openapi::check variable-nats-api::check
    reuse lint

gen-copyright-headers:
    #!/usr/bin/env bash
    set -euo pipefail

    readonly copyright='Weidmueller Interface GmbH & Co. KG <oss@weidmueller.com>'

    mapfile -t files < <(
        git diff --diff-filter=AM -w --numstat origin/main |
            awk '$1 + $2 > 3 { print $3 }'
    )

    if ((${#files[@]} == 0)); then
        exit 0
    fi

    reuse annotate \
        --license MIT \
        --copyright "$copyright" \
        --merge-copyrights \
        --recursive \
        --skip-unrecognised \
        "${files[@]}"

    flatbuffer_files=()
    for file in "${files[@]}"; do
        if [[ "$file" == *.fbs ]]; then
            flatbuffer_files+=("$file")
        fi
    done

    if ((${#flatbuffer_files[@]} > 0)); then
        reuse annotate \
            --license MIT \
            --copyright "$copyright" \
            --style c \
            --merge-copyrights \
            "${flatbuffer_files[@]}"
    fi
