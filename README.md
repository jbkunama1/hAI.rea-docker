# hAI.rea-docker

Eigenes Docker-Image fuer das offizielle [`rea-agents`](https://www.npmjs.com/package/rea-agents)-Paket.

Das GitHub-Action-Workflow:

- baut das Image fuer `linux/amd64` und `linux/arm64`
- pushed es nach `ghcr.io/jbkunama1/hai.rea-docker`
- prueft taeglich die aktuelle `rea-agents`-Version auf npm
- aktualisiert bei einer neuen Version `REA_VERSION`, committet und baut automatisch

## Voraussetzungen

Im GitHub-Repo unter **Settings > Actions > General > Workflow permissions**:

- **Read and write permissions** aktivieren

## Manueller Build

```bash
docker build --build-arg REA_VERSION="$(cat REA_VERSION)" -t ghcr.io/jbkunama1/hai.rea-docker:local .
```

## Portainer

```yaml
services:
  rea:
    image: ghcr.io/jbkunama1/hai.rea-docker:latest
    container_name: rea
    restart: unless-stopped
    environment:
      REA_HTTP_PORT: "8080"
    ports:
      - "127.0.0.1:8080:8080"
    volumes:
      - /opt/rea/targets:/work:ro
      - /opt/rea/data:/home/rea
      - /opt/rea/tools:/opt/rea-tools
    tmpfs:
      - /tmp:rw,nosuid,size=4g
    read_only: true
    cap_drop:
      - ALL
    security_opt:
      - no-new-privileges
```

## Agent anbinden

Der Container stellt einen ungeschuetzten HTTP-MCP-Endpunkt bereit. Deshalb nur lokal oder hinter einem authentifizierten Reverse Proxy betreiben.

SSH-Tunnel:

```bash
ssh -N -L 8080:127.0.0.1:8080 user@dein-server
```

Claude Code:

```bash
claude mcp add --transport http rea http://127.0.0.1:8080/mcp
```
