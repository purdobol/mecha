#!/usr/bin/env bash

set -euo pipefail

# ============================================================
# Dotfiles - install repository configuration
# ============================================================

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

TIMESTAMP="$(date '+%Y-%m-%d-%H%M%S')"
BACKUP_DIR="$HOME/.dotfiles-backup/$TIMESTAMP"

echo
echo "============================================================"
echo " Dotfiles installer"
echo "============================================================"
echo
echo "Repository:"
echo "  $REPO_DIR"
echo
echo "Backup:"
echo "  $BACKUP_DIR"
echo

# ------------------------------------------------------------
# Backup helper
# ------------------------------------------------------------

backup_file() {
    local source="$1"
    local backup="$2"

    if [[ -e "$source" || -L "$source" ]]; then
        mkdir -p "$(dirname "$backup")"
        cp -a "$source" "$backup"
        echo "    Backup: $source"
    fi
}

# ------------------------------------------------------------
# Home files
# ------------------------------------------------------------

echo "== Home files =="

if [[ -d "$REPO_DIR/home" ]]; then

    found=0

    for file in "$REPO_DIR/home/"*; do
        [[ -f "$file" ]] || continue

        found=1

        name="$(basename "$file")"
        destination="$HOME/$name"

        echo "  Installing $name"

        if [[ -e "$destination" || -L "$destination" ]]; then
            backup_file \
                "$destination" \
                "$BACKUP_DIR/home/$name"
        fi

        cp -a "$file" "$destination"
    done

    if [[ "$found" -eq 0 ]]; then
        echo "  No home files found."
    fi

else
    echo "  Directory not found: $REPO_DIR/home"
fi

# ------------------------------------------------------------
# Doom Emacs
# ------------------------------------------------------------

echo
echo "== Doom Emacs =="

if [[ -d "$REPO_DIR/config/doom" ]]; then

    mkdir -p "$HOME/.config/doom"

    echo "  Installing → ~/.config/doom"

    while IFS= read -r -d '' file; do

        relative="${file#$REPO_DIR/config/doom/}"
        destination="$HOME/.config/doom/$relative"

        if [[ -e "$destination" || -L "$destination" ]]; then
            backup_file \
                "$destination" \
                "$BACKUP_DIR/config/doom/$relative"
        fi

    done < <(find "$REPO_DIR/config/doom" -type f -print0)

    rsync -a \
        "$REPO_DIR/config/doom/" \
        "$HOME/.config/doom/"

    echo "  Done."

else
    echo "  Not found: $REPO_DIR/config/doom"
fi

# ------------------------------------------------------------
# Omarchy / Hyprland
# ------------------------------------------------------------

echo
echo "== Omarchy / Hyprland =="

if [[ -d "$REPO_DIR/omarchy/hypr" ]]; then

    mkdir -p "$HOME/.config/hypr"

    echo "  Installing → ~/.config/hypr"

    while IFS= read -r -d '' file; do

        relative="${file#$REPO_DIR/omarchy/hypr/}"
        destination="$HOME/.config/hypr/$relative"

        if [[ -e "$destination" || -L "$destination" ]]; then
            backup_file \
                "$destination" \
                "$BACKUP_DIR/omarchy/hypr/$relative"
        fi

    done < <(find "$REPO_DIR/omarchy/hypr" -type f -print0)

    rsync -a \
        "$REPO_DIR/omarchy/hypr/" \
        "$HOME/.config/hypr/"

    echo "  Done."

else
    echo "  Not found: $REPO_DIR/omarchy/hypr"
fi

# ------------------------------------------------------------
# Omarchy hooks
# ------------------------------------------------------------

echo
echo "== Omarchy hooks =="

THEME_SET="$REPO_DIR/omarchy/hooks/theme-set"

if [[ -f "$THEME_SET" ]]; then

    destination="$HOME/.config/omarchy/hooks/theme-set"

    echo "  Installing:"
    echo "    $destination"

    if [[ -e "$destination" || -L "$destination" ]]; then
        backup_file \
            "$destination" \
            "$BACKUP_DIR/omarchy/hooks/theme-set"
    fi

    mkdir -p "$HOME/.config/omarchy/hooks"

    cp -a \
        "$THEME_SET" \
        "$destination"

    echo "  Done."

else
    echo "  Not found:"
    echo "    $THEME_SET"
fi

# ------------------------------------------------------------
# keyd
# ------------------------------------------------------------

echo
echo "== keyd =="

KEYD_CONFIG="$REPO_DIR/system/keyd/default.conf"

if [[ -f "$KEYD_CONFIG" ]]; then

    echo "  Installing → /etc/keyd/default.conf"

    if sudo test -e /etc/keyd/default.conf; then

        sudo mkdir -p "$BACKUP_DIR/system/keyd"

        sudo cp -a \
            /etc/keyd/default.conf \
            "$BACKUP_DIR/system/keyd/default.conf"

        echo "    Backup: /etc/keyd/default.conf"
    fi

    sudo mkdir -p /etc/keyd

    sudo cp -a \
        "$KEYD_CONFIG" \
        /etc/keyd/default.conf

    echo "  Done."

    # Reload keyd
    if command -v systemctl >/dev/null 2>&1; then
        if systemctl list-unit-files keyd.service >/dev/null 2>&1; then
            echo "  Restarting keyd..."
            sudo systemctl restart keyd.service || true
        fi
    fi

else
    echo "  Not found:"
    echo "    $KEYD_CONFIG"
fi

# ------------------------------------------------------------
# Done
# ------------------------------------------------------------

echo
echo "============================================================"
echo " Installation complete"
echo "============================================================"
echo

if [[ -d "$BACKUP_DIR" ]]; then
    echo "Backups were created in:"
    echo "  $BACKUP_DIR"
    echo
fi

echo "Repository:"
echo "  $REPO_DIR"
echo
