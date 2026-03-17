#!/usr/bin/env bash
set -euo pipefail

timestamp() { date '+%Y-%m-%d %H:%M:%S'; }

ts_prefix() {
  while IFS= read -r line || [ -n "$line" ]; do
    printf '%s %s\n' "$(timestamp)" "$line"
  done
}

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

pkg update 2>&1 | ts_prefix || true
pkg upgrade 2>&1 | ts_prefix || true

for p in "${PACKAGES[@]}"; do
  if pkg install -y "$p" 2>&1 | ts_prefix; then
    printf '%s %s: installed\n' "$(timestamp)" "$p"
  else
    rc=${PIPESTATUS[0]:-1}
    printf '%s ERROR: %s failed to install (exit %d)\n' "$(timestamp)" "$p" "$rc" >&2
  fi
done

if command -v npm >/dev/null 2>&1; then
  export NPM_PREFIX="$HOME/.npm-global"
  mkdir -p "$NPM_PREFIX"
  npm config set prefix "$NPM_PREFIX" 2>&1 | ts_prefix || true
  printf '%s npm configured with prefix %s\n' "$(timestamp)" "$NPM_PREFIX"
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

printf '%s Done\n' "$(timestamp)"
