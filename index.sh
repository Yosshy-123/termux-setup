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

pkg update >/dev/null 2>&1 || true
pkg upgrade >/dev/null 2>&1 || true

for p in "${PACKAGES[@]}"; do
  if pkg install -y "$p" >/dev/null 2>&1; then
    printf "%s: installed\n" "$p"
  else
    printf "ERROR: %s failed to install\n" "$p" >&2
  fi
done

if command -v npm >/dev/null 2>&1; then
  export NPM_PREFIX="$HOME/.npm-global"
  mkdir -p "$NPM_PREFIX"
  npm config set prefix "$NPM_PREFIX" >/dev/null 2>&1 || true
fi

SHELL_RC=""
if [ -n "${ZDOTDIR-}" ]; then
  SHELL_RC="$ZDOTDIR/.zshrc"
elif [ -f "$HOME/.zshrc" ]; then
  SHELL_RC="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then
  SHELL_RC="$HOME/.bashrc"
else
  SHELL_RC="$HOME/.profile"
fi

mkdir -p "$(dirname "$SHELL_RC")"
: > "$SHELL_RC"

grep -qxF 'export PATH="$HOME/.npm-global/bin:$PATH"' "$SHELL_RC" 2>/dev/null \
  || printf '\n# npm global path\nexport PATH="$HOME/.npm-global/bin:$PATH"\n' >> "$SHELL_RC"

printf "Done\n"
