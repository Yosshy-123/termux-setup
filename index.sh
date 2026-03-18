#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

_on_error() {
  local exit_code=$?
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: Exit $exit_code at line ${BASH_LINENO[0]}" >&2
  exit "$exit_code"
}
trap _on_error ERR

_on_interrupt() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] INTERRUPTED"
  exit 130
}
trap _on_interrupt INT TERM

log() {
  printf '[%s] %s\n' "$(date +'%Y-%m-%d %H:%M:%S')" "$*"
}

if ! command -v pkg >/dev/null 2>&1; then
  log "pkg not found; aborting"
  exit 1
fi

log "running pkg update/upgrade"
if ! pkg update -y; then
  log "pkg update failed; attempting apt update"
  apt update -y || log "apt update failed"
fi
pkg upgrade -y || log "pkg upgrade returned non-zero"

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

install_with_retries() {
  local pkgname=$1
  local max_attempts=3
  local attempt=1
  local backoff=2

  while (( attempt <= max_attempts )); do
    log "installing ${pkgname} (attempt ${attempt}/${max_attempts})"
    if pkg install -y "${pkgname}"; then
      log "installed ${pkgname} via pkg"
      return 0
    fi

    log "pkg install ${pkgname} failed; trying apt"
    if apt install -y "${pkgname}"; then
      log "installed ${pkgname} via apt"
      return 0
    fi

    log "install ${pkgname} failed on attempt ${attempt}"
    (( attempt++ ))
    sleep $(( backoff ** attempt )) 2>/dev/null || sleep 2
  done

  log "failed to install ${pkgname} after ${max_attempts} attempts"
  return 1
}

for p in "${PACKAGES[@]}"; do
  log "-> $p"
  if ! install_with_retries "$p"; then
    log "skipping ${p}"
  fi
done

log "done"
exit 0
