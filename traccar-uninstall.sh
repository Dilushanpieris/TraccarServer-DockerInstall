#!/bin/bash

echo "--- Traccar Uninstaller & Cleanup ---"

# --- 1. Confirmation ---
echo "WARNING: This will delete ALL Traccar data, logs, and containers."
read -p "Are you sure you want to proceed? (y/n): " CONFIRM < /dev/tty
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Uninstall cancelled."
    exit 1
fi

# --- 2. Stop and Remove Containers ---
if [ -d "~/traccar" ] || [ -f "~/traccar/docker-compose.yml" ]; then
    echo "Stopping Traccar containers..."
    cd ~/traccar && sudo docker compose down --rmi all -v --remove-orphans
    cd ~
else
    echo "Traccar directory not found. Attempting manual container removal..."
    sudo docker stop traccar-app 2>/dev/tty
    sudo docker rm traccar-app 2>/dev/tty
fi

# --- 3. Remove Project Files ---
echo "Removing project folder: ~/traccar"
sudo rm -rf ~/traccar

# --- 4. System Prune (Optional Cleanup) ---
echo "Cleaning up unused Docker resources..."
sudo docker volume prune -f
sudo docker network prune -f

echo "------------------------------------------------"
echo "CLEANUP COMPLETE: Your VPS is now ready for a fresh install."
echo "------------------------------------------------"