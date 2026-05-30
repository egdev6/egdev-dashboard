ARG OPENCLAW_BASE_IMAGE=ghcr.io/openclaw/openclaw:latest
FROM ${OPENCLAW_BASE_IMAGE}

USER root
RUN mkdir -p /opt/egdev-dashboard/skills /opt/egdev-dashboard/openclaw-config /usr/local/bin \
  && chown -R node:node /opt/egdev-dashboard

COPY --chown=node:node skills/ /opt/egdev-dashboard/skills/
COPY --chown=node:node openclaw/config/ /opt/egdev-dashboard/openclaw-config/
COPY --chown=root:root docker/openclaw/sync-skills.sh /usr/local/bin/egdev-sync-skills
RUN chmod 0755 /usr/local/bin/egdev-sync-skills

USER node
