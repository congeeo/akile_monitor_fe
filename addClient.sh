#!/bin/bash

# Create the directory and navigate into it
mkdir -p /etc/ak_monitor/
cd /etc/ak_monitor/

# Download the client executable
wget -O client https://github.com/akile-network/akile_monitor/releases/download/v0.01/akile_client-linux-amd64

# Make the client executable
chmod 777 client

# Create the systemd service file
cat > /etc/systemd/system/ak_client.service <<EOF
[Unit]
Description=AkileCloud Monitor Service
After=network.target nss-lookup.target
Wants=network.target
[Service]
User=root
Group=root
Type=simple
LimitAS=infinity
LimitRSS=infinity
LimitCORE=infinity
LimitNOFILE=999999999
WorkingDirectory=/etc/ak_monitor/
ExecStart=/etc/ak_monitor/client
Restart=always
RestartSec=10
[Install]
WantedBy=multi-user.target
EOF

# Read four parameters from standard input
read -p "Enter auth_secret: " auth_secret
read -p "Enter url: " url
read -p "Enter net_name: " net_name
read -p "Enter name: " name

net_name=${net_name:-eth0}

# Create the client.json file with the provided parameters
cat > /etc/ak_monitor/client.json <<EOF
{
  "auth_secret": "$auth_secret",
  "url": "$url",
  "net_name": "$net_name",
  "name": "$name"
}
EOF

# Enable and start the systemd service
systemctl daemon-reload
systemctl enable --now ak_client.service
