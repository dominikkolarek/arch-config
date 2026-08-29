#!/usr/bin/env bash
#
# Restores this Arch + Hyprland setup onto a fresh install.
#
# Assumes: Arch is already installed and booting, you have a user account
# with sudo, and you are connected to the internet.
#
# Does NOT handle: partitioning, bootloader, fstab, swap, snapper.
# Those are hardware-specific and documented in README.md.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"

info()  { printf '\033[1;32m::\033[0m %s\n' "$1"; }
warn()  { printf '\033[1;33m!!\033[0m %s\n' "$1"; }
error() { printf '\033[1;31mXX\033[0m %s\n' "$1" >&2; }

if [[ $EUID -eq 0 ]]; then
    error "Do not run this as root. It installs into your home directory."
    exit 1
fi

# --- 1. official packages -------------------------------------------------

if [[ -f "$REPO_DIR/packages/pacman.txt" ]]; then
    info "Installing official packages"
    sudo pacman -S --needed --noconfirm - < "$REPO_DIR/packages/pacman.txt"
else
    warn "packages/pacman.txt not found, skipping"
fi

# --- 2. AUR helper --------------------------------------------------------

if ! command -v yay >/dev/null 2>&1; then
    info "Installing yay"
    tmp="$(mktemp -d)"
    git clone --depth 1 https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
    (cd "$tmp/yay-bin" && makepkg -si --noconfirm)
    rm -rf "$tmp"
fi

# --- 3. AUR packages ------------------------------------------------------

if [[ -s "$REPO_DIR/packages/aur.txt" ]]; then
    info "Installing AUR packages"
    yay -S --needed --noconfirm - < "$REPO_DIR/packages/aur.txt"
fi

# --- 4. configs -----------------------------------------------------------

info "Backing up existing configs to $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

copy_tree() {
    local src="$1" dest="$2"
    [[ -d "$src" ]] || return 0

    while IFS= read -r -d '' file; do
        local rel="${file#"$src"/}"
        local target="$dest/$rel"

        if [[ -e "$target" ]]; then
            mkdir -p "$(dirname "$BACKUP_DIR/$rel")"
            cp -a "$target" "$BACKUP_DIR/$rel"
        fi

        mkdir -p "$(dirname "$target")"
        cp -a "$file" "$target"
    done < <(find "$src" -type f -print0)
}

info "Installing dotfiles"
copy_tree "$REPO_DIR/home" "$HOME"

# scripts need to stay executable
if [[ -d "$HOME/.config/waybar/scripts" ]]; then
    chmod +x "$HOME"/.config/waybar/scripts/* 2>/dev/null || true
fi
if [[ -d "$HOME/.local/bin" ]]; then
    chmod +x "$HOME"/.local/bin/* 2>/dev/null || true
fi

# --- 5. services ----------------------------------------------------------

info "Enabling system services"
sudo systemctl enable --now NetworkManager.service 2>/dev/null || true
sudo systemctl enable --now bluetooth.service 2>/dev/null || true

info "Reloading user systemd units"
systemctl --user daemon-reload

# --- 6. done --------------------------------------------------------------

cat <<EOF

$(info "Done.")

Backup of anything overwritten: $BACKUP_DIR

Still to do by hand (see README.md):
  - swap / hibernation (resume_offset is machine-specific)
  - snapper configuration
  - secrets: SSH keys, bot config.yaml
  - log out and start Hyprland with: uwsm start hyprland

EOF
