# hAI.rea-docker

Eigenes Docker-Image fuer das offizielle [`rea-agents`](https://www.npmjs.com/package/rea-agents)-Paket.

Das GitHub-Action-Workflow:

- baut das Image fuer `linux/amd64` und `linux/arm64`
- pusht es nach `ghcr.io/jbkunama1/hai.rea-docker`
- prueft taeglich die aktuelle `rea-agents`-Version auf npm
- aktualisiert bei einer neuen Version `REA_VERSION`, committet und baut automatisch

## Compose-Varianten

Es gibt zwei fertige Portainer-/Compose-Dateien:

| Datei | Port-Bindung | Erreichbarkeit |
|---|---|---|
| `compose-internal.yml` | `127.0.0.1:8075:8075` | Nur der Docker-Host selbst |
| `compose-lan.yml` | `8075:8075` | Alle Geraete im LAN |

Beide verwenden:

- Docker-Netzwerk: `highfishNetwork`
- Container-Port: `8075`
- MCP-Endpunkt: `/mcp`
- AnythingMCP-URL im Docker-Netz: `http://rea:8075/mcp`
- LAN-URL: `http://<SERVER-IP>:8075/mcp`

## Netzwerk vorbereiten

Falls `highfishNetwork` noch nicht existiert:

```bash
docker network create highfishNetwork
```

## Host-Ordner vorbereiten

```bash
sudo mkdir -p /opt/rea/targets /opt/rea/data /opt/rea/tools
sudo chown -R 1000:1000 /opt/rea/data /opt/rea/tools
```

## Portainer verwenden

1. **Stacks > + Add stack**
2. Einen Namen vergeben, z. B. `rea`
3. Entweder `compose-internal.yml` oder `compose-lan.yml` in den Web Editor kopieren
4. **Deploy the stack** klicken

Alternativ per CLI:

```bash
docker compose -f compose-internal.yml up -d
# oder
docker compose -f compose-lan.yml up -d
```

## AnythingMCP anbinden

In AnythingMCP einen Connector vom Typ **MCP Bridge** bzw. **Remote MCP Server** anlegen.

Transport:

```text
Remote Streamable HTTP
```

URL, wenn AnythingMCP im selben Docker-Netz laeuft:

```text
http://rea:8075/mcp
```

URL, wenn AnythingMCP ausserhalb des Docker-Netzes laeuft:

```text
http://<SERVER-IP>:8075/mcp
```

## Sicherheit

Die LAN-Variante stellt den MCP-Endpunkt **ohne Authentifizierung** bereit. Jeder im LAN kann die REA-Tools aufrufen.

- Fuer ein vertrauenswuerdiges Heimnetz: `compose-lan.yml` verwenden.
- Fuer Schule, Gaeste-WLAN oder oeffentliche Server: `compose-internal.yml` verwenden und den Zugriff nur per SSH-Tunnel oder authentifiziertem Reverse Proxy freigeben.
- Optional kann mit UFW der Zugriff auf das eigene Subnetz begrenzt werden:

```bash
sudo ufw allow from 192.168.178.0/24 to any port 8075 proto tcp
sudo ufw deny 8075/tcp
```

Das Subnetz `192.168.178.0/24` muss an das eigene Heimnetz angepasst werden.

## Ressourcen

Beide Compose-Dateien sind auf einen ressourcenschonenden MCP-Betrieb ohne Ghidra ausgelegt:

- CPU-Limit: 1 Kern
- RAM-Limit: 1 GB
- CPU-Reservierung: 0,25 Kerne
- RAM-Reservierung: 256 MB

Fuer Ghidra-Analysen sollten mindestens 2 CPU-Kerne und 4 GB RAM eingeplant werden.

## GitHub-Workflow

Das Repository enthaelt `.github/workflows/build.yml`. Es baut und published das Image automatisch nach:

```text
ghcr.io/jbkunama1/hai.rea-docker
```

Im GitHub-Repo unter **Settings > Actions > General > Workflow permissions** muss **Read and write permissions** aktiviert sein.

## Manuelles Bauen

```bash
docker build --build-arg REA_VERSION="$(cat REA_VERSION)" -t ghcr.io/jbkunama1/hai.rea-docker:local .
```

## Image testen

```bash
docker pull ghcr.io/jbkunama1/hai.rea-docker:latest
docker run --rm ghcr.io/jbkunama1/hai.rea-docker:latest rea --version
```
