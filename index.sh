#!/usr/bin/env bash
set -euo pipefail

PACKAGES=(
  coreutils
  git
  openssh
  nodejs
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

# Git config defaults (quiet)
if ! git config --global user.name >/dev/null 2>&1; then
  git config --global user.name "termux-user" >/dev/null 2>&1 || true
fi
if ! git config --global user.email >/dev/null 2>&1; then
  git config --global user.email "user@local" >/dev/null 2>&1 || true
fi

# Brief verification output
command -v node >/dev/null 2>&1 && printf "node: %s\n" "$(node -v)"
command -v npm >/dev/null 2>&1 && printf "npm: %s\n" "$(npm -v)"
command -v yarn >/dev/null 2>&1 && printf "yarn: %s\n" "$(yarn -v)"
command -v git >/dev/null 2>&1 && printf "git: %s\n" "$(git --version)"

printf "Done\n"
