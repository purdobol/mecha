#!/usr/bin/env bash

set -euo pipefail

# ============================================================
# Dotfiles - pull configuration from this machine
# ============================================================

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

echo "Pulling configuration into:"
echo "  $REPO_DIR"
echo

# ------------------------------------------------------------
# Create repository directories
# ------------------------------------------------------------

mkdir -p \
    "$REPO_DIR/home" \
    "$REPO_DIR/config" \
    "$REPO_DIR/omarchy/hooks" \
    "$REPO_DIR/system/keyd"

# ------------------------------------------------------------
# Home files
# ------------------------------------------------------------

echo "== Home files =="

HOME_FILES=(
    ".bashrc"
    ".bash_profile"
    ".profile"
    ".zshrc"
    ".zprofile"
    ".gitconfig"
    ".gitignore_global"
    ".inputrc"
)

for file in "${HOME_FILES[@]}"; do

    source="$HOME/$file"
    destination="$REPO_DIR/home/$file"

    if [[ -f "$source" ]]; then
        cp -a "$source" "$destination"
        echo "  $file"
    fi

done

# ------------------------------------------------------------
# Doom Emacs
# ------------------------------------------------------------

echo
echo "== Doom Emacs =="

if [[ -d "$HOME/.config/doom" ]]; then

    rsync -a --delete \
        "$HOME/.config/doom/" \
        "$REPO_DIR/config/doom/"

    echo "  ~/.config/doom"
else
    echo "  Not found: ~/.config/doom"
fi

# ------------------------------------------------------------
# Omarchy / Hyprland
# ------------------------------------------------------------

echo
echo "== Omarchy / Hyprland =="

if [[ -d "$HOME/.config/hypr" ]]; then

    rsync -a --delete \
        "$HOME/.config/hypr/" \
        "$REPO_DIR/omarchy/hypr/"

    echo "  ~/.config/hypr"
else
    echo "  Not found: ~/.config/hypr"
fi

# ------------------------------------------------------------
# Omarchy hooks
# ------------------------------------------------------------

echo
echo "== Omarchy hooks =="

OMARCHY_THEME_SET="$HOME/.config/omarchy/hooks/theme-set"

if [[ -f "$OMARCHY_THEME_SET" ]]; then

    cp -a \
        "$OMARCHY_THEME_SET" \
        "$REPO_DIR/omarchy/hooks/theme-set"

    echo "  ~/.config/omarchy/hooks/theme-set"

else
    echo "  Not found: ~/.config/omarchy/hooks/theme-set"
fi

# ------------------------------------------------------------
# keyd
# ------------------------------------------------------------

echo
echo "== keyd =="

if [[ -f "/etc/keyd/default.conf" ]]; then

    sudo cp \
        "/etc/keyd/default.conf" \
        "$REPO_DIR/system/keyd/default.conf"

    echo "  /etc/keyd/default.conf"
else
    echo "  Not found: /etc/keyd/default.conf"
fi

# ------------------------------------------------------------
# Done
# ------------------------------------------------------------

echo
echo "Pull complete."
echo
echo "Review:"
echo
echo "  cd \"$REPO_DIR\""
echo "  git status"
echo
