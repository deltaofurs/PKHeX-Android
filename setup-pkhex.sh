#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PIN_FILE="$ROOT/PKHEX_COMMIT.txt"
PKHEX_DIR="$ROOT/PKHeX"

if [[ ! -f "$PIN_FILE" ]]; then
  echo "Missing $PIN_FILE" >&2
  exit 1
fi

PKHEX_COMMIT="${PKHEX_COMMIT:-$(tr -d '[:space:]' < "$PIN_FILE")}" 
if [[ ! "$PKHEX_COMMIT" =~ ^[0-9a-fA-F]{40}$ ]]; then
  echo "Invalid PKHeX commit SHA: $PKHEX_COMMIT" >&2
  exit 1
fi

if [[ -d "$PKHEX_DIR/.git" ]]; then
  git -C "$PKHEX_DIR" fetch --depth 1 origin "$PKHEX_COMMIT"
else
  git init "$PKHEX_DIR"
  git -C "$PKHEX_DIR" remote add origin https://github.com/kwsch/PKHeX.git
  git -C "$PKHEX_DIR" fetch --depth 1 origin "$PKHEX_COMMIT"
fi

git -C "$PKHEX_DIR" checkout --detach --force FETCH_HEAD
ACTUAL="$(git -C "$PKHEX_DIR" rev-parse HEAD)"
if [[ "$ACTUAL" != "$PKHEX_COMMIT" ]]; then
  echo "PKHeX pin mismatch: expected $PKHEX_COMMIT, got $ACTUAL" >&2
  exit 1
fi

echo "PKHeX.Core ready at $ACTUAL"
