# 🌾 Contributing to Krishi-Saarthi

Welcome to the **Krishi-Saarthi** development team! This guide will help you set up your local development environment safely, collaborate with other developers, and uphold security and privacy standards across the codebase.

---

## 📋 Table of Contents
1. [Project Overview](#project-overview)
2. [Prerequisites](#prerequisites)
3. [Quick Start Setup](#quick-start-setup)
   - [Environment Configuration](#1-environment-configuration)
   - [Backend Setup (FastAPI)](#2-backend-setup-fastapi)
   - [Mobile App Setup (Flutter)](#3-mobile-app-setup-flutter)
   - [Admin Dashboard Setup (Web)](#4-admin-dashboard-setup-web)
4. [Security & Secrets Policy](#security--secrets-policy)
5. [Pre-Commit Verification](#pre-commit-verification)
6. [Git Workflow & Pull Requests](#git-workflow--pull-requests)

---

## 🚜 Project Overview

The repository is organized into modular layers:
- `backend/`: FastAPI REST & WebSocket server, SQLite/PostgreSQL, Redis, AI service, Celery tasks, and cryptography.
- `mobile_app/`: Flutter cross-platform mobile application (Android / iOS / macOS / Web) with offline SQLCipher database, AR spray guidance, and mesh sync.
- `admin_dashboard/`: Web administration portal with GIS outbreak heatmap, disease telemetry, and farmer registry.
- `ml_models/`: Offline quantized ML models (TinyLlama GGUF, MobileNetV3 TFLite) and training scripts.
- `infrastructure/`: Docker Compose definitions for PostgreSQL, Redis, and MinIO.
- `scripts/`: Operational tools and pre-commit security verification scripts.

---

## 🛠️ Prerequisites

Ensure you have the following installed on your machine:
- **Python 3.11+**
- **Flutter 3.20+** and **Dart 3.3+**
- **Node.js 18+** & `npm` (for admin dashboard)
- **Git**
- *(Optional)* **Docker & Docker Compose** (if running PostgreSQL, Redis, and MinIO in containers)

---

## 🚀 Quick Start Setup

### 1. Environment Configuration

1. Copy the environment template to create your local `.env`:
   ```bash
   cp .env.example .env
   # Or inside the backend directory:
   cp backend/.env.example backend/.env
   ```
2. **API Keys**:
   - **Google Gemini AI (Recommended)**: Obtain a free API key from [Google AI Studio](https://aistudio.google.com/app/apikey) and paste it into `GEMINI_API_KEY=your_key_here`.
   - *Note: If you leave `GEMINI_API_KEY` empty, Krishi-Saarthi automatically falls back to the ICAR offline agronomy rule engine and local heuristics.*
   - **CARTO Basemaps (Optional)**: CARTO raster basemaps function with standard OpenStreetMap attribution without requiring a key.
3. **Never commit `.env`!** The `.gitignore` is pre-configured to keep it strictly local.

---

### 2. Backend Setup (FastAPI)

```bash
cd backend

# 1. Create a virtual environment
python3 -m venv venv

# 2. Activate virtual environment
# On macOS / Linux:
source venv/bin/activate
# On Windows:
# venv\Scripts\activate

# 3. Install dependencies
pip install --upgrade pip
pip install -r requirements.txt

# 4. Initialize local SQLite database
python3 scripts/init_db.py

# 5. Start development server
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

- Interactive API Docs (Swagger UI): `http://localhost:8000/docs`
- Health check: `http://localhost:8000/api/v1/dashboard/stats`

---

### 3. Mobile App Setup (Flutter)

```bash
cd mobile_app

# 1. Fetch Flutter packages
flutter pub get

# 2. Verify connected devices
flutter devices

# 3. Run the application (iOS simulator, Android emulator, macOS desktop, or Chrome)
flutter run -d chrome
# or for macOS desktop:
flutter run -d macos
```

> **Note**: Android's `local.properties` contains your personal machine's SDK path and is automatically ignored by Git. Never remove it from `.gitignore`.

---

### 4. Admin Dashboard Setup (Web)

```bash
cd admin_dashboard

# Install packages & launch
npm install
npm run dev
```

Open `http://localhost:3000` (or `http://localhost:5173`) in your browser to view the administrative control room.

---

## 🔐 Security & Secrets Policy

1. **Zero Hardcoded Secrets**: Never commit real API keys, passwords, bearer tokens, or private keys to any file tracked by Git.
2. **Local Machine Files**: Do not commit IDE folders (`.idea/`, `.vscode/`), system files (`.DS_Store`), or local SDK paths (`local.properties`).
3. **Large Binary Files**: Model weights (`models/*.gguf`, `*.bin`, `*.safetensors`) exceed GitHub's 100 MB file limit. Use `python3 backend/download_model.py` to retrieve them locally.

---

## 🛡️ Pre-Commit Verification

Before submitting any code, always run the automated security scanner from the repository root:

```bash
python3 scripts/security_check.py
```

Ensure it exits with `✅ SUCCESS: 0 secrets or sensitive file leaks detected!`

---

## 🌿 Git Workflow & Pull Requests

1. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```
2. **Make your changes and verify**:
   ```bash
   python3 scripts/security_check.py
   ```
3. **Commit with clean, descriptive messages**:
   ```bash
   git add .
   git commit -m "feat(ai): add multi-turn agronomic context support"
   ```
4. **Push and open a Pull Request**:
   ```bash
   git push origin feature/your-feature-name
   ```

<!-- Agri-Saarthi 2026 Sync -->
