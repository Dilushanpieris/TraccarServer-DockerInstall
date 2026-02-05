#!/bin/bash

# --- Engineering Check: Root Privileges ---
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (use sudo)"
   exit 1
fi

echo "Starting Step 01: System Prep & Docker Installation..."

# 1. Update and install dependencies
apt update && apt upgrade -y
apt install -y ca-certificates curl gnupg haveged

# 2. Performance Fix: Add 2GB Swap File (Prevents E2-micro freezing)
echo "Setting up 2GB Swap File..."
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab

# 3. Security: Add Docker's official GPG key
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# 4. Add Docker Repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# 5. Install Docker Engine & Compose Plugin
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 6. Start Performance Services
systemctl enable --now haveged
systemctl enable --now docker

echo "------------------------------------------------"
echo "Step 01 Complete: Docker and Performance Tuning are READY."
echo "------------------------------------------------"