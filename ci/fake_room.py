"""A one-client chat server for ci/check-chat.sh (stdlib only).

Accepts the app, records the join request, waits for /tmp/go, then sends a
few messages in machin-rooms' format and keeps the connection open."""
import base64, hashlib, json, os, socket, time

s = socket.create_server(("127.0.0.1", 48500))
c, _ = s.accept()
request = b""
while b"\r\n\r\n" not in request:
    request += c.recv(4096)
lines = request.decode().split("\r\n")
open("/tmp/join", "w").write(lines[0] + "\n")
key = next(l.split(":", 1)[1].strip() for l in lines if l.lower().startswith("sec-websocket-key"))
accept = base64.b64encode(hashlib.sha1((key + "258EAFA5-E914-47DA-95CA-C5AB0DC85B11").encode()).digest()).decode()
c.sendall(("HTTP/1.1 101 Switching Protocols\r\nUpgrade: websocket\r\nConnection: Upgrade\r\n"
           "Sec-WebSocket-Accept: %s\r\n\r\n" % accept).encode())
while not os.path.exists("/tmp/go"):
    time.sleep(0.2)
for i in range(4):
    body = json.dumps({"type": "msg", "name": "Sam", "text": "test message %d" % i}, separators=(",", ":")).encode()
    c.sendall(bytes([0x81, len(body)]) + body)
    time.sleep(0.3)
time.sleep(60)
