#!/usr/bin/env bash
set -euo pipefail

PACKAGES=(
  coreutils
  git
  openssh
  nodejs-lts
  yarn
  python
  python-pip
  clang
  make
  cmake
  pkg-config
  build-essential
  curl
  wget
  vim
  htop
  ripgrep
  fd
  unzip
  zip
  git-lfs
  termux-api
)

# Update and upgrade (auto-yes)
pkg update -y >/dev/null 2>&1 || true
pkg upgrade -y >/dev/null 2>&1 || true

# Install packages; report success or failure per package
for p in "${PACKAGES[@]}"; do
  if pkg install -y "$p" >/dev/null 2>&1; then
    printf "%s: installed\n" "$p"
  else
    printf "ERROR: %s failed to install\n" "$p" >&2
  fi
done

# npm global prefix
export NPM_PREFIX="$HOME/.npm-global"
mkdir -p "$NPM_PREFIX" >/dev/null 2>&1
npm config set prefix "$NPM_PREFIX" >/dev/null 2>&1 || true

# Choose shell rc file
SHELL_RC=""
if [ -n "${ZDOTDIR-}" ] || [ -f "$HOME/.zshrc" ]; then
  SHELL_RC="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ] || [ -n "${BASH_VERSION-}" ]; then
  SHELL_RC="$HOME/.bashrc"
else
  SHELL_RC="$HOME/.profile"
fi

# Ensure npm global path is in shell rc
grep -qxF 'export PATH="$HOME/.npm-global/bin:$PATH"' "$SHELL_RC" 2>/dev/null || cat >> "$SHELL_RC" <<'EOF'

# npm global path
export PATH="$HOME/.npm-global/bin:$PATH"
EOF

printf "Done\n"
