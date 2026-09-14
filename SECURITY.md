# 🛡️ Security & Privacy Architecture - Krishi-Saarthi

Security and privacy are first-class architectural pillars of **Krishi-Saarthi**. This document defines the security standards, cryptographic mechanisms, secret management policies, and vulnerability response procedures implemented in the project.

---

## 1. Secrets Management & API Key Protection

### Isolation Principle
- All API keys, database credentials, and cryptographic signing keys are loaded strictly from environment variables via `backend/app/config.py` using `pydantic-settings`.
- No sensitive credentials or machine-specific files (`.env`, `local.properties`, keystores, certificates) are ever checked into version control.
- Git tracking is fortified with multi-platform exclusion rules in `.gitignore`.

### Rate Limiting & Quota Guards
To prevent API key exhaustion and protect free-tier developer credentials, the backend implements a high-security sliding-window rate limiter (`backend/app/services/rate_limiter.py`):
- **Window**: 1-hour rolling sliding window (default: 15 requests/hr for free-tier Google Gemini and CARTO endpoints).
- **In-Memory Caching**: SHA-256 hashed queries cache identical responses to eliminate redundant external API consumption.
- **Failover / Offline Fallback**: When quotas are exhausted or keys are absent, the application instantly transitions to offline ICAR expert heuristics without disrupting the user experience.

### Key Masking
Any runtime key inspection endpoint (`GET /api/v1/ai/key-status`) masks sensitive values (e.g. `AQ.Ab8...EUw`), preventing disclosure in network logs, browser inspect panels, or admin dashboards.

---

## 2. Cryptographic Standards

Krishi-Saarthi incorporates defense-in-grade cryptographic techniques:

| Layer | Standard | Implementation | Purpose |
| :--- | :--- | :--- | :--- |
| **Device Signatures** | ECDSA P-256 (SHA-256) | `backend/app/core/crypto.py` & `mobile_app/lib/services/crypto_service.dart` | Non-repudiation and tamper-proofing of farmer disease reports & insurance telemetry. |
| **Local Storage** | SQLCipher (AES-256-GCM) | `mobile_app/lib/db/local_db.dart` | Encrypts local farm logs, pest images, and farmer records on mobile devices. |
| **Authentication** | JWT (HS256) + bcrypt | `backend/app/core/security.py` | Secure stateless sessions and salted password storage. |
| **Mesh Sync** | Merkle Tree Differential Sync | `mobile_app/lib/db/delta_sync.dart` | Cryptographic reconciliation of offline records between field nodes without network access. |

---

## 3. Farmer Privacy & Data Protection

1. **Edge-First Processing**: Leaf pathology and disease diagnosis are executed on-device (via quantized MobileNetV3 / TinyLlama) whenever possible, preserving farmer image privacy.
2. **Coarse Geolocation for Disease Telemetry**: Outbreak heatmaps aggregate coordinates into Kriging spatial grids rather than exposing individual farm plot boundaries publicly.
3. **No Third-Party Trackers**: The mobile app and admin dashboard contain zero third-party telemetry, behavioral analytics, or advertising SDKs.

---

## 4. Pre-Commit Security Auditing

Before every commit, developers must execute the repository audit script:

```bash
python3 scripts/security_check.py
```

This verifies that:
- No unmasked API keys (Gemini, Google Maps, CARTO, OpenAI, AWS) exist in staged or tracked files.
- No private keys (`*.pem`, `*.key`, `*.keystore`) exist in tracked files.
- No machine-specific paths (e.g. Android `local.properties`) are tracked.
- No large model binaries (>50 MB) are staged without Git LFS.

---

## 5. Vulnerability Reporting

If you identify a potential security vulnerability or credential leak:
1. **Do NOT open a public GitHub issue.**
2. Report the vulnerability privately to the project lead or security contact at: `moryagaurav933@gmail.com`
3. Include details of the vulnerability, steps to reproduce, and potential impact.
4. We aim to acknowledge reports within 24 hours and provide remediation within 72 hours.

<!-- Agri-Saarthi 2026 Sync -->
