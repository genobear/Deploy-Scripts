#
# Inital Set Up

- Execute set up script via raw github url
  - `curl -sL https://raw.githubusercontent.com/genobear/Deploy-Scripts/main/fbscuk/setup.sh | bash -`

# Update

1. Rename the existing example Update.sh file
2. Modify update script with secrets.
3. Run Update Script
   - `sudo sh /home/ubuntu/apps/fbscuk/deploy/update.sh`

# Service Management


`/home/ubuntu/apps/fbscuk/venv/bin/python /home/ubuntu/apps/fbscuk/manage.py {command}`
