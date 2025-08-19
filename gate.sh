#!/bin/bash

echo "Initiating Gate"

# Check for sshpass command (used to send password automatically)
if ! command -v sshpass &> /dev/null; then
    echo "sshpass is not installed. Please install sshpass in the container."
    exit 1
fi

# Prompt for credentials
read -p "Enter VPS username: " VPS_USER
read -p "Enter VPS hostname (e.g. jetdail.fr): " VPS_HOST
read -s -p "Enter VPS password (for initial setup): " VPS_PASS
echo

# Define SSH key path
KEY_DIR="$HOME/.ssh"
KEY_NAME="id_rsa"
KEY_PATH="$KEY_DIR/$KEY_NAME"

# Generate SSH key if missing
if [ ! -f "$KEY_PATH" ]; then
    echo "Generating SSH key pair..."
    ssh-keygen -t ed25519 -f "$KEY_PATH" -N "" -q
else
    echo "SSH key already exists at $KEY_PATH"
fi

# Copy public key manually (only if not already present)
echo "Copying public key manually..."
PUB_KEY_CONTENT=$(cat "$KEY_PATH.pub")
sshpass -p "$VPS_PASS" ssh -o StrictHostKeyChecking=no "$VPS_USER@$VPS_HOST" "mkdir -p ~/.ssh && chmod 700 ~/.ssh && grep -qxF '$PUB_KEY_CONTENT' ~/.ssh/authorized_keys || echo '$PUB_KEY_CONTENT' >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"

# Configure VPS SSH and firewall
echo "Configuring VPS SSH server..."

sshpass -p "$VPS_PASS" ssh -o StrictHostKeyChecking=no "$VPS_USER@$VPS_HOST" bash <<'EOF'
# Ensure GatewayPorts is set to yes
if grep -q "^GatewayPorts" /etc/ssh/sshd_config; then
    sudo sed -i "s/^GatewayPorts.*/GatewayPorts yes/" /etc/ssh/sshd_config
else
    echo "GatewayPorts yes" | sudo tee -a /etc/ssh/sshd_config
fi

# Restart sshd
sudo systemctl restart sshd

# Open firewall port if ufw exists
if command -v ufw &>/dev/null; then
    sudo ufw allow 8080/tcp
fi
EOF

echo "Setup complete!"