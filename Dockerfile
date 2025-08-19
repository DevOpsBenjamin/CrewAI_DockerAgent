# Use Ubuntu 24.04 as base image
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Base tools (+ gnupg for NodeSource)
RUN apt-get update && apt-get install -y \
    curl \
    git \
    python3 \
    python3-pip \
    ca-certificates \
    sudo \
    openssh-client \
    sshpass \
    netcat-openbsd \
    autossh \
    libnss3 \
    libxss1 \
    libatk-bridge2.0-0 \
    libgtk-3-0 \
    gnupg \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash vscode && \
    echo "vscode ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

WORKDIR /workspace
ENV HOME=/home/vscode
ENV PATH="$HOME/.local/bin:$PATH"

# Install uv CLI as vscode user
USER vscode
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/home/vscode/.uv/bin:${PATH}"

# Use uv to install crewai
RUN uv tool install crewai

# Back to root for system-wide installs
USER root

# Install code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh

# --- Added: Node.js (latest LTS 22.x) + gemini-cli ---
# If you truly want the bleeding-edge "current" instead of LTS, replace setup_22.x with setup_current.x
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g @google/gemini-cli \
    && npm cache clean --force \
    && rm -rf /var/lib/apt/lists/*
# -----------------------------------------------------

# Expose default code-server port
EXPOSE 8080


USER vscode
SHELL ["/bin/bash", "-c"]

# Entrypoint script: run init.sh (can start code-server inside)
CMD /home/vscode/init.sh