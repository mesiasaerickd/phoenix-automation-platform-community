"""Transport Ansible Runner events to the PAP Go receiver."""

import http.client
import json
import os
import socket


class UnixHTTPConnection(http.client.HTTPConnection):
    def __init__(self, socket_path, timeout=10):
        super().__init__("localhost", timeout=timeout)
        self.socket_path = socket_path

    def connect(self):
        self.sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        self.sock.settimeout(self.timeout)
        self.sock.connect(self.socket_path)


def _send(config, payload):
    settings = getattr(config, "settings", None) or {}

    socket_path = settings.get("runner_http_url")
    url_path = settings.get("runner_http_path")

    if not socket_path and not url_path:
        return

    if not isinstance(socket_path, str) or not socket_path.startswith("/"):
        raise ValueError("Invalid PAP event socket configuration")

    if not isinstance(url_path, str) or not url_path.startswith("/"):
        raise ValueError("Invalid PAP event URL path")

    if not os.path.exists(socket_path):
        raise ConnectionError("PAP event socket is unavailable")

    body = json.dumps(payload, default=str).encode("utf-8")

    conn = UnixHTTPConnection(socket_path)

    try:
        conn.request(
            "POST",
            url_path,
            body=body,
            headers={"Content-Type": "application/json"},
        )

        response = conn.getresponse()
        response.read()

        if response.status != 204:
            raise ConnectionError(
                f"PAP event receiver returned HTTP {response.status}"
            )
    finally:
        conn.close()


def event_handler(config, event_data):
    _send(config, event_data)


def status_handler(config, status_data):
    # Status events carry process metadata that is unnecessary for
    # reconciliation. Only forward the minimal status information.
    safe_status = {
        "status": status_data.get("status"),
        "runner_ident": status_data.get("runner_ident"),
    }
    _send(config, safe_status)
