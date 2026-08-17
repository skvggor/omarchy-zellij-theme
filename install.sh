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
mkdir -p "$HOOKS_DIR/theme-set.d"

# Migrate legacy single-file hook (pre-Omarchy 4) if present
if [[ -f "$HOOKS_DIR/theme-set" ]] && grep -q "omarchy-zellij" "$HOOKS_DIR/theme-set" 2>/dev/null; then
  echo "[2/5] Migrating legacy theme-set hook to theme-set.d/..."
  if [[ -L "$HOOKS_DIR/theme-set" ]]; then
    rm "$HOOKS_DIR/theme-set"
  else
    sed -i '/# --- omarchy-zellij-theme integration (start) ---/,/# --- omarchy-zellij-theme integration (end) ---/d' "$HOOKS_DIR/theme-set"
  fi
fi

HOOK_TARGET="$HOOKS_DIR/theme-set.d/omarchy-zellij-theme"
if [[ -L "$HOOK_TARGET" || -f "$HOOK_TARGET" ]]; then
  rm "$HOOK_TARGET"
fi
ln -s "$SCRIPT_DIR/theme-set" "$HOOK_TARGET"
echo "[2/5] Installed hook -> $HOOK_TARGET"

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
CURRENT_THEME=$(cat "$HOME/.local/state/omarchy/current/theme.name" 2>/dev/null || echo "")
if [[ -n "$CURRENT_THEME" ]]; then
  echo "[5/5] Applying current theme '$CURRENT_THEME' to Zellij..."
  omarchy theme refresh
  echo "[5/5] Done! Theme injected inline into config.kdl (hot-reload enabled)."
else
  echo "[5/5] No current theme found. Theme will sync on next omarchy theme set."
fi

echo ""
echo "=== Installation complete ==="
echo "To revert, run: $SCRIPT_DIR/uninstall.sh"
