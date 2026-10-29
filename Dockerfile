# syntax=docker/dockerfile:1

ARG NODE_VERSION=24
FROM node:${NODE_VERSION}-bookworm-slim

ARG REA_VERSION
ARG TARGETPLATFORM

ENV NODE_ENV=production \
    REA_HOME=/home/rea \
    REA_TOOLS_DIR=/opt/rea-tools \
    PATH="/usr/local/bin:${PATH}"

# procps ist Pflicht: REA benoetigt ein procps-kompatibles ps.
# curl und jq dienen Health-Checks und Diagnose im Container.
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      jq \
      procps \
      tini \
 && rm -rf /var/lib/apt/lists/*

# Offizielles REA-Paket installieren.
# --ignore-scripts verhindert beliebige Lifecycle-Skripte aus Abhaengigkeiten.
RUN npm install --global --ignore-scripts "rea-agents@${REA_VERSION}" \
 && npm cache clean --force \
 && rea --version

# HTTP-Bridge fuer den stdio-MCP-Server von REA
RUN npm install --global --ignore-scripts supergateway

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod 0755 /usr/local/bin/entrypoint.sh \
 && useradd --create-home --shell /usr/sbin/nologin rea \
 && mkdir -p /work /opt/rea-tools /home/rea \
 && chown -R rea:rea /home/rea /opt/rea-tools

USER rea
WORKDIR /home/rea

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD curl -fsS http://127.0.0.1:8080/healthz || exit 1

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/entrypoint.sh"]
