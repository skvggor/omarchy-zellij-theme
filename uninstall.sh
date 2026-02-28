#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEMED_DIR="$HOME/.config/omarchy/themed"
HOOKS_DIR="$HOME/.config/omarchy/hooks"
ZELLIJ_CONFIG="$HOME/.config/zellij/config.kdl"
OLD_THEME_FILE="$HOME/.config/zellij/themes/omarchy.kdl"
START_MARKER="// --- omarchy-zellij-theme (start) ---"
END_MARKER="// --- omarchy-zellij-theme (end) ---"

echo "=== omarchy-zellij-theme uninstaller ==="

# 1. Remove template symlink
if [[ -L "$THEMED_DIR/zellij.kdl.tpl" ]]; then
  rm "$THEMED_DIR/zellij.kdl.tpl"
  echo "[1/5] Removed template symlink."
else
  echo "[1/5] Template symlink not found, skipping."
fi

# 2. Remove hook
if [[ -f "$HOOKS_DIR/theme-set" ]]; then
  if grep -q "omarchy-zellij-theme integration" "$HOOKS_DIR/theme-set" 2>/dev/null; then
    sed -i '/# --- omarchy-zellij-theme integration (start) ---/,/# --- omarchy-zellij-theme integration (end) ---/d' "$HOOKS_DIR/theme-set"
    echo "[2/5] Removed Zellij integration from existing hook."
  elif grep -q "omarchy-zellij" "$HOOKS_DIR/theme-set" 2>/dev/null; then
    rm "$HOOKS_DIR/theme-set"
    echo "[2/5] Removed theme-set hook."
  else
    echo "[2/5] Hook doesn't contain our integration, skipping."
  fi
else
  echo "[2/5] No theme-set hook found, skipping."
fi

# 3. Comment out theme in Zellij config
if [[ -f "$ZELLIJ_CONFIG" ]] && grep -q '^theme "omarchy"' "$ZELLIJ_CONFIG" 2>/dev/null; then
  sed -i 's|^theme "omarchy"|// theme "omarchy"|' "$ZELLIJ_CONFIG"
  echo "[3/5] Commented out theme in Zellij config."
else
  echo "[3/5] Theme not set in Zellij config, skipping."
fi

# 4. Remove inline theme block from config.kdl
if [[ -f "$ZELLIJ_CONFIG" ]] && grep -qF "$START_MARKER" "$ZELLIJ_CONFIG" 2>/dev/null; then
  sed -i "\%${START_MARKER}%,\%${END_MARKER}%d" "$ZELLIJ_CONFIG"
  echo "[4/5] Removed inline theme block from config.kdl."
else
  echo "[4/5] No inline theme block found, skipping."
fi

# 5. Clean up old theme file from previous approach
if [[ -f "$OLD_THEME_FILE" ]]; then
  rm "$OLD_THEME_FILE"
  echo "[5/5] Removed old theme file ($OLD_THEME_FILE)."
else
  echo "[5/5] No old theme file to clean up."
fi

echo ""
echo "=== Uninstall complete ==="
