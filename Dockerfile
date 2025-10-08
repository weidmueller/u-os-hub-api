# SPDX-FileCopyrightText: 2024 - 2025 Weidmueller Interface GmbH & Co. KG <oss@weidmueller.com>
#
# SPDX-License-Identifier: MIT

FROM mcr.microsoft.com/devcontainers/typescript-node:18

ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  chromium \
  default-jre \
  flatbuffers-compiler \
  git \
  jq \
  reuse \
  sudo \
  && rm -rf /var/lib/apt/lists/*

# Install oasdiff
RUN curl -fsSL https://raw.githubusercontent.com/oasdiff/oasdiff/main/install.sh | sh

USER node

# Install prek for pre commit hooks
RUN curl --proto '=https' --tlsv1.2 -LsSf https://github.com/j178/prek/releases/download/v0.2.3/prek-installer.sh | sh
