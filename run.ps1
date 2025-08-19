# Remove container if exists
if (docker ps -a --format '{{.Names}}' | Select-String '^crewai-run$') {
    docker rm -f crewai-run
}

# Run container in detached mode
docker run -d -p 8080:8080 --env-file .\.env -v ".\.ssh:/home/vscode/.ssh:ro" -v ".\volumes:/workspace" --name crewai-run crewai-ubuntu