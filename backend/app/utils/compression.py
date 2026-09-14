"""
Compression utilities - JSON compression for mesh packets and sync.
"""
import json
import zlib
import base64
from typing import Any


def compress_json(data: Any) -> str:
    """Compress JSON data using zlib + base64 encoding."""
    json_bytes = json.dumps(data, separators=(",", ":"), default=str).encode("utf-8")
    compressed = zlib.compress(json_bytes, level=9)
    return base64.b64encode(compressed).decode("ascii")


def decompress_json(compressed: str) -> Any:
    """Decompress base64+zlib compressed JSON."""
    compressed_bytes = base64.b64decode(compressed.encode("ascii"))
    json_bytes = zlib.decompress(compressed_bytes)
    return json.loads(json_bytes.decode("utf-8"))


def calculate_compression_ratio(original: Any) -> dict:
    """Calculate compression statistics."""
    original_json = json.dumps(original, default=str).encode("utf-8")
    compressed = compress_json(original)
    compressed_bytes = len(compressed.encode("ascii"))
    original_bytes = len(original_json)

    return {
        "original_bytes": original_bytes,
        "compressed_bytes": compressed_bytes,
        "ratio": round(compressed_bytes / original_bytes, 3) if original_bytes > 0 else 0,
        "savings_pct": round((1 - compressed_bytes / original_bytes) * 100, 1) if original_bytes > 0 else 0,
    }
