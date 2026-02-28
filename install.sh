#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEMED_DIR="$HOME/.config/omarchy/themed"
HOOKS_DIR="$HOME/.config/omarchy/hooks"
ZELLIJ_CONFIG="$HOME/.config/zellij/config.kdl"
OLD_THEME_FILE="$HOME/.config/zellij/themes/omarchy.kdl"

echo "=== omarchy-zellij-theme installer ==="

# 1. Symlink template
mkdir -p "$THEMED_DIR"
if [[ -L "$THEMED_DIR/zellij.kdl.tpl" ]]; then
  echo "[1/5] Template symlink already exists, updating..."
  rm "$THEMED_DIR/zellij.kdl.tpl"
fi
ln -s "$SCRIPT_DIR/zellij.kdl.tpl" "$THEMED_DIR/zellij.kdl.tpl"
echo "[1/5] Symlinked template -> $THEMED_DIR/zellij.kdl.tpl"

# 2. Install hook
if [[ -f "$HOOKS_DIR/theme-set" ]]; then
  if grep -q "omarchy-zellij" "$HOOKS_DIR/theme-set" 2>/dev/null; then
    echo "[2/5] Hook already installed, updating..."
    cp "$SCRIPT_DIR/theme-set" "$HOOKS_DIR/theme-set"
  else
    echo "[2/5] Existing theme-set hook found. Appending Zellij integration..."
    echo "" >> "$HOOKS_DIR/theme-set"
    echo "# --- omarchy-zellij-theme integration (start) ---" >> "$HOOKS_DIR/theme-set"
    echo "\"$SCRIPT_DIR/theme-set\" \"\$1\"" >> "$HOOKS_DIR/theme-set"
    echo "# --- omarchy-zellij-theme integration (end) ---" >> "$HOOKS_DIR/theme-set"
  fi
else
  cp "$SCRIPT_DIR/theme-set" "$HOOKS_DIR/theme-set"
  echo "[2/5] Installed hook -> $HOOKS_DIR/theme-set"
fi
chmod +x "$HOOKS_DIR/theme-set"

# 3. Configure Zellij to use the "omarchy" theme
if [[ -f "$ZELLIJ_CONFIG" ]]; then
  if grep -q '^theme "omarchy"' "$ZELLIJ_CONFIG" 2>/dev/null; then
    echo "[3/5] Zellij config already has theme \"omarchy\", skipping."
  else
    cp "$ZELLIJ_CONFIG" "$ZELLIJ_CONFIG.bak.$(date +%s)"
    if grep -q '// theme "dracula"' "$ZELLIJ_CONFIG" 2>/dev/null; then
      sed -i 's|// theme "dracula"|theme "omarchy"|' "$ZELLIJ_CONFIG"
    elif grep -q '^// *theme ' "$ZELLIJ_CONFIG" 2>/dev/null; then
      sed -i '0,/^\/\/ *theme /{s|^// *theme .*|theme "omarchy"|}' "$ZELLIJ_CONFIG"
    else
      echo '' >> "$ZELLIJ_CONFIG"
      echo 'theme "omarchy"' >> "$ZELLIJ_CONFIG"
    fi
    echo "[3/5] Set theme \"omarchy\" in Zellij config (backup created)."
  fi
else
  echo "[3/5] WARNING: Zellij config not found at $ZELLIJ_CONFIG"
fi

# 4. Clean up old theme file from previous approach
if [[ -f "$OLD_THEME_FILE" ]]; then
  rm "$OLD_THEME_FILE"
  echo "[4/5] Removed old theme file from previous approach ($OLD_THEME_FILE)."
else
  echo "[4/5] No old theme file to clean up."
fi

# 5. Generate and inject theme into config.kdl
CURRENT_THEME=$(cat "$HOME/.config/omarchy/current/theme.name" 2>/dev/null || echo "")
if [[ -n "$CURRENT_THEME" ]]; then
  echo "[5/5] Applying current theme '$CURRENT_THEME' to Zellij..."
  omarchy-theme-set-templates
  "$HOOKS_DIR/theme-set"
  echo "[5/5] Done! Theme injected inline into config.kdl (hot-reload enabled)."
else
  echo "[5/5] No current theme found. Theme will sync on next omarchy-theme-set."
fi

echo ""
echo "=== Installation complete ==="
echo "To revert, run: $SCRIPT_DIR/uninstall.sh"
