#!/usr/bin/env bash
set -euo pipefail

# Adapted from: https://gist.github.com/peterwake/2851767e4424d11688d9a6f40149c3da

HUGO_VERSION="0.141.0"
INSTALL_BIN="/opt/homebrew/bin/hugo"

have_cmd() { command -v "$1" >/dev/null 2>&1; }

if have_cmd hugo; then
  # Example output usually starts with: "Hugo Static Site Generator v0.141.0 ..."
  if hugo version 2>/dev/null | grep -q "v${HUGO_VERSION}"; then
    echo "Hugo ${HUGO_VERSION} already installed; pinning in brew (best effort)."
    have_cmd brew && brew pin hugo >/dev/null 2>&1 || true
    exit 0
  fi
fi

# Prereqs
have_cmd brew || { echo "brew not found; run bootstrap step 2 first."; exit 1; }
have_cmd git  || { echo "git not found; install it via brew first."; exit 1; }

# Ensure Go exists for building (needed for hugo build)
if ! have_cmd go; then
  echo "Go not found; installing Go via brew (best effort)."
  brew install go || { echo "Failed to install go."; exit 1; }
fi

# (Optional, but makes "brew pin hugo" work more reliably)
brew install hugo >/dev/null 2>&1 || true

WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

cd "$WORKDIR"
echo "Cloning Hugo v${HUGO_VERSION}..."
git clone --branch "v${HUGO_VERSION}" --depth 1 https://github.com/gohugoio/hugo.git
cd hugo

COMMIT_HASH="$(git rev-parse HEAD)"
BUILD_DATE="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

echo "Building Hugo ${HUGO_VERSION} (extended)..."
go build -tags extended -ldflags "-s -w \
  -X github.com/gohugoio/hugo/common/hugo.commitHash=${COMMIT_HASH} \
  -X github.com/gohugoio/hugo/common/hugo.buildDate=${BUILD_DATE} \
  -X github.com/gohugoio/hugo/common/hugo.vendorInfo=brew" \
  -o hugo

echo "Installing to ${INSTALL_BIN}..."

TARGET_DIR="$(dirname "$INSTALL_BIN")"
if [ ! -w "$TARGET_DIR" ]; then
  echo "Error: $TARGET_DIR is not writable. Run once with sudo or change INSTALL_BIN to a user-writable path." >&2
  exit 1
fi

if [ -f "$INSTALL_BIN" ]; then
  ts="$(date +%Y%m%d%H%M%S)"
  mv "$INSTALL_BIN" "${INSTALL_BIN}.bak.${ts}"
fi

mv hugo "$INSTALL_BIN"
chmod +x "$INSTALL_BIN"

echo "Verifying..."
hugo version

echo "Pinning Hugo in Homebrew..."
brew pin hugo >/dev/null 2>&1 || true

echo "Done."
