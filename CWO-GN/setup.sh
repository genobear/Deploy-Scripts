#!/bin/bash

# Variables
BRANCH="main"  # or the branch you want to deploy
REPO_URL="https://github.com/genobear/CWO-to-GN-Permit-Ingestion.git"

DEPLOY_DIR="/usr/local/apps/CWO-GN-sync"
SERVICE_NAME="FWO-GN-sync"
SCRIPT_NAME="main.py"
USER_NAME="genobear90"


# Step 1: Clone the repository
echo making dir
mkdir -p $DEPLOY_DIR
echo cloning
git clone -b $BRANCH $REPO_URL $DEPLOY_DIR


# make other directory
echo create logs dir
mkdir -p $DEPLOY_DIR/logs

echo Create example .env file
cat > $DEPLOY_DIR/.env <<EOL
SOURCE_API_KEY = 'dasda=='
GROUP_NEXUS_LOGIN = "asdsada@ndomain.co.uk"
GROUP_NEXUS_PASSWORD = "Iasdasdsadsad"
MODE = 'TEST'
EOL

# Step 2: Set up a Python virtual environment and install dependencies
echo Set up a Python virtual environment and install dependencies
cd $DEPLOY_DIR && python3 -m venv venv && source venv/bin/activate && pip install -r requirements.txt

#permissions
echo Set permissions
chown -R $USER_NAME:$USER_NAME $DEPLOY_DIR


# Step 3: Create a systemd service file
SERVICE_FILE=$(cat <<EOF
[Unit]
Description=CWO Live Purchases to Group Nexus Permit Ingestion
After=network.target

[Service]
User=$USER_NAME
Group=$USER_NAME
WorkingDirectory=$DEPLOY_DIR
Environment="PATH=$DEPLOY_DIR/venv/bin"
ExecStart=$DEPLOY_DIR/venv/bin/python $DEPLOY_DIR/$SCRIPT_NAME

Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
)

echo create the service file 
echo "$SERVICE_FILE" | sudo tee /etc/systemd/system/$SERVICE_NAME.service

echo Reload systemd, enable and start the service
sudo systemctl daemon-reload && sudo systemctl enable $SERVICE_NAME.service && sudo systemctl start $SERVICE_NAME.service