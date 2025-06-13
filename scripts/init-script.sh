#!/bin/bash

# Enable error handling and logging
set -e
exec > >(tee /var/log/init-script.log) 2>&1

echo "Starting initialization script at $(date)"

# Update package lists
echo "Updating package lists..."
apt-get update

# Install OpenSSH server
echo "Installing OpenSSH server..."
apt-get install -y openssh-server

# Configure SSH server
echo "Configuring SSH server..."
cat > /etc/ssh/sshd_config.d/custom.conf << 'EOF'
# Custom SSH configuration
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
X11Forwarding no
AllowAgentForwarding no
AllowTcpForwarding no
PermitUserEnvironment no
ClientAliveInterval 300
ClientAliveCountMax 2
EOF

# Restart SSH service to apply changes
echo "Restarting SSH service..."
systemctl restart sshd

# Enable SSH service to start on boot
echo "Enabling SSH service..."
systemctl enable sshd

echo "SSH server has been installed and configured"

# Remove old Docker packages
echo "Removing old Docker packages..."
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do apt-get remove -y $pkg; done

# Add Docker's official GPG key:
echo "Adding Docker's GPG key..."
apt-get update
apt-get install -y ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo "Adding Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update

echo "Installing Docker packages..."
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "Initialization script completed at $(date)"