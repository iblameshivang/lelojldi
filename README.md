# Agri-Saarthi (कृषि-सारथी) 🌱🌾

> **Empowering Indian Farmers with Real-Time AI Diagnostics, Multilingual Voice Assistance, and Verified Government Mandi Market Prices (AGMARKNET & OGD Platform).**

---

## 🚀 Key Features & Architectural Capabilities

### 1. 🌾 Real Government Mandi Integration (AGMARKNET / data.gov.in)
- **Zero Fake Prices**: Minimum, Maximum, and Modal prices sourced directly from the official Government of India dataset (`Resource ID: 9ef84268-d588-465a-a308-a864a43d0070`).
- **Dynamic Commodity Extraction**: Commodity filters are dynamically populated from real government records for the active region with valid price data (`modal_price > 0 || min_price > 0 || max_price > 0`).
- **Progressive Proximity Hierarchy**: Automatic multi-tier geographic expansion from local APMC mandis to neighboring districts, states, and national markets.
- **Privacy & Security**: Government API credentials remain strictly backend-only.

### 2. 🤖 Gemini AI Agricultural Advisory & Diagnosis
- Crop health analysis, fertilizer dosage recommendations, and weather-aware soil advisory in multiple Indian languages (Hindi, Punjabi, English).

### 3. 🎙️ Multilingual Voice Assistant
- Real-time voice query resolution for mandi prices, weather forecasts, and crop disease management.

---

## 🛠️ Project Structure

```
├── admin_dashboard/     # Vite + Vanilla JS/CSS Modern Agricultural Dashboard
├── backend/             # Node.js Express API & AGMARKNET Market Engine
│   ├── market-service.js# Government API connector, TTL cache & proximity resolver
│   ├── server.js        # Express REST API & AI endpoints
├── mobile_app/          # Flutter / Mobile Agricultural Application
├── ml_models/           # Disease Computer Vision & Soil Health Models
├── infrastructure/      # Docker & Deployment configurations
└── stitch_assets/       # UI Design tokens & visual assets
```

---

## ⚡ Quick Start

### 1. Backend Server
```bash
cd backend
npm install
npm start
```
*Backend runs on `http://localhost:3000`*

### 2. Frontend Dashboard
```bash
cd admin_dashboard
npm install
npm run dev
```
*Frontend runs on `http://localhost:5173`*

<!-- Agri-Saarthi 2026 Sync -->
