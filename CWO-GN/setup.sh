#!/bin/bash

# Variables
BRANCH="main"  # or the branch you want to deploy
REPO_URL="https://github.com/genobear/CWO-to-GN-Permit-Ingestion.git"

DEPLOY_DIR="/usr/local/apps/CWO-GN-sync"
SERVICE_NAME="FWO-GN-sync"
SCRIPT_NAME="main.py"



# Step 1: Clone the repository
echo making dir
mkdir -p $DEPLOY_DIR
echo cloning
git clone -b $BRANCH $REPO_URL $DEPLOY_DIR

# make directory
mkdir -p $DEPLOY_DIR/logs

# Step 2: Set up a Python virtual environment and install dependencies
cd $DEPLOY_DIR && python3 -m venv venv && source venv/bin/activate && pip install -r requirements.txt

# Step 3: Create a systemd service file
SERVICE_FILE=$(cat <<EOF
[Unit]
Description=CWO Live Purchases to Group Nexus Permit Ingestion
After=network.target

[Service]
User=ubuntu
Group=ubuntu
WorkingDirectory=$DEPLOY_DIR
Environment="PATH=$DEPLOY_DIR/venv/bin"
ExecStart=$DEPLOY_DIR/venv/bin/python $DEPLOY_DIR/$SCRIPT_NAME

Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
)

# Step 4: Transfer the service file to the remote server
echo "$SERVICE_FILE" | sudo tee /etc/systemd/system/$SERVICE_NAME.service

# Step 5: Reload systemd, enable and start the service
sudo systemctl daemon-reload && sudo systemctl enable $SERVICE_NAME.service && sudo systemctl start $SERVICE_NAME.service