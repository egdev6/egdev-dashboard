ARG OPENCLAW_BASE_IMAGE=ghcr.io/openclaw/openclaw:latest
FROM ${OPENCLAW_BASE_IMAGE}

USER root
RUN mkdir -p /opt/discord-project-manager/skills /opt/discord-project-manager/openclaw-config /usr/local/bin \
  && chown -R node:node /opt/discord-project-manager

COPY --chown=node:node skills/ /opt/discord-project-manager/skills/
COPY --chown=node:node openclaw/config/ /opt/discord-project-manager/openclaw-config/
COPY --chown=root:root docker/openclaw/sync-skills.sh /usr/local/bin/discord-project-manager-sync-skills
COPY --chown=root:root docker/openclaw/managed-channel-registry.sh /usr/local/bin/discord-project-manager-managed-registry
RUN chmod 0755 /usr/local/bin/discord-project-manager-sync-skills /usr/local/bin/discord-project-manager-managed-registry

USER node
