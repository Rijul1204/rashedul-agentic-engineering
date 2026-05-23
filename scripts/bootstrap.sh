#!/usr/bin/env bash
# bootstrap.sh — one-liner installer for rashedul-agentic-engineering.
#
# Clones the repo to a stable location and runs scripts/install.sh from there.
# Designed to be piped from curl, so subsequent `git pull` keeps every
# symlinked skill / agent up to date with zero extra work.
#
# Usage (one-liner — paste in any shell):
#
#   curl -fsSL https://raw.githubusercontent.com/Rijul1204/rashedul-agentic-engineering/main/scripts/bootstrap.sh | bash
#
# Override defaults via environment variables (set them BEFORE the pipe):
#
#   INSTALL_DIR=~/work/agentic-engineering curl ... | bash   # clone elsewhere
#   BRANCH=develop curl ... | bash                            # try a non-main branch
#   REPO_URL=https://github.com/<fork>/<repo>.git curl ... | bash  # install from a fork
#
# Pass flags through to install.sh by adding them after `bash -s --`:
#
#   curl ... | bash -s -- --copy
#   curl ... | bash -s -- --only skills --dry-run
#   curl ... | bash -s -- --target ~/Projects/my-app
#
# After bootstrap, the cloned repo lives at $INSTALL_DIR (default
# ~/.claude/rashedul-agentic-engineering/). Update later with:
#
#   git -C ~/.claude/rashedul-agentic-engineering pull
#
# That single command refreshes every symlinked skill / agent system-wide.

set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/Rijul1204/rashedul-agentic-engineering.git}"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.claude/rashedul-agentic-engineering}"
BRANCH="${BRANCH:-main}"

if ! command -v git >/dev/null 2>&1; then
  echo "error: git is required but not installed" >&2
  exit 1
fi

# Clone fresh if INSTALL_DIR is empty; pull if it's already a clone of this
# repo; refuse if it's something else (don't trash unrelated user files).
if [[ ! -d "$INSTALL_DIR/.git" ]]; then
  if [[ -e "$INSTALL_DIR" ]]; then
    echo "error: $INSTALL_DIR exists but isn't a git repo. Refusing to overwrite." >&2
    echo "       Remove or back up that path, or set INSTALL_DIR=<other-path>." >&2
    exit 1
  fi
  echo "==> cloning $REPO_URL -> $INSTALL_DIR (branch: $BRANCH)"
  mkdir -p "$(dirname "$INSTALL_DIR")"
  git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$INSTALL_DIR"
else
  echo "==> $INSTALL_DIR already exists; fetching + pulling $BRANCH"
  git -C "$INSTALL_DIR" fetch --quiet origin "$BRANCH"
  git -C "$INSTALL_DIR" checkout --quiet "$BRANCH"
  git -C "$INSTALL_DIR" pull --quiet --ff-only origin "$BRANCH"
fi

if [[ ! -x "$INSTALL_DIR/scripts/install.sh" ]]; then
  echo "error: $INSTALL_DIR/scripts/install.sh missing or not executable" >&2
  exit 1
fi

echo "==> running scripts/install.sh $*"
cd "$INSTALL_DIR"
./scripts/install.sh "$@"

echo ""
echo "Bootstrap complete."
echo "  Source clone: $INSTALL_DIR"
echo "  Update later: git -C $INSTALL_DIR pull"
