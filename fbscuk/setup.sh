#!/bin/bash

# Stop script on any error
set -e

# Variables
BRANCH="main"  # Branch you want to deploy
REPO_URL="https://github.com/genobear/fbsc.uk.git"
SERVICE_NAME="fbscuk"
DEPLOY_DIR="/usr/local/apps/$SERVICE_NAME"
SCRIPT_NAME="main.py"
USER_NAME="ubuntu"
DOMAIN_NAME="fbsc.uk preprod.fbsc.uk"  # Your domain name for Nginx setup

# Step 1: Update and Install Required Packages
echo "Updating system and installing required packages..."
sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt-get install -y python3 python3-pip python3-venv git nginx curl

# Step 2: Clone the repository
# echo "Creating deployment directory..."
# mkdir -p $DEPLOY_DIR
# echo "Cloning the repository..."
# git clone -b $BRANCH $REPO_URL $DEPLOY_DIR

# Step 3: Set up a Python virtual environment and install dependencies
echo "Setting up a Python virtual environment and installing dependencies..."
cd $DEPLOY_DIR && python3 -m venv venv && source venv/bin/activate && pip install -r requirements.txt

# Install python packages
$DEPLOY_DIR/venv/bin/pip install uwsgi==2.0.26

# Run migrations and collectstatic
cd $DEPLOY_DIR
$DEPLOY_DIR/venv/bin/python manage.py migrate
$DEPLOY_DIR/venv/bin/python manage.py collectstatic --noinput

# Step 4: Set permissions
# echo "Setting permissions..."
# sudo chown -R $USER_NAME:$USER_NAME $DEPLOY_DIR

# Step 5: Configure systemd
echo "Creating systemd service..."
sudo bash -c "cat > /etc/systemd/system/$SERVICE_NAME.service <<EOL
[Unit]
Description=fbscuk Django Application
After=network.target

[Service]
User=ubuntu
Group=www-data
WorkingDirectory=$DEPLOY_DIR
Environment=\"PATH=$DEPLOY_DIR/venv/bin\"
ExecStart=$DEPLOY_DIR/venv/bin/uwsgi --ini $DEPLOY_DIR/uwsgi.ini

Restart=always
RestartSec=10
KillMode=process
TimeoutSec=infinity

[Install]
WantedBy=multi-user.target
EOL"

sudo systemctl daemon-reload
sudo systemctl start $SERVICE_NAME
sudo systemctl enable $SERVICE_NAME

# Configure nginx
if [ -f "$DEPLOY_DIR/deploy/nginx_fbscuk.conf" ]; then
    sudo cp $DEPLOY_DIR/deploy/nginx_fbscuk.conf /etc/nginx/sites-available/fbscuk.conf
else
    echo "Nginx configuration file not found. Please check the path."
    exit 1
fi

sudo rm -f /etc/nginx/sites-enabled/default
sudo ln -sf /etc/nginx/sites-available/fbscuk.conf /etc/nginx/sites-enabled/fbscuk.conf
sudo systemctl restart nginx.service

# Step 9: Test Nginx configuration and reload
echo "Testing Nginx configuration..."
sudo nginx -t
echo "Reloading Nginx..."
sudo systemctl reload nginx

echo "Setup complete!"
