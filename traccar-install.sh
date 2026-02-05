#!/bin/bash

# --- 1. Project Setup ---
echo "--- Traccar Interactive Installer ---"
mkdir -p ~/traccar && cd ~/traccar
mkdir -p logs

# --- 2. User Input ---
read -p "Enter Web Panel Port [Default: 8082]: " PANEL_PORT
PANEL_PORT=${PANEL_PORT:-8082}

read -p "Enter GPS Tracker Port [e.g. 5013]: " TRACKER_PORT
if [[ -z "$TRACKER_PORT" ]]; then
    echo "Error: Tracker Port is required for communication."
    exit 1
fi

read -p "Enter Traccar.org API Key (Press Enter to Skip): " API_KEY

# --- 3. Generate Docker Compose ---
echo "Generating configuration..."

# Start of the Compose file
cat <<EOF > docker-compose.yml
services:
  traccar:
    image: traccar/traccar:latest
    container_name: traccar-app
    restart: always
    environment:
      - CONFIG_USE_ENVIRONMENT_VARIABLES=true
EOF

# Conditionally add the API Key and Notificator settings
if [[ ! -z "$API_KEY" ]]; then
    cat <<EOF >> docker-compose.yml
      - NOTIFICATOR_TYPES=web,mail,command,traccar
      - NOTIFICATOR_TRACCAR_KEY=$API_KEY
EOF
else
    cat <<EOF >> docker-compose.yml
      - NOTIFICATOR_TYPES=web,mail,command
EOF
fi

# Add the Ports and Volumes
cat <<EOF >> docker-compose.yml
    ports:
      - "$PANEL_PORT:8082"
      - "$TRACKER_PORT:$TRACKER_PORT"
      - "$TRACKER_PORT:$TRACKER_PORT/udp"
    volumes:
      - ./logs:/opt/traccar/logs:rw
EOF

# --- 4. Deployment ---
echo "Deploying Traccar Container..."
sudo docker compose up -d

echo "------------------------------------------------"
echo "INSTALLATION COMPLETE"
echo "Panel: http://$(curl -s ifconfig.me):$PANEL_PORT"
echo "Tracker Port: $TRACKER_PORT"
if [[ -z "$API_KEY" ]]; then
    echo "Push Notifications: DISABLED (No API Key provided)"
else
    echo "Push Notifications: ENABLED"
fi
echo "------------------------------------------------"