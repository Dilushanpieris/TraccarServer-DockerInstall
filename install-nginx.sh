#!/bin/bash

# --- 1. Project Setup ---
echo "--- Nginx Proxy Manager Installer ---"
mkdir -p ~/ssl-proxy && cd ~/ssl-proxy

# --- 2. Interactive Prompts ---
# Proxy Admin Panel Port
echo -n "Enter Nginx Admin Panel Port [Default 81]: "
read ADMIN_PORT < /dev/tty
ADMIN_PORT=${ADMIN_PORT:-81}

# --- 3. Build the Docker Compose ---
echo "Generating SSL Proxy configuration..."

cat <<EOF > docker-compose.yml
services:
  nginx-proxy:
    image: 'jc21/nginx-proxy-manager:latest'
    container_name: nginx-proxy
    restart: always
    ports:
      - '80:80'      # Standard HTTP
      - '$ADMIN_PORT:81'  # Custom Admin Panel
      - '443:443'    # Secure HTTPS
    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt
EOF

# --- 4. Launch ---
echo "Starting Nginx Proxy Manager..."
sudo docker compose up -d

# --- 5. Output Networking Info for SSL Setup ---
echo "------------------------------------------------"
echo "INSTALLATION SUCCESSFUL"
echo "Admin Panel: http://$(curl -s -4 ifconfig.me):$ADMIN_PORT"
echo "Default Login: admin@example.com / changeme"
echo "------------------------------------------------"
echo "CRITICAL INFO FOR YOUR SSL SETUP:"
echo "When adding a 'Proxy Host', use the Internal IP below"
echo "as the 'Forward Hostname/IP' to connect to Traccar:"
echo ""
ip addr show docker0 | grep inet | awk '{print $2}' | cut -d/ -f1
echo "------------------------------------------------"