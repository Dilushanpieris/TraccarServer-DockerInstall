#!/bin/bash

echo "--- Nginx Proxy Manager Uninstaller ---"

# --- 1. Confirmation ---
echo "WARNING: This will delete ALL SSL certificates, proxy settings, and logs."
read -p "Are you sure you want to proceed? (y/n): " CONFIRM < /dev/tty
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Uninstall cancelled."
    exit 1
fi

# --- 2. Stop and Remove Containers ---
if [ -d "~/ssl-proxy" ] || [ -f "~/ssl-proxy/docker-compose.yml" ]; then
    echo "Stopping Nginx Proxy containers..."
    cd ~/ssl-proxy && sudo docker compose down --rmi all -v --remove-orphans
    cd ~
else
    echo "SSL-Proxy directory not found. Attempting manual container removal..."
    sudo docker stop nginx-proxy 2>/dev/tty
    sudo docker rm nginx-proxy 2>/dev/tty
fi

# --- 3. Remove Project Files ---
echo "Removing project folder: ~/ssl-proxy"
sudo rm -rf ~/ssl-proxy

# --- 4. Cleanup Network (Optional) ---
sudo docker network prune -f

echo "------------------------------------------------"
echo "CLEANUP COMPLETE: Port 80, 81, and 443 are now free."
echo "------------------------------------------------"