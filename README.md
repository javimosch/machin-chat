# machin-chat

A live room chat desktop app for [machin-365](https://github.com/javimosch/machin-365)
— talks to [machin-rooms](https://github.com/javimosch/machin-rooms) over plain
`ws://`, dogfooding Machin's hand-rolled WebSocket client path (`wss_*` builtins
are TLS-only; see javimosch/machin#694).

- Room + name fields, Connect/Send, live message list with join/leave notices
- Reader goroutine owns the socket; the UI drains a channel via non-blocking
  `select` each frame — the interface never blocks on the network
- Messages are live-only for now (no history); bkn `events` is the natural
  persistence/sync fit later

## Run

```sh
# 1. start a chat server
~/ai/machin-rooms/machin-rooms            # ws://127.0.0.1:48500

# 2. build + launch (or: machin-365 install chat --bin ./build/machin-chat)
./build.sh                               # -> build/machin-chat (~2.6 MB)
./build/machin-chat
```

Point at another server with `MDK_CHAT_SERVER=ws://host:48500`.

## Develop

```sh
~/ai/machin-desktop/mdk dev app/     # hot reload
~/ai/machin-desktop/mdk shot app/ out.ppm
~/ai/machin-desktop/mdk check app/
```

`app/ws.src` is vendored from `furet/src/wsclient.src` — the pure-MFL ws://
client (masked client frames with a zero key, extended-length parsing,
ping→pong). When a core `ws_*` client lands in machin it can be swapped for
the builtin.

## License

MIT
