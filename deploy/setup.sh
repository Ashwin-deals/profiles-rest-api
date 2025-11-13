#!/usr/bin/env bash

set -e

# TODO: Set to URL of git repo.
PROJECT_GIT_URL='https://github.com/Ashwin-deals/profiles-rest-api.git'

PROJECT_BASE_PATH='/usr/local/apps/profiles-rest-api'

# Set Ubuntu Language
locale-gen en_GB.UTF-8

# Install necessary development dependencies and updated package names.
echo "Installing dependencies..."
# Update repositories
apt-get update

# CORRECTED:
# 1. Use python3-venv and python3-dev for modern Python setup.
# 2. Use supervisor, nginx, and git.
# 3. Use sqlite3 and libsqlite3-dev (SQLite development library) instead of generic 'sqlite'.
apt-get install -y python3-dev python3-venv sqlite3 libsqlite3-dev supervisor nginx git build-essential

# NOTE: python-pip is replaced by python3-pip, but since we are using
# 'python3 -m venv', we rely on the venv module to create the virtual environment
# with pip pre-installed, making a separate 'apt-get install python3-pip' unnecessary here.

# Create the base directory and clone the project
mkdir -p $PROJECT_BASE_PATH
git clone $PROJECT_GIT_URL $PROJECT_BASE_PATH

# Create virtual environment inside the project directory
python3 -m venv $PROJECT_BASE_PATH/env

# Install Python requirements and uWSGI inside the virtual environment
# We explicitly call python3 to use the correct interpreter.
$PROJECT_BASE_PATH/env/bin/pip install -r $PROJECT_BASE_PATH/requirements.txt uwsgi==2.0.21

# Run migrations
# We explicitly call python3 from the environment
$PROJECT_BASE_PATH/env/bin/python3 $PROJECT_BASE_PATH/manage.py migrate

# Setup Supervisor to run our uwsgi process.
cp $PROJECT_BASE_PATH/deploy/supervisor_profiles_api.conf /etc/supervisor/conf.d/profiles_api.conf
supervisorctl reread
supervisorctl update
supervisorctl restart profiles_api

# Setup nginx to make our application accessible.
cp $PROJECT_BASE_PATH/deploy/nginx_profiles_api.conf /etc/nginx/sites-available/profiles_api.conf
rm /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/profiles_api.conf /etc/nginx/sites-enabled/profiles_api.conf
systemctl restart nginx.service

echo "DONE! :)"
