# CWO GN

For CWO to GN Permit sync.

# Inital Set Up

- Execute set up script via raw github url
  - curl -sL https://raw.githubusercontent.com/genobear/Deploy-Scripts/main/CWO-GN/setup.sh | sudo bash -

# Update

1. Rename the existing example Update.sh file
2. Modify update script with secrets.
3. Run Update Script
   - sudo sh /usr/local/apps/CWO-GN-sync/deploy/update.sh

# Service Management

- sudo systemctl {restart} FWO-GN-sync.service
  - stop
  - start
  - enable
  - disable

# Run in terminal

/usr/local/apps/CWO-GN-sync/venv/bin/python /usr/local/apps/CWO-GN-sync/main.py
