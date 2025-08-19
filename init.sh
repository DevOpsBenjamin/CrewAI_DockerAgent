#!/bin/bash
set -euo pipefail

chown -R vscode:vscode /workspace || true

echo "Starting code-server"
# Prefer PASSWORD from env; fall back to HASHED_PASSWORD if provided
if [[ -n "${PASSWORD:-}" ]]; then
  export PASSWORD


echo "Starting code-server in background"
sudo -u vscode code-server /workspace &

# Wait for code-server to be ready
while ! nc -z localhost 8080; do
  sleep 1
done

echo "Starting autossh tunnel"
sudo -u vscode autossh -M 0 -N -R '*:8080:localhost:8080' -o StrictHostKeyChecking=no root@jetdail.fr &

# Now wait for code-server or autossh to exit (keep container running)
wait -n