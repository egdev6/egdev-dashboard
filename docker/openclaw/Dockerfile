ARG OPENCLAW_BASE_IMAGE=ghcr.io/openclaw/openclaw:latest
FROM ${OPENCLAW_BASE_IMAGE}

ARG TARGETARCH
ARG GENTLE_AI_VERSION=1.37.0

USER root
RUN set -eu; \
  case "${TARGETARCH:-amd64}" in \
    amd64|x86_64) gentle_arch="amd64" ;; \
    arm64|aarch64) gentle_arch="arm64" ;; \
    *) echo "unsupported TARGETARCH for gentle-ai: ${TARGETARCH}" >&2; exit 1 ;; \
  esac; \
  tmpdir="$(mktemp -d)"; \
  cd "$tmpdir"; \
  curl -fsSLO "https://github.com/Gentleman-Programming/gentle-ai/releases/download/v${GENTLE_AI_VERSION}/gentle-ai_${GENTLE_AI_VERSION}_linux_${gentle_arch}.tar.gz"; \
  curl -fsSLO "https://github.com/Gentleman-Programming/gentle-ai/releases/download/v${GENTLE_AI_VERSION}/checksums.txt"; \
  grep " gentle-ai_${GENTLE_AI_VERSION}_linux_${gentle_arch}.tar.gz$" checksums.txt | sha256sum -c -; \
  tar -xzf "gentle-ai_${GENTLE_AI_VERSION}_linux_${gentle_arch}.tar.gz"; \
  install -m 0755 gentle-ai /usr/local/bin/gentle-ai; \
  cd /; \
  rm -rf "$tmpdir"; \
  gentle-ai --version; \
  mkdir -p /opt/discord-project-manager/skills /opt/discord-project-manager/openclaw-config /usr/local/bin; \
  chown -R node:node /opt/discord-project-manager

COPY --chown=node:node skills/ /opt/discord-project-manager/skills/
COPY --chown=node:node openclaw/config/ /opt/discord-project-manager/openclaw-config/
COPY --chown=root:root docker/openclaw/sync-skills.sh /usr/local/bin/discord-project-manager-sync-skills
COPY --chown=root:root docker/openclaw/managed-channel-registry.sh /usr/local/bin/discord-project-manager-managed-registry
RUN chmod 0755 /usr/local/bin/discord-project-manager-sync-skills /usr/local/bin/discord-project-manager-managed-registry

USER node
