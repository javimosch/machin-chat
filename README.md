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

`app/wsclient.src` is vendored from `javimosch/machin`'s `framework/wsclient.src`
— the pure-MFL `wsc_*` ws:// client (masked client frames, extended-length
parsing, fragment reassembly, ping→pong, Sec-WebSocket-Accept verification).
machin's `ws_*` builtins are the shorter path but need a toolchain newer than
the pinned v0.142.0; `wsc_*` compiles on both.

## License

MIT
