#!/bin/bash

# Default values
BACKUP_DIR="$HOME/system_backup"
MAX_BACKUPS=7
USE_GIT=false

# Function to display help
function show_help() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -local <path>     Set the backup directory (default: $HOME/system_backup)"
    echo "  -max <number>     Set the maximum number of backups (default: 7)"
    echo "  -git              Enable git for backups"
    echo "  -help             Show this help message"
}

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
            USE_GIT=true
            shift
            ;;
        -help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Create the backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Variables
DATE=$(date +"%Y-%m-%d")
BACKUP_FILE="$BACKUP_DIR/backup_$DATE.yaml"

# Create the YAML backup file (single file)
echo "date: $DATE" > "$BACKUP_FILE"
echo "packages:" >> "$BACKUP_FILE"
dpkg --get-selections | awk '{print "- " $1}' >> "$BACKUP_FILE"
echo "snap_packages:" >> "$BACKUP_FILE"
snap list | awk 'NR>1 {print "- " $1}' >> "$BACKUP_FILE"
echo "flatpak_packages:" >> "$BACKUP_FILE"
flatpak list --columns=name | awk '{print "- " $1}' >> "$BACKUP_FILE"
echo "dconf_settings: |" >> "$BACKUP_FILE"
dconf dump / | sed 's/^/  /' >> "$BACKUP_FILE"

# Git operations
if [ "$USE_GIT" = true ]; then
    cd "$BACKUP_DIR"
    if [ ! -d ".git" ]; then
        echo "Initializing Git repository in $BACKUP_DIR"
        git init
        read -p "Enter the remote Git repository URL: " REPO_URL
        git remote add origin "$REPO_URL"
        git branch -M main
        git push --set-upstream origin main
    fi

    # Configure Git user if not already configured
    if ! git config user.name >/dev/null; then
        read -p "Enter your Git user name: " GIT_NAME
        git config --global user.name "$GIT_NAME"
    fi

    if ! git config user.email >/dev/null; then
        read -p "Enter your Git user email: " GIT_EMAIL
        git config --global user.email "$GIT_EMAIL"
    fi

    # Add and commit changes
    git add "$BACKUP_FILE"
    git commit -m "Backup $DATE"

    # Push changes
    git push
fi

# Remove old backups
if [ "$(ls -1 "$BACKUP_DIR"/*.yaml | wc -l)" -gt "$MAX_BACKUPS" ]; then
    ls -t "$BACKUP_DIR"/*.yaml | tail -n +$((MAX_BACKUPS + 1)) | xargs -I {} rm "{}"
fi

# Done
echo "Backup completed. Files saved to $BACKUP_DIR."
