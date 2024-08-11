#
# Inital Set Up

- Execute set up script via raw github url
  - `curl -sL https://raw.githubusercontent.com/genobear/Deploy-Scripts/main/fbscuk/setup.sh | sudo bash -`

# Update

1. Rename the existing example Update.sh file
2. Modify update script with secrets.
3. Run Update Script
   - `sudo sh /usr/local/apps/fbscuk/deploy/update.sh`

# Service Management


`/usr/local/apps/fbscuk/venv/bin/python /usr/local/apps/fbscuk/manage.py {command}`
