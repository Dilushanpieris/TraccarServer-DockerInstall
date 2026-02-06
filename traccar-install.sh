#!/bin/bash

# --- 1. Project Setup ---
echo "--- Traccar Interactive Installer ---"
mkdir -p ~/traccar && cd ~/traccar
mkdir -p logs

# --- 2. Interactive Prompts ---
# Panel Port
read -p "Enter Web Panel Port [Default 8082]: " PANEL_PORT
PANEL_PORT=${PANEL_PORT:-8082}

# GPS Port
read -p "Enter GPS Tracker Port [Default 5013]: " GPS_PORT
GPS_PORT=${GPS_PORT:-5013}

# API Key (Required for Push)
echo "------------------------------------------------"
echo "NOTE: API Key is REQUIRED for Push Notifications."
echo "If you skip this, push alerts will not work."
read -p "Enter Traccar.org API Key (or press Enter to skip): " API_KEY
echo "------------------------------------------------"

# --- 3. Build the Docker Compose ---
echo "Building configuration..."

# Standard environment variables
ENV_BLOCK="      - CONFIG_USE_ENVIRONMENT_VARIABLES=true"

# Add push notification logic if key exists
if [[ ! -z "$API_KEY" ]]; then
    ENV_BLOCK="$ENV_BLOCK
      - NOTIFICATOR_TYPES=web,mail,command,traccar
      - NOTIFICATOR_TRACCAR_KEY=$API_KEY"
else
    ENV_BLOCK="$ENV_BLOCK
      - NOTIFICATOR_TYPES=web,mail,command"
fi

# Write the file
cat <<EOF > docker-compose.yml
services:
  traccar:
    image: traccar/traccar:latest
    container_name: traccar-app
    restart: always
    environment:
$ENV_BLOCK
    ports:
      - "$PANEL_PORT:8082"
      - "$GPS_PORT:$GPS_PORT"
      - "$GPS_PORT:$GPS_PORT/udp"
    volumes:
      - ./logs:/opt/traccar/logs:rw
EOF

# --- 4. Launch ---
echo "Starting Traccar..."
sudo docker compose up -d

echo "------------------------------------------------"
echo "INSTALLATION SUCCESSFUL"
echo "Web Panel: http://$(curl -s ifconfig.me):$PANEL_PORT"
echo "Tracker Port: $GPS_PORT"
[[ ! -z "$API_KEY" ]] && echo "Push Notifications: ENABLED" || echo "Push Notifications: DISABLED"
echo "------------------------------------------------"