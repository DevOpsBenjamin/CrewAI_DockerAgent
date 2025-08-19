#!/usr/bin/env bash
set -euo pipefail

# Required env (fail fast)
if [[ -z "${PASSWORD:-}" && -z "${HASHED_PASSWORD:-}" ]]; then
  echo "ERROR: set PASSWORD or HASHED_PASSWORD in .env" >&2; exit 1
fi
: "${GATE_HOST:?ERROR: set GATE_HOST}"
: "${GATE_USER:?ERROR: set GATE_USER}"
: "${REMOTE_PORT:?ERROR: set REMOTE_PORT}"
: "${LOCAL_PORT:?ERROR: set LOCAL_PORT}"

# Best-effort ownership (safe if already owned)
chown -R vscode:vscode /workspace 2>/dev/null || true
chown -R vscode:vscode /home/vscode 2>/dev/null || true

echo "Starting code-server on 127.0.0.1:${LOCAL_PORT}"
code-server /workspace --bind-addr "127.0.0.1:${LOCAL_PORT}" &

# Wait until code-server is listening
until nc -z 127.0.0.1 "${LOCAL_PORT}"; do sleep 1; done

echo "Starting autossh ${GATE_HOST}:${REMOTE_PORT} -> 127.0.0.1:${LOCAL_PORT}"
autossh -M 0 -N \
  -R "*:${REMOTE_PORT}:127.0.0.1:${LOCAL_PORT}" \
  -o ServerAliveInterval=30 -o ServerAliveCountMax=3 \
  -o StrictHostKeyChecking=no \
  "${GATE_USER}@${GATE_HOST}" &

wait -n