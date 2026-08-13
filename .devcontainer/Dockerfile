# SPDX-FileCopyrightText: 2024 - 2025 Weidmueller Interface GmbH & Co. KG <oss@weidmueller.com>
#
# SPDX-License-Identifier: MIT

ARG VARIANT="trixie"
FROM mcr.microsoft.com/vscode/devcontainers/rust:2.0.6-${VARIANT}

ARG BASE_IMAGE_USERNAME="vscode"

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    default-jre \
    flatbuffers-compiler \
    git \
    jq \
    reuse \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Install oasdiff
RUN curl -fsSL https://raw.githubusercontent.com/oasdiff/oasdiff/main/install.sh | sh

# Download and install just
RUN curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --tag 1.58.0 --to "/usr/local/cargo/bin"

# Download and install just-lsp
RUN <<-EOT
    VER="0.6.2"
    DIR="/usr/local/cargo/bin"
    mkdir -p $DIR
    curl -L -o $DIR/archive.tar.gz https://github.com/terror/just-lsp/releases/download/${VER}/just-lsp-${VER}-x86_64-unknown-linux-musl.tar.gz
    tar -xzvf $DIR/archive.tar.gz --strip-components=1 -C $DIR
    rm $DIR/archive.tar.gz
EOT

RUN <<-EOT
    VER="6.15.0"
    curl -fsSL https://raw.githubusercontent.com/stoplightio/spectral/refs/tags/v${VER}/scripts/install.sh | sh -s -- ${VER}
EOT

# Download and install openapi generator
RUN <<-EOT
    DIR="/usr/local/bin"
    VER="7.23.0"
    wget https://repo1.maven.org/maven2/org/openapitools/openapi-generator-cli/$VER/openapi-generator-cli-$VER.jar -O $DIR/openapi-generator-cli.jar
EOT

USER ${BASE_IMAGE_USERNAME}

# Install prek for pre commit hooks
RUN curl --proto '=https' --tlsv1.2 -LsSf https://github.com/j178/prek/releases/download/v0.4.13/prek-installer.sh | sh

RUN curl -fsSL https://bun.com/install | bash -s "bun-v1.3.14"
