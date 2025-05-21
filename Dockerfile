# SPDX-FileCopyrightText: 2024 Weidmueller Interface GmbH & Co. KG <oss@weidmueller.com>
#
# SPDX-License-Identifier: CC0-1.0

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

ARG HADOLINT_VERSION=v2.12.0

RUN HADOLINT=/usr/local/bin/hadolint; \
  mkdir -p "$(dirname ${HADOLINT})" \
  && curl -sL -o ${HADOLINT} \
  "https://github.com/hadolint/hadolint/releases/download/${HADOLINT_VERSION}/hadolint-$(uname -s)-$(uname -m)" \
  && chmod 0755 ${HADOLINT}

# Install oasdiff
RUN curl -fsSL https://raw.githubusercontent.com/oasdiff/oasdiff/main/install.sh | sh
