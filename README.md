# machin-chat

A live room chat desktop app for [machin-365](https://github.com/javimosch/machin-365)
— talks to [machin-rooms](https://github.com/javimosch/machin-rooms) over plain
`ws://`, dogfooding Machin's hand-rolled WebSocket client path (`wss_*` builtins
are TLS-only; see javimosch/machin#694).

- Room + name fields, Connect/Send, live message list with join/leave notices
- Empty fields mean what they show: room `general`, name `you`
- Network goroutines report over a channel the UI drains via non-blocking
  `select` each frame — receiving and connecting never block the interface
- Keeps the server's limits: room names are cut at 64 bytes and user names at
  32; a message over 128 KiB is not sent and stays in the input
- Keeps the last 500 messages, and the first 1 KiB of each (a message is one
  line on screen). Messages are live-only for now; bkn `events` is the natural
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

Needs machin v0.146.1+.

- `app/net.src` — the socket side. Goroutines never write globals, and the
  reader hands the socket to a fresh goroutine now and then to free its memory
- `app/history.src` — the on-screen messages, kept in mdk's state store
  (assigning a global slice inside a frame leaks it)
- `app/wsclient.src` — vendored from machin's `framework/wsclient.src`
  (v0.146.1), the pure-MFL ws:// client; its header lists the one local fix

## License

MIT
