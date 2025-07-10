#!/usr/bin/env bash

set -e

CONFIG_DIR="$HOME/.config/sublime-text/Packages/User"
INSTALLED_PKGS="$HOME/.config/sublime-text/Installed Packages"
PREF_FILE="$CONFIG_DIR/Preferences.sublime-settings"
PKG_CTRL_FILE="$CONFIG_DIR/Package Control.sublime-settings"

mkdir -p "$CONFIG_DIR"
mkdir -p "$INSTALLED_PKGS"

# Step 1: Ensure Package Control is installed
if [ ! -f "$INSTALLED_PKGS/Package Control.sublime-package" ]; then
  echo "📦 Installing Package Control..."
  curl -fsSL https://packagecontrol.io/Package%20Control.sublime-package \
    -o "$INSTALLED_PKGS/Package Control.sublime-package"
fi

# Step 2: Request Brogrammer to be installed
echo "🧩 Configuring Package Control to install Brogrammer..."
cat > "$PKG_CTRL_FILE" <<EOF
{
  "installed_packages": [
    "Package Control",
    "Brogrammer"
  ]
}
EOF

# Step 3: Use fallback preferences for first launch
echo "⚙️ Setting fallback preferences (no theme yet)..."
cat > "$PREF_FILE" <<EOF
{
  "translate_tabs_to_spaces": true,
  "tab_size": 2,
  "word_wrap": true
}
EOF

# Step 4: Prompt user to launch Sublime so it installs Brogrammer
echo ""
echo "🚀 Please now start Sublime Text manually."
echo "   It will install the Brogrammer theme automatically."
echo "   Then re-run this script to apply the theme."

# Step 5: Optional auto-apply theme after installation
read -p "❓ Do you want me to auto-apply Brogrammer theme if installed now? [y/N] " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
  THEME_PATH="$HOME/.config/sublime-text/Packages/Brogrammer/Brogrammer.tmTheme"
  if [ -f "$THEME_PATH" ]; then
    echo "🎨 Brogrammer theme found. Applying it now..."
    cat > "$PREF_FILE" <<EOF
{
  "theme": "Brogrammer.sublime-theme",
  "color_scheme": "Packages/Brogrammer/Brogrammer.tmTheme",
  "translate_tabs_to_spaces": false,
  "tab_size": 2,
  "word_wrap": true
}
EOF
    echo "✅ Theme applied! Restart Sublime to see it."
  else
    echo "❌ Theme file still not found at: $THEME_PATH"
    echo "ℹ️ Make sure Sublime is launched so it can install Brogrammer."
  fi
fi
