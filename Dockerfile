# SPDX-FileCopyrightText: 2024 Weidmueller Interface GmbH & Co. KG <oss@weidmueller.com>
#
# SPDX-License-Identifier: CC0-1.0

FROM node:18

ENV PUPPETEER_EXECUTABLE_PATH /usr/bin/chromium
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    chromium \
    default-jre \
    flatbuffers-compiler \
    git \
    jq \
    reuse \
 && rm -rf /var/lib/apt/lists/*

ARG USERNAME=node
ARG USER_UID=1000
ARG USER_GID=${USER_UID}
ARG HOME=/home/${USERNAME}

RUN test "${USERNAME}" = "node" \
  || ( \
    addgroup -g ${USER_GID} ${USERNAME} \
    && adduser -G ${USERNAME} -D -u ${USER_UID} ${USERNAME} \
  )

RUN chown -R ${USER_UID}:${USER_GID} ${HOME}

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    sudo \
 && rm -rf /var/lib/apt/lists/* \
 && echo ${USERNAME} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${USERNAME} \
 && chmod 0440 /etc/sudoers.d/${USERNAME}

ARG HADOLINT_VERSION=v2.12.0

RUN HADOLINT=/usr/local/bin/hadolint; \
  mkdir -p "$(dirname ${HADOLINT})" \
  && curl -sL -o ${HADOLINT} \
    "https://github.com/hadolint/hadolint/releases/download/${HADOLINT_VERSION}/hadolint-$(uname -s)-$(uname -m)" \
  && chmod 0755 ${HADOLINT}

# NestJS
RUN npm install -g @nestjs/cli \
 && rm -rf ${HOME}/.npm
