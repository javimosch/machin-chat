#!/usr/bin/env bash
# check-chat.sh <binary> — starting is not enough for a chat app. On each
# supported Ubuntu it must:
#   - join with the room and name its fields show. 0.2.2 sent both empty, so
#     the server put people in "lobby" while the window said "general", and
#     they never saw anyone in "general". This is what fails 0.2.2.
#   - redraw when messages arrive on an idle window. A separate guard: 0.2.2
#     passes it.
set -euo pipefail
bin="$(readlink -f "${1:?usage: check-chat.sh <binary>}")"
here="$(cd "$(dirname "$0")" && pwd)"
for image in ubuntu:22.04 ubuntu:24.04; do
    echo "== $image"
    docker run --rm -v "$bin:/app:ro" -v "$here/fake_room.py:/fake_room.py:ro" "$image" bash -c '
        { apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
            libfreetype6 libharfbuzz0b libgl1 libgl1-mesa-dri fonts-dejavu-core \
            xvfb x11-apps python3; } >/dev/null 2>&1 || exit 90
        python3 -I /fake_room.py & sleep 1
        Xvfb :99 -screen 0 800x600x24 >/dev/null 2>&1 & sleep 2
        export DISPLAY=:99
        mkdir /tmp/home; HOME=/tmp/home /app >/tmp/out 2>&1 & app=$!
        sleep 5
        xwd -root -silent >/tmp/before
        touch /tmp/go; sleep 4
        xwd -root -silent >/tmp/after
        kill -0 $app || { echo "the app exited"; cat /tmp/out; exit 1; }
        cat /tmp/join || { echo "the app never connected"; exit 1; }
        grep -q "room=general&name=you " /tmp/join || { echo "joined without the default room and name"; exit 1; }
        ! cmp -s /tmp/before /tmp/after || { echo "messages arrived and the window did not change"; exit 1; }
        echo "messages changed the window"
    ' || { echo "::error::the chat check failed on $image (exit $?; 90 means it could not be set up)"; exit 1; }
done
