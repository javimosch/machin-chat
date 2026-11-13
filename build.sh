#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
MDK_DESKTOP="${MDK_DESKTOP:-$HOME/ai/machin-desktop}"
[[ -f "$MDK_DESKTOP/mdk" ]] || { echo "build: machin-desktop not found" >&2; exit 1; }
mkdir -p build
exec "$MDK_DESKTOP/mdk" build app/ -o "$PWD/build/machin-chat"
