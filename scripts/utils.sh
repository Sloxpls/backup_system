#!/bin/bash

function create_backup_file() {
    local backup_file=$1
    echo "Creating backup file at $backup_file..."
    echo "date: $(date +"%Y-%m-%d")" > "$backup_file"
    echo "packages:" >> "$backup_file"
    dpkg --get-selections | awk '{print "- " $1}' >> "$backup_file"
    echo "snap_packages:" >> "$backup_file"
    snap list | awk 'NR>1 {print "- " $1}' >> "$backup_file"
    echo "flatpak_packages:" >> "$backup_file"
    flatpak list --columns=application | awk '{print "- " $1}' >> "$BACKUP_FILE"
    echo "dconf_settings: |" >> "$BACKUP_FILE"
    dconf dump / | sed '/^$/d' | sed 's/^/  /' >> "$BACKUP_FILE"

}

function cleanup_backups() {
    local backup_dir=$1
    local max_backups=$2
    if [ "$(ls -1 "$backup_dir"/*.yaml 2>/dev/null | wc -l)" -gt "$max_backups" ]; then
        ls -t "$backup_dir"/*.yaml | tail -n +$((max_backups + 1)) | xargs -I {} rm "{}"
        echo "Old backups removed, keeping only the last $max_backups backups."
    fi
}


function setup_git() {
    local backup_dir=$1
    local repo_url=$2

    cd "$backup_dir" || exit 1

    if [ ! -d ".git" ]; then
        echo "Initializing Git repository in $backup_dir"
        git init
        git remote add origin "$repo_url"
        git branch -M main
        git push --set-upstream origin main
    fi
}

function commit_and_push() {
    local backup_dir=$1
    local backup_file=$2
    local date=$3

    cd "$backup_dir" || exit 1
    git add "$backup_file"
    git commit -m "Backup $date"
    git push
}


