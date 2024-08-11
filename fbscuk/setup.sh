#!/bin/bash

# Stop script on any error
# set -e

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
echo "Creating deployment directory..."
mkdir -p $DEPLOY_DIR
echo "Cloning the repository..."
git clone -b $BRANCH $REPO_URL $DEPLOY_DIR

# Step 3: Set up a Python virtual environment and install dependencies
echo "Setting up a Python virtual environment and installing dependencies..."
cd $DEPLOY_DIR && python3 -m venv venv && source venv/bin/activate && pip install -r requirements.txt


# Install python packages
$DEPLOY_DIR/venv/bin/pip install -r $DEPLOY_DIR/requirements.txt
$DEPLOY_DIR/venv/bin/pip install uwsgi

# Run migrations and collectstatic
cd $DEPLOY_DIR
$DEPLOY_DIR/venv/bin/python manage.py migrate
$DEPLOY_DIR/venv/bin/python manage.py collectstatic --noinput

# Step 4: Set permissions
# echo "Setting permissions..."
# chown -R $USER_NAME:$USER_NAME $DEPLOY_DIR


# Configure supervisor
cp $DEPLOY_DIR/deploy/supervisor_fbscuk.conf /etc/supervisor/conf.d/fbscuk.conf
supervisorctl reread
supervisorctl update
supervisorctl restart fbscuk


# Configure nginx
cp $PROJECT_BASE_PATH/deploy/nginx_fbscuk.conf /etc/nginx/sites-available/fbscuk.conf
rm /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/fbscuk.conf /etc/nginx/sites-enabled/fbscuk.conf
systemctl restart nginx.service


# Step 9: Test Nginx configuration and reload
echo "Testing Nginx configuration..."
sudo nginx -t
echo "Reloading Nginx..."
sudo systemctl reload nginx

echo "Setup complete!"