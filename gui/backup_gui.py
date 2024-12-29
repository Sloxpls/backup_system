import tkinter as tk
from tkinter import messagebox, filedialog
import yaml

CONFIG_FILE = "~/.config/system_backup/config.yaml"

def load_config():
    try:
        with open(CONFIG_FILE, "r") as file:
            return yaml.safe_load(file)
    except FileNotFoundError:
        return {
            "backup_dir": "~/system_backup",
            "max_backups": 7,
            "backup_locations": ["local", "github"]
        }

def save_config(config):
    with open(CONFIG_FILE, "w") as file:
        yaml.dump(config, file)
    messagebox.showinfo("Success", "Configuration saved successfully!")

def browse_directory(entry):
    directory = filedialog.askdirectory()
    if directory:
        entry.delete(0, tk.END)
        entry.insert(0, directory)

def create_gui():
    config = load_config()

    def save_changes():
        config["backup_dir"] = backup_dir_entry.get()
        config["max_backups"] = int(max_backups_entry.get())
        config["backup_locations"] = [loc for loc, val in backup_vars.items() if val.get()]
        save_config(config)

    root = tk.Tk()
    root.title("Backup Configuration")

    tk.Label(root, text="Backup Directory:").grid(row=0, column=0, padx=10, pady=5, sticky="w")
    backup_dir_entry = tk.Entry(root, width=40)
    backup_dir_entry.grid(row=0, column=1, padx=10, pady=5)
    backup_dir_entry.insert(0, config["backup_dir"])
    tk.Button(root, text="Browse", command=lambda: browse_directory(backup_dir_entry)).grid(row=0, column=2, padx=10, pady=5)

    tk.Label(root, text="Max Backups:").grid(row=1, column=0, padx=10, pady=5, sticky="w")
    max_backups_entry = tk.Entry(root, width=40)
    max_backups_entry.grid(row=1, column=1, padx=10, pady=5)
    max_backups_entry.insert(0, config["max_backups"])

    tk.Label(root, text="Backup Locations:").grid(row=2, column=0, padx=10, pady=5, sticky="w")
    backup_vars = {}
    locations = ["local", "github"]
    for i, loc in enumerate(locations):
        var = tk.BooleanVar(value=(loc in config["backup_locations"]))
        backup_vars[loc] = var
        tk.Checkbutton(root, text=loc, variable=var).grid(row=2+i, column=1, sticky="w")

    tk.Button(root, text="Save", command=save_changes).grid(row=4+len(locations), column=1, pady=10)

    root.mainloop()

if __name__ == "__main__":
    create_gui()

