#!/usr/bin/env sh
set -eu

# Archiverse setup (macOS/Linux)
# - Installs uv if missing
# - Runs uv sync
# - Creates config.yaml from template if missing

cd "$(dirname "$0")"

echo ""
echo "=== Archiverse setup (macOS/Linux) ==="
echo ""

if command -v uv >/dev/null 2>&1; then
  echo "[OK] uv is already installed."
else
  echo "[..] uv not found. Installing..."
  # Official installer: https://docs.astral.sh/uv/getting-started/installation/
  if command -v curl >/dev/null 2>&1; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
  elif command -v wget >/dev/null 2>&1; then
    wget -qO- https://astral.sh/uv/install.sh | sh
  else
    echo "[ERR] Neither curl nor wget found. Install uv manually:"
    echo "      https://docs.astral.sh/uv/getting-started/installation/"
    exit 1
  fi

  # Try common install locations for this script run.
  UV_BIN=""
  for d in "$HOME/.local/bin" "$HOME/.cargo/bin" "/usr/local/bin"; do
    if [ -x "$d/uv" ]; then
      UV_BIN="$d"
      break
    fi
  done
  if [ -n "$UV_BIN" ]; then
    PATH="$UV_BIN:$PATH"
    export PATH
  fi

  # Verify
  if ! command -v uv >/dev/null 2>&1; then
    echo "[ERR] uv installed but is not on PATH in this shell."
    echo ""
    echo "Add uv to PATH, then reopen your terminal:"
    echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo ""
    echo "To persist on Linux/macOS, add to your shell profile (e.g. ~/.bashrc, ~/.zshrc):"
    echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
    exit 1
  fi
  echo "[OK] uv installed and reachable."
fi

echo ""
uv sync

if [ ! -f "config.yaml" ]; then
  cp "config.yaml.template" "config.yaml"
  echo "[OK] Created config.yaml from template."
fi

echo ""
echo "Installation completed successfully!"
echo "Try:"
echo "  uv run archiverse --help"
echo ""

# Persist uv path for future shells (idempotent).
PATH_LINE='export PATH="$HOME/.local/bin:$PATH"'
PROFILE_TARGET=""
if [ -n "${ZSH_VERSION:-}" ]; then
  PROFILE_TARGET="$HOME/.zshrc"
elif [ -n "${BASH_VERSION:-}" ]; then
  PROFILE_TARGET="$HOME/.bashrc"
elif [ -f "$HOME/.zshrc" ]; then
  PROFILE_TARGET="$HOME/.zshrc"
else
  PROFILE_TARGET="$HOME/.bashrc"
fi

if [ ! -f "$PROFILE_TARGET" ]; then
  : > "$PROFILE_TARGET"
fi

if ! grep -Fq "$PATH_LINE" "$PROFILE_TARGET"; then
  printf '\n%s\n' "$PATH_LINE" >> "$PROFILE_TARGET"
  echo "[OK] Added uv PATH to $PROFILE_TARGET"
else
  echo "[OK] uv PATH already present in $PROFILE_TARGET"
fi

echo "Open a new terminal (or run: source \"$PROFILE_TARGET\") to reload PATH."
echo ""

