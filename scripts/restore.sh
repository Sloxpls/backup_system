#!/bin/bash

# Default values
CONFIG_FILE="$HOME/.config/system_backup/config.yaml"
BACKUP_DIR=""
RESTORE_FILE=""

# Function to display help
function show_help() {
    echo "Usage: $0 [-file <path_to_file>]"
    echo "Options:"
    echo "  -file <path_to_file>   Specify the backup file to restore from."
    echo "  -help                  Show this help message."
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -file)
            RESTORE_FILE="$2"
            shift 2
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

# Load configuration file
if [ -f "$CONFIG_FILE" ]; then
    BACKUP_DIR=$(yq '.backup_dir' "$CONFIG_FILE" | tr -d '"')
else
    echo "Configuration file not found. Ensure $CONFIG_FILE exists."
    exit 1
fi

# Ensure backup directory is set
BACKUP_DIR=${BACKUP_DIR:-"$HOME/backup_system/assets/backup"}
if [ ! -d "$BACKUP_DIR" ]; then
    echo "Backup directory not found: $BACKUP_DIR"
    exit 1
fi

# Determine the restore file
if [ -z "$RESTORE_FILE" ]; then
    RESTORE_FILE=$(ls -t "$BACKUP_DIR"/*.yaml 2>/dev/null | head -n 1)
    if [ -z "$RESTORE_FILE" ]; then
        echo "No backup files found in $BACKUP_DIR."
        exit 1
    fi
fi

# Validate the specified restore file
if [ ! -f "$RESTORE_FILE" ]; then
    echo "Specified restore file does not exist: $RESTORE_FILE"
    exit 1
fi

# Begin restore process
echo "Restoring from file: $RESTORE_FILE"

# Restore packages
echo "Restoring apt packages..."
yq '.packages[]' "$RESTORE_FILE" | xargs sudo apt install -y

echo "Restoring snap packages..."
yq '.snap_packages[]' "$RESTORE_FILE" | xargs sudo snap install

echo "Restoring flatpak packages..."
yq '.flatpak_packages[]' "$RESTORE_FILE" | while read -r flatpak; do
    if [[ "$flatpak" == *"."* ]]; then
        flatpak install -y "$flatpak"
    else
        echo "Skipping invalid Flatpak package: $flatpak"
    fi
done


# Restore dconf settings
echo "Restoring dconf settings..."
yq '.dconf_settings' "$RESTORE_FILE" | dconf load /

echo "Restore process completed."
