FROM node:18 AS builder

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    flatbuffers-compiler \
    git \
 && rm -rf /var/lib/apt/lists/*

FROM builder AS devcontainer

ARG USERNAME=node
ARG USER_UID=1000
ARG USER_GID=${USER_UID}

RUN test "${USERNAME}" = "node" \
  || ( \
    addgroup -g ${USER_GID} ${USERNAME} \
    && adduser -G ${USERNAME} -D -u ${USER_UID} ${USERNAME} \
  )

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

FROM builder
