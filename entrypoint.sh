#!/usr/bin/env bash
set -euo pipefail

REA_VERSION="$(rea --version 2>/dev/null || true)"
PORT="${REA_HTTP_PORT:-8080}"
HOST="${REA_HTTP_HOST:-0.0.0.0}"

echo "{\"level\":\"info\",\"msg\":\"Starting REA\",\"rea\":\"${REA_VERSION}\"}" >&2

exec supergateway \
  --stdio "rea mcp" \
  --outputTransport streamableHttp \
  --port "${PORT}" \
  --host "${HOST}" \
  --healthEndpoint /healthz
