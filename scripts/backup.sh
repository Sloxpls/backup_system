#!/bin/bash

# Load helper functions
source ./utils.sh

# Default values
CONFIG_FILE="$HOME/.config/system_backup/config.yaml"
BACKUP_DIR=${BACKUP_DIR:-"/home/hugo/backup_system/assets/backup"}
MAX_BACKUPS=7
USE_GIT="n"
GIT_REPO_URL=""

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -local)
            BACKUP_DIR="$2"
            shift 2
            ;;
        -max)
            MAX_BACKUPS="$2"
            shift 2
            ;;
        -git)
            USE_GIT="y"
            shift
            ;;
        -help)
            echo "Usage: $0 [-local <path>] [-max <number>] [-git]"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [-local <path>] [-max <number>] [-git]"
            exit 1
            ;;
    esac
done

# Load configuration file if it exists
if [ -f "$CONFIG_FILE" ]; then
    CONFIG_BACKUP_DIR=$(yq '.backup_dir' "$CONFIG_FILE" | tr -d '"')
    BACKUP_DIR=${BACKUP_DIR:-$CONFIG_BACKUP_DIR}
    MAX_BACKUPS=$(yq '.max_backups' "$CONFIG_FILE" || echo "$MAX_BACKUPS")
    USE_GIT=$(yq '.use_git' "$CONFIG_FILE" || echo "$USE_GIT")
    GIT_REPO_URL=$(yq '.git_repo_url' "$CONFIG_FILE" || echo "$GIT_REPO_URL")
fi

# Default backup directory if not set
BACKUP_DIR=${BACKUP_DIR:-$HOME/backup_system/assets/backup}

# Create backup directory if needed
mkdir -p "$BACKUP_DIR"

# Variables
DATE=$(date +"%Y-%m-%d")
BACKUP_FILE="$BACKUP_DIR/backup_$DATE.yaml"

# Perform backup
create_backup_file "$BACKUP_FILE"

# Handle Git operations
if [ "$USE_GIT" == "y" ]; then
    setup_git "$BACKUP_DIR" "$GIT_REPO_URL"
    commit_and_push "$BACKUP_DIR" "$BACKUP_FILE" "$DATE"
fi

# Cleanup old backups
cleanup_backups "$BACKUP_DIR" "$MAX_BACKUPS"

# Notify user
echo "Backup completed. Files saved to $BACKUP_DIR."
