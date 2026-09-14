"""
Krishi-Saarthi High-Security Sliding-Window Quota Guard
Enforces strict rate limiting (default: 15 requests per 1 hour) for Free Tier APIs
(Google Gemini AI and CARTO Basemaps) to protect credentials from depletion.
Features:
- Thread-safe sliding window tracking (3600 seconds)
- SHA-256 in-memory caching to eliminate redundant API calls
- Instant fallback trigger when quota threshold is reached
- Credential masking utility
"""
import time
import hashlib
import threading
from collections import deque
from typing import Dict, Any, Optional, Tuple
from app.config import settings


def mask_key(key: Optional[str]) -> Optional[str]:
    """Securely mask sensitive keys for public UI and log display."""
    if not key or len(key) < 8:
        return None
    return f"{key[:6]}...{key[-4:]}"


class SlidingWindowRateLimiter:
    """
    Sliding window rate limiter with microsecond timestamp auditing and query response caching.
    """

    def __init__(self, name: str, limit: int = 15, window_seconds: int = 3600):
        self.name = name
        self.limit = limit
        self.window_seconds = window_seconds
        self._timestamps = deque()
        self._lock = threading.Lock()
        self._cache: Dict[str, Dict[str, Any]] = {}
        self._cache_hits = 0

    def check_and_record(self, cache_key: Optional[str] = None) -> Tuple[bool, int, int, Optional[Dict[str, Any]]]:
        """
        Check if request is permitted under sliding window.
        Returns:
            (allowed: bool, remaining: int, reset_in_seconds: int, cached_data: Optional[Dict])
        """
        with self._lock:
            now = time.time()
            cutoff = now - self.window_seconds

            # Purge expired timestamps older than window
            while self._timestamps and self._timestamps[0] <= cutoff:
                self._timestamps.popleft()

            # Check cache hit if key provided
            if cache_key and cache_key in self._cache:
                entry = self._cache[cache_key]
                # Cache TTL matches window_seconds
                if now - entry["timestamp"] <= self.window_seconds:
                    self._cache_hits += 1
                    remaining = max(0, self.limit - len(self._timestamps))
                    reset_in = int(self._timestamps[0] + self.window_seconds - now) if self._timestamps else 0
                    return True, remaining, max(0, reset_in), entry["data"]

            # Check if limit exceeded
            if len(self._timestamps) >= self.limit:
                reset_in = int(self._timestamps[0] + self.window_seconds - now)
                return False, 0, max(1, reset_in), None

            # Consume 1 slot
            self._timestamps.append(now)
            remaining = max(0, self.limit - len(self._timestamps))
            reset_in = int(self._timestamps[0] + self.window_seconds - now)
            return True, remaining, max(0, reset_in), None

    def store_cache(self, cache_key: str, data: Dict[str, Any]):
        """Caches successful external API responses to save quota."""
        if not cache_key:
            return
        with self._lock:
            self._cache[cache_key] = {
                "timestamp": time.time(),
                "data": data
            }
            # Limit cache size to 200 items
            if len(self._cache) > 200:
                oldest_key = next(iter(self._cache))
                del self._cache[oldest_key]

    def get_status(self) -> Dict[str, Any]:
        """Get live status of quota usage and countdown."""
        with self._lock:
            now = time.time()
            cutoff = now - self.window_seconds
            while self._timestamps and self._timestamps[0] <= cutoff:
                self._timestamps.popleft()

            used = len(self._timestamps)
            remaining = max(0, self.limit - used)
            reset_in = int(self._timestamps[0] + self.window_seconds - now) if self._timestamps else 0

            return {
                "service": self.name,
                "hourly_limit": self.limit,
                "requests_used_last_hour": used,
                "requests_remaining": remaining,
                "window_seconds": self.window_seconds,
                "reset_in_seconds": max(0, reset_in),
                "cache_hits_served": self._cache_hits,
                "cached_items_count": len(self._cache),
                "quota_engaged": used >= self.limit,
                "policy": f"Strict {self.limit} requests per 1 hour free-tier protection guard active"
            }


# Singleton instances for Gemini AI and CARTO Basemaps
gemini_limiter = SlidingWindowRateLimiter(
    name="Google Gemini 2.5 Flash AI",
    limit=getattr(settings, "GEMINI_RATE_LIMIT_PER_HOUR", 15),
    window_seconds=3600
)

carto_limiter = SlidingWindowRateLimiter(
    name="CARTO Basemaps Enterprise HD",
    limit=getattr(settings, "CARTO_RATE_LIMIT_PER_HOUR", 15),
    window_seconds=3600
)
