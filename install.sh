#!/bin/bash

CONFIG_FILE="$HOME/.config/system_backup/config.yaml"
BACKUP_DIR="$HOME/system_backup/"

echo "Installing backup system..."

# Install dependencies
sudo apt update
sudo apt install -y git dconf-cli flatpak python3-pip

# Setup Git globally
read -p "Enter your Git user name: " GIT_NAME
read -p "Enter your Git user email: " GIT_EMAIL
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"

# Create configuration directory
mkdir -p "$(dirname "$CONFIG_FILE")"

# Default config values
cat > "$CONFIG_FILE" <<EOL
backup_dir: "$BACKUP_DIR"
max_backups: 7
use_git: n
git_repo_url: ""
git_user_name: "$GIT_NAME"
git_user_email: "$GIT_EMAIL"
EOL

echo "Configuration saved to $CONFIG_FILE."

# Optional: install Python dependencies for GUI
if [ -d "gui" ]; then
    echo "Installing Python dependencies for GUI..."
    pip install -r gui/requirements.txt
fi

echo "Installation complete. Run config.sh to update settings or backup.sh to start a backup."
