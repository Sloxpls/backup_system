#!/bin/bash

CONFIG_FILE="$HOME/.config/system_backup/config.yaml"

echo "Updating configuration..."

# Load current values
BACKUP_DIR=$(yq '.backup_dir' "$CONFIG_FILE")
MAX_BACKUPS=$(yq '.max_backups' "$CONFIG_FILE")
USE_GIT=$(yq '.use_git' "$CONFIG_FILE")
GIT_REPO_URL=$(yq '.git_repo_url' "$CONFIG_FILE")
GIT_USER_NAME=$(yq '.git_user_name' "$CONFIG_FILE")
GIT_USER_EMAIL=$(yq '.git_user_email' "$CONFIG_FILE")

# Prompt user for updates
read -p "Enter the backup directory (default: $BACKUP_DIR): " NEW_BACKUP_DIR
BACKUP_DIR=${NEW_BACKUP_DIR:-$BACKUP_DIR}

read -p "Enter the maximum number of backups to keep (default: $MAX_BACKUPS): " NEW_MAX_BACKUPS
MAX_BACKUPS=${NEW_MAX_BACKUPS:-$MAX_BACKUPS}

read -p "Do you want to enable Git for backups? (y/n, default: $USE_GIT): " NEW_USE_GIT
USE_GIT=${NEW_USE_GIT:-$USE_GIT}

if [ "$USE_GIT" == "y" ]; then
    read -p "Enter the remote Git repository URL (default: $GIT_REPO_URL): " NEW_GIT_REPO_URL
    GIT_REPO_URL=${NEW_GIT_REPO_URL:-$GIT_REPO_URL}
fi

# Save updates to config file
cat > "$CONFIG_FILE" <<EOL
backup_dir: "$BACKUP_DIR"
max_backups: $MAX_BACKUPS
use_git: $USE_GIT
git_repo_url: "$GIT_REPO_URL"
git_user_name: "$GIT_USER_NAME"
git_user_email: "$GIT_USER_EMAIL"
EOL

echo "Configuration updated and saved to $CONFIG_FILE."
