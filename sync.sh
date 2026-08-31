#!/usr/bin/env bash
#
# Pulls the live configs on this machine back into the repo,
# so you can commit whatever you have changed since last time.
#
# Run from anywhere:  ./sync.sh

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

info() { printf '\033[1;32m::\033[0m %s\n' "$1"; }

# Config paths to track, relative to $HOME.
# Add to this list as your setup grows.
PATHS=(
    ".config/hypr"
    ".config/waybar"
    ".config/kitty"
    ".config/wofi"
    ".config/mako"
    ".config/cava"
    ".config/nano"
    ".config/fastfetch"
    ".config/environment.d"
    ".config/systemd/user"
    ".config/uwsm"
    ".config/rofi"
    ".local/bin"
    ".bashrc"
    ".bash_profile"
    ".gitconfig"
)

info "Copying live configs into repo"

for rel in "${PATHS[@]}"; do
    src="$HOME/$rel"
    [[ -e "$src" ]] || continue

    dest="$REPO_DIR/home/$rel"
    mkdir -p "$(dirname "$dest")"
    rm -rf "$dest"
    cp -a "$src" "$dest"
    printf '   %s\n' "$rel"
done

info "Regenerating package lists"

# Explicitly installed, in official repos
pacman -Qqen > "$REPO_DIR/packages/pacman.txt" || true

# Explicitly installed, foreign (AUR)
pacman -Qqem > "$REPO_DIR/packages/aur.txt" || true

printf '   %s official, %s AUR\n' \
    "$(wc -l < "$REPO_DIR/packages/pacman.txt")" \
    "$(wc -l < "$REPO_DIR/packages/aur.txt")"

info "Scrubbing check"

# Cheap guard against committing secrets. Not exhaustive.
if grep -rIl --exclude-dir=.git --exclude=sync.sh \
     -e 'gsk_[A-Za-z0-9]' \
     -e 'sk-proj-' \
     -e 'BEGIN OPENSSH PRIVATE KEY' \
     "$REPO_DIR" 2>/dev/null | grep -q .; then
    printf '\033[1;31mXX\033[0m Possible secret found in repo:\n'
    grep -rIl --exclude-dir=.git --exclude=sync.sh \
      -e 'gsk_[A-Za-z0-9]' \
      -e 'sk-proj-' \
      -e 'BEGIN OPENSSH PRIVATE KEY' \
      "$REPO_DIR" 2>/dev/null
    printf 'Remove these before committing.\n'
    exit 1
fi

info "Done. Review with 'git diff', then commit."
