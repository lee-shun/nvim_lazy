#!/usr/bin/env python3
"""Ollama API -> OpenAI API shim.

把 Ollama 的 /api/generate 协议转发到本机 llama-server (OpenAI 兼容) 的
/v1/chat/completions，让只懂 Ollama 协议的客户端（transdog.nvim）可以
直接用本地 llama.cpp 模型。无第三方依赖，stdlib only。

用法: python3 ollama_shim.py [listen_port] [openai_base_url]
默认: 127.0.0.1:11434 -> http://127.0.0.1:8080/v1
"""
import json
import sys
import time
import urllib.request
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

LISTEN_PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 11434
OPENAI_BASE = (sys.argv[2] if len(sys.argv) > 2 else "http://127.0.0.1:8080/v1").rstrip("/")
MODEL_NAME = "llama-server-local"  # 对外模型名；实际模型由 llama-server 决定


def chat_completions(payload, stream):
    """调用 OpenAI 兼容 chat completions，yield 文本块（流式）或返回全文（非流式）。"""
    req = urllib.request.Request(
        OPENAI_BASE + "/chat/completions",
        data=json.dumps({**payload, "stream": stream}).encode(),
        headers={"Content-Type": "application/json"},
    )
    with urllib.request.urlopen(req, timeout=120) as resp:
        if not stream:
            data = json.loads(resp.read().decode())
            yield data["choices"][0]["message"]["content"]
            return
        for raw in resp:
            line = raw.decode().strip()
            if not line.startswith("data: "):
                continue
            chunk = line[6:]
            if chunk == "[DONE]":
                break
            piece = json.loads(chunk)["choices"][0].get("delta", {}).get("content")
            if piece:
                yield piece


class Handler(BaseHTTPRequestHandler):
    def log_message(self, *a):  # 静默
        pass

    def _send(self, obj, content_type="application/json"):
        body = obj if isinstance(obj, bytes) else json.dumps(obj).encode()
        self.send_response(200)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        if self.path == "/api/tags":
            self._send({"models": [{"name": MODEL_NAME}]})
        elif self.path == "/api/version":
            self._send({"version": "0.0.0-shim"})
        else:
            self._send({"error": "not found"})

    def do_POST(self):
        length = int(self.headers.get("Content-Length", 0))
        body = json.loads(self.rfile.read(length).decode() or "{}")
        if self.path != "/api/generate":
            self._send({"error": "not found"})
            return
        system = body.get("system")
        messages = []
        if system:
            messages.append({"role": "system", "content": system})
        messages.append({"role": "user", "content": body.get("prompt", "")})
        created = time.time()

        try:
            if not body.get("stream", False):
                text = "".join(chat_completions({"model": MODEL_NAME, "messages": messages}, False))
                self._send({
                    "model": MODEL_NAME,
                    "created_at": created,
                    "response": text,
                    "done": True,
                    "done_reason": "stop",
                    "total_duration": int((time.time() - created) * 1e9),
                })
            else:
                self.send_response(200)
                self.send_header("Content-Type", "application/x-ndjson")
                self.end_headers()
                for piece in chat_completions({"model": MODEL_NAME, "messages": messages}, True):
                    chunk = {"model": MODEL_NAME, "created_at": created, "response": piece, "done": False}
                    self.wfile.write((json.dumps(chunk) + "\n").encode())
                    self.wfile.flush()
                done = {"model": MODEL_NAME, "created_at": created, "response": "", "done": True, "done_reason": "stop"}
                self.wfile.write((json.dumps(done) + "\n").encode())
                self.wfile.flush()
        except Exception as e:
            self._send({"error": f"upstream error: {e}"})


if __name__ == "__main__":
    print(f"ollama-shim: 127.0.0.1:{LISTEN_PORT} -> {OPENAI_BASE} (model {MODEL_NAME})", flush=True)
    ThreadingHTTPServer(("127.0.0.1", LISTEN_PORT), Handler).serve_forever()
