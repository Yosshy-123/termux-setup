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

pkg update -y
pkg upgrade -y

for p in "${PACKAGES[@]}"; do
  echo "-> $p"
  pkg install -y "$p" || {
    echo "パッケージ $p のインストールに失敗しました。続行します..."
  }
done

export NPM_PREFIX="$HOME/.npm-global"
mkdir -p "$NPM_PREFIX"
npm config set prefix "$NPM_PREFIX" || true

SHELL_RC=""
if [ -n "${ZDOTDIR-}" ] || [ -f "$HOME/.zshrc" ]; then
  SHELL_RC="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ] || [ -n "${BASH_VERSION-}" ]; then
  SHELL_RC="$HOME/.bashrc"
else
  SHELL_RC="$HOME/.profile"
fi

grep -qxF 'export PATH="$HOME/.npm-global/bin:$PATH"' "$SHELL_RC" 2>/dev/null || cat >> "$SHELL_RC" <<'EOF'

# npm global path for Termux
export PATH="$HOME/.npm-global/bin:$PATH"
EOF

if ! git config --global user.name >/dev/null 2>&1; then
  git config --global user.name "termux-user"
fi
if ! git config --global user.email >/dev/null 2>&1; then
  git config --global user.email "user@local"
fi

echo "=== 動作確認 ==="
command -v node >/dev/null 2>&1 && echo "node: $(node -v)"
command -v npm >/dev/null 2>&1 && echo "npm: $(npm -v)"
command -v yarn >/dev/null 2>&1 && echo "yarn: $(yarn -v)"
command -v git >/dev/null 2>&1 && echo "git: $(git --version)"

echo "完了"
