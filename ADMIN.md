# 🌱 KRISHI-SAARTHI (कृषि-सारथी) — Web Admin Dashboard
## Complete Architecture, Component Guide & Interactive Engineering Specification

> **SIH 2026 Problem Statement Solution**: Offline-First Agricultural Intelligence Operating System  
> **Target Audience**: ICAR Agriculture Scientists, District Officers, FPO Leads, and Farm Command Operators  
> **Frontend Stack**: Vanilla HTML5, High-Performance Modern CSS3 (BEM / Custom Properties), Vanilla JavaScript (ES2022 Modules), Vite 5.4  
> **Backend Integration**: FastAPI Core (`http://localhost:8000/api/v1`), SQLite / Postgres, Leaflet.js GIS, Chart.js  

---

## 📑 Table of Contents

1. [Architectural Overview & Design System](#1-architectural-overview--design-system)
2. [Global Layout & Atmosphere](#2-global-layout--atmosphere)
3. [Top Header & Command HUD](#3-top-header--command-hud)
4. [Sidebar Navigation & Theme Switcher](#4-sidebar-navigation--theme-switcher)
5. [Module 1: Dashboard Overview (डैशबोर्ड अवलोकन)](#5-module-1-dashboard-overview)
   - [KPI Metrics Grid & Sparklines](#kpi-metrics-grid--sparklines)
   - [GIS Vector Map Preview & Live Diagnoses Feed](#gis-vector-map-preview--live-diagnoses-feed)
   - [Actionable Risk Center ("What Needs Attention")](#actionable-risk-center-what-needs-attention)
   - [Today's Priority Action Plan Checklist](#todays-priority-action-plan-checklist)
   - [Weather Forecast & Mandi Ticker](#weather-forecast--mandi-ticker)
6. [Module 2: Predictive Kriging GIS Map (रोग मानचित्र)](#6-module-2-predictive-kriging-gis-map)
7. [Module 3: Crop Diagnoses & Interactive AI Scanner (फसल निदान)](#7-module-3-crop-diagnoses--interactive-ai-scanner)
   - [1-Click Sample Leaf Inspection Row](#1-click-sample-leaf-inspection-row)
   - [Holographic Laser Scanner Viewfinder](#holographic-laser-scanner-viewfinder)
   - [7-Day Disease Risk Trajectory Timeline](#7-day-disease-risk-trajectory-timeline)
   - [Circular Animated Health Score Gauge](#circular-animated-health-score-gauge)
   - [3-Tab Remedies Hub (Chemical, Organic, Prevention)](#3-tab-remedies-hub)
   - [Crop Diagnoses Registry Table](#crop-diagnoses-registry-table)
8. [Module 4: Farmers & Farm Plots Registry (किसान व खेत)](#8-module-4-farmers--farm-plots-registry)
9. [Module 5: Mandi Market Intelligence & Category Filters (मंडी भाव)](#9-module-5-mandi-market-intelligence)
10. [Module 6: Fertilizer Anti-Counterfeit Verifier (उर्वरक जाँच)](#10-module-6-fertilizer-anti-counterfeit-verifier)
11. [Module 7: Blockchain Insurance Claim Locker (बीमा लॉकर)](#11-module-7-blockchain-insurance-claim-locker)
12. [Module 8: P2P Mesh Network Nodes (मेश नेटवर्क)](#12-module-8-p2p-mesh-network-nodes)
13. [Module 9: AI & LLM Copilot Hub (Gemini AI)](#13-module-9-ai--llm-copilot-hub)
14. [Module 10: 2G Rural Telecom Gateway (USSD & SMS)](#14-module-10-2g-rural-telecom-gateway)
15. [Living Nature Animation Engine & Particle System](#15-living-nature-animation-engine--particle-system)
16. [Toast Notification System & Global Window Bindings](#16-toast-notification-system--global-window-bindings)
17. [Developer Quickstart & Build Instructions](#17-developer-quickstart--build-instructions)

---

## 1. Architectural Overview & Design System

The Krishi-Saarthi Admin Dashboard is built on the **Living Nature + Cyber Agriculture** design ethos:

```
┌────────────────────────────────────────────────────────────────────────┐
│                        KRISHI-SAARTHI ADMIN OS                         │
│                                                                        │
│   ┌────────────────────┐   ┌──────────────────┐   ┌────────────────┐   │
│   │   Foliage Emerald  │   │   Harvest Earth  │   │   Cyber Cyan   │   │
│   │   #10B981 / #059669│   │   #F59E0B / #D97706│ │   #00E5FF / 38BDF8 │
│   └────────────────────┘   └──────────────────┘   └────────────────┘   │
│                                                                        │
│   • Dark Glassmorphism Surfaces: rgba(14, 21, 38, 0.72)               │
│   • Specular 1px Micro-Borders: rgba(255, 255, 255, 0.08)             │
│   • Multi-Layer Backdrop Filters: blur(20px) saturate(180%)           │
│   • Typography Hierarchy: Outfit (Headings) + Plus Jakarta Sans (UI)   │
│     + JetBrains Mono (Data/Hashes) + Noto Sans Devanagari (Hindi)     │
└────────────────────────────────────────────────────────────────────────┘
```

### Color Palette & Semantic Tokens
- **Background Deep Canvas**: `#060913` (Cosmic Obsidian)
- **Glass Card Fill**: `rgba(14, 21, 38, 0.72)` (Deep Midnight Blue)
- **Primary Bio Accent**: `#10B981` (Spring Emerald)
- **Secondary Telemetry Accent**: `#00E5FF` (Bioluminescent Cyan)
- **Harvest Earth**: `#F59E0B` (Amber Grain)
- **Critical Risk Alert**: `#EF4444` / `#FB7185` (Rose Red)
- **Border Glass**: `rgba(255, 255, 255, 0.08)`
- **Border Glow Active**: `rgba(16, 185, 129, 0.5)`

---

## 2. Global Layout & Atmosphere

### File Reference: [index.html](file:///Users/gauravmoriya/SIH2026./admin_dashboard/index.html#L17-L27)
The page implements a responsive split layout with ambient natural depth:

1. **Ambient Organic Blobs (`.organic-blob`)**:
   - 3 continuously pulsing blur nodes (`blobFloat` animation, 20-30s cycle) positioned at top-left (Emerald), center-right (Cyan), and bottom-center (Amber).
2. **Floating Nature Particle System (`#floatingNature`)**:
   - Fixed full-screen DOM canvas where delicate farm particles (`🍃`, `🌿`, `🍂`, `🌱`, `🌾`, `☘️`) continuously drift upward with random rotation and sway.
3. **Toast Notification Container (`#toast-container`)**:
   - Fixed top-right container for non-blocking feedback with animated timer bars.

---

## 3. Top Header & Command HUD

### File Reference: [index.html](file:///Users/gauravmoriya/SIH2026./admin_dashboard/index.html#L109-L134)
The header provides continuous situational awareness:

| Element | ID / Class | Purpose / Behavior |
|---|---|---|
| **Page Title** | `#page-title` | Dynamically updates as you switch between the 10 modules. |
| **Page Subtitle** | `#page-subtitle` | Contextual module description in Hindi and English. |
| **Global Search** | `#global-search-input` | Instant cross-table filtering with `⌘K` keyboard shortcut. |
| **AI Status Badge** | `#header-ai-status` | Shows connection status (`⚡ Gemini / ICAR Live`), clickable to jump to AI Hub. |
| **Weather Sync Badge** | `#current-district-display` | Live telemetry from IMD grid (`UP_LKO (लखनऊ) 28.5°C`). |
| **Digital Clock** | `#system-clock` | Real-time Indian Standard Time (IST) readout (`HH:MM:SS`). |
| **Refresh Button** | `#btn-refresh-data` | Triggers immediate re-fetch of all backend endpoints with toast feedback. |

---

## 4. Sidebar Navigation & Theme Switcher

### File Reference: [index.html](file:///Users/gauravmoriya/SIH2026./admin_dashboard/index.html#L28-L104)

### Navigation Menu
Buttons trigger tab switching without page reload (`switchTab(tabId)`):
1. `📊 डैशबोर्ड अवलोकन (Overview)`
2. `🗺️ रोग मानचित्र (Kriging GIS)` — `LIVE` Badge
3. `🔬 फसल निदान (AI Diagnoses)`
4. `🌾 किसान व खेत (Farmers & Plots)`
5. `💰 मंडी भाव (Mandi Analytics)`
6. `🧪 उर्वरक जाँच (Anti-Counterfeit)`
7. `🛡️ बीमा लॉकर (Blockchain Locker)`
8. `📡 P2P मेश नेटवर्क (Mesh Nodes)`
9. `🤖 AI व LLM केंद्र (Gemini AI)` — `AI` Badge
10. `📟 टेलीकॉम गेटवे (USSD & SMS)` — `2G` Badge

### 3-Way Instant Theme Switcher
- **🌱 Bio (`emerald`)**: Lush forest and agriculture tones.
- **⚡ Cyber (`cyber`)**: High-contrast blue/cyan telemetry command center.
- **🌾 Harvest (`harvest`)**: Earthy amber, wheat gold, and warm soil tones.
- Persisted automatically to browser `localStorage`.

### Node Status Card
- Displays backend heartbeat (`http://localhost:8000`), active P2P store-and-forward ferry status, and live latency (`12ms`).

---

## 5. Module 1: Dashboard Overview

### File Reference: [index.html](file:///Users/gauravmoriya/SIH2026./admin_dashboard/index.html#L136-L362)

### KPI Metrics Grid & Sparklines
5 primary cards with real-time counters and SVG vector sparklines:
- **पंजीकृत किसान (Farmers)**: Total Aadhaar-vaulted farmers (`#kpi-farmers`).
- **फसल रोग निदान (AI Diagnoses)**: Total scans executed on-device (`#kpi-diagnoses`).
- **सक्रिय रोग प्रकोप (Active Outbreaks)**: High-risk clusters identified by Kriging (`#kpi-diseases`).
- **बीमा दावे (Insurance Settled)**: Settled claims secured on blockchain (`#kpi-claims`).
- **कवर जिले (Districts)**: Active IMD meteorological districts (`#kpi-districts`).

### GIS Vector Map Preview & Live Diagnoses Feed
- **Left Panel**: Small interactive Leaflet preview of the Kriging vector risk layer.
- **Right Panel**: Real-time diagnostic stream showing severity tags (`Critical`, `High`, `Medium`), crop names, and diagnosis timestamps.

### Actionable Risk Center ("What Needs Attention")
Derived directly from the natural living reference architecture:
- **Disease Risk**: Yellow Rust and Late Blight alerts with expandable "See What To Do" instructions.
- **Weather Risk**: Impending 36-hour rainfall warning to prevent pesticide wash-off.
- **Soil Moisture**: Surface vs. root moisture advisory to conserve irrigation water.
- **Toggle Action**: `toggleRiskDetail(btn, id)` slides open specific treatment protocols.

### Today's Priority Action Plan Checklist
- Interactive, tactile task items with priority badges:
  - `🔴 NOW`: Leaf inspection & weather delay protocols.
  - `🟠 TODAY`: Fertilizer anti-counterfeit bag verification.
  - `🟢 LATER`: Mandi price trend review before grain liquidation.
- **Micro-Interaction**: Clicking `.action-plan-check` toggles a checkmark, strikes through completed text, and triggers an affirmative toast notification.

### Weather Forecast & Mandi Ticker
- Instant 3-day weather card (Temperature, Humidity, Wind speed, and ICAR advisory).
- Top 5 commodity modal price ticker with price change indicators (`+3.4%`, `-1.2%`).

---

## 6. Module 2: Predictive Kriging GIS Map

### File Reference: [index.html](file:///Users/gauravmoriya/SIH2026./admin_dashboard/index.html#L363-L488)

### Technical Specifications
- **Basemap Layer**: CARTO HD Dark Matter tiles with CartoCDN fallback.
- **Rate Limit Safety**: Strictly complies with the user's free tier budget (max 15 requests/hr; local raster cache active).
- **Spatial Interpolation**: Ordinary Kriging algorithm calculating continuous disease risk surfaces from geo-tagged diagnostic points.
- **Pathogen Filter**: Filter map by pathogen: *All*, *Yellow Rust (Wheat)*, *Late Blight (Potato)*, *Rice Blast (Paddy)*, or *White Rust (Mustard)*.
- **HUD District Fly-To Buttons**: Instant one-click camera flights to *Lucknow*, *Varanasi*, *Agra*, *Gorakhpur*, or *All*.
- **Visual Wind Vector**: Dispersal direction indicator (`ENE @ 14 km/h`, 65° cone angle).

---

## 7. Module 3: Crop Diagnoses & Interactive AI Scanner

### File Reference: [index.html](file:///Users/gauravmoriya/SIH2026./admin_dashboard/index.html#L489-L650)

The centerpiece of the farmer diagnostic intelligence pipeline:

```
┌───────────────────────────────────────┬───────────────────────────────────────┐
│     AI CROP SCANNER & 7-DAY RISK      │     WHAT SHOULD I DO? REMEDIES HUB    │
│                                       │                                       │
│ [🍅 Tomato] [🌾 Wheat] [🥔 Potato]     │  [SVG CIRCULAR GAUGE] 65/100 Health   │
│ [🌿 Healthy Leaf Demo Presets]        │                                       │
│                                       │  [ 💊 CIBRC ] [ 🌿 Organic ] [ 🛡️ Prev]│
│ ┌───────────────────────────────────┐ │  ┌───────────────────────────────────┐│
│ │ 📷 Drag Leaf Photo / Laser Scan   │ │  │ Recommended Certified Fungicide:   ││
│ │   [=== LASER SCAN LINE ===]       │ │  │ Propiconazole 25% EC (Tilt) @ 1ml/L││
│ └───────────────────────────────────┘ │  └───────────────────────────────────┘│
│                                       │                                       │
│ 7-Day Spore Risk Trajectory:          │  [📢 SMS Alert to Farmers]            │
│ [D1 22%] [D2 38%] [D3 55%] [D7 94%]   │  [🛡️ Add Proof to Blockchain Locker]  │
└───────────────────────────────────────┴───────────────────────────────────────┘
```

### 1-Click Sample Leaf Inspection Row
Users can test the AI scanner instantly without having a photo on hand:
- `🍅 Tomato (Early Blight)`: Alternaria solani, 94.2% confidence.
- `🌾 Wheat (Yellow Rust)`: Puccinia striiformis, 96.8% confidence.
- `🥔 Potato (Late Blight)`: Phytophthora infestans, 93.5% confidence.
- `🌿 Healthy Leaf`: Clean green tissue, 98.5% confidence.

### Holographic Laser Scanner Viewfinder
- Features 4 cybernetic corner crosshairs and a moving green laser sweep line (`#scannerLaser`).
- Uploading an image or tapping a demo sample triggers the laser beam, updates the viewfinder label, and renders diagnostic results in under 800ms.

### 7-Day Disease Risk Trajectory Timeline
- 7 vertical dynamic SVG/CSS columns showing day-by-day spore spread probability.
- Color-coded: Green (<35%), Amber (35-65%), Red (>65%).
- Includes ICAR epidemiological reasoning for risk rises (temperature/humidity correlation).

### Circular Animated Health Score Gauge
- Animated SVG ring (`#hring`) with cubic bezier stroke offset.
- Dynamic color transitions: Emerald (>75), Amber (50-75), Crimson (<50).
- Displays `/100` health vigor rating.

### 3-Tab Remedies Hub
Integrated ICAR & CIBRC multi-modal treatment matrix:
1. **💊 रासायनिक (CIBRC Certified Chemicals)**: Exact chemical name, concentration per liter of water, and spraying interval.
2. **🌿 जैविक देशी इलाज (Organic Bio Solutions)**: Zero-cost neem oil formulations, sour buttermilk (छाछ) sprays, and infected tissue burial guidelines.
3. **🛡️ भविष्य रोकथाम (Prevention Protocol)**: Ridge planting, drip vs. sprinkler advice, crop spacing, and balanced NPK fertilizer recommendations.

### Direct Action Integration
- **📢 SMS चेतावनी बटन**: Instantly switches to the Telecom module with pre-drafted Hindi emergency advisory text.
- **🛡️ बीमा साक्ष्य बटन**: Deep-links into the Blockchain Locker with diagnostic hashes.

### Crop Diagnoses Registry Table
- Searchable multi-column table displaying full history with severity badges and timestamps.

---

## 8. Module 4: Farmers & Farm Plots Registry

### File Reference: [index.html](file:///Users/gauravmoriya/SIH2026./admin_dashboard/index.html#L652-L704)
- **Aadhaar Data Vault**: Displays tokenized, privacy-preserving farmer credentials.
- **Plot Telemetry**: Acreage, GPS polygon status, crop variety, and irrigation infrastructure.
- **Sync Status**: Shows whether the farmer's mobile terminal is currently synchronized or awaiting a mesh ferry node.

---

## 9. Module 5: Mandi Market Intelligence

### File Reference: [index.html](file:///Users/gauravmoriya/SIH2026./admin_dashboard/index.html#L705-L775)
- **Agmarknet Integration**: Real-time modal price feeds across 12 major commodities.
- **Commodity Category Filter Chips**:
  - `🌾 समस्त (All Crops)`
  - `🌾 अनाज (Cereals - Wheat, Rice, Maize)`
  - `🌱 दलहन (Pulses - Gram, Arhar, Moong)`
  - `🥔 सब्जियां (Vegetables - Potato, Tomato, Onion)`
  - `🌻 तिलहन (Oilseeds - Mustard, Soybean)`
- **Dynamic Search**: Filter instantly by mandi name, variety, or district.
- **Trend Calculation**: Visual indicators showing positive or negative price velocity (`▲ +3.4%`).

---

## 10. Module 6: Fertilizer Anti-Counterfeit Verifier

### File Reference: [index.html](file:///Users/gauravmoriya/SIH2026./admin_dashboard/index.html#L776-L840)
- **Holographic HUD Viewfinder**: Live optical scan target with corner reticles.
- **Quick 1-Click Verification Presets**:
  - `✅ IFFCO Genuine Nano Urea`: Barcode `8901234567890`. Verifies genuine cryptographic checksum.
  - `❌ Banned Fake Paras Urea`: Barcode `8909999999999`. Triggers counterfeit lockout and alert.
- **Registry Inspection**: Displays manufacturer license number, batch production date, and lab test results.

---

## 11. Module 7: Blockchain Insurance Claim Locker

### File Reference: [index.html](file:///Users/gauravmoriya/SIH2026./admin_dashboard/index.html#L841-L910)
- **Polygon PoS Smart Contract Verification**: Decentralized claim anchoring preventing duplicate claims.
- **Cryptographic Evidence Hashing**: Image SHA-256 + GPS coordinates + Kriging spore density index.
- **Payout Telemetry**: Real-time status (`SETTLED`, `PENDING_SURVEYOR`, `REJECTED`) and rupee payout tracking.

---

## 12. Module 8: P2P Mesh Network Nodes

### File Reference: [index.html](file:///Users/gauravmoriya/SIH2026./admin_dashboard/index.html#L911-L980)
- **Store-and-Forward Topology**: Tracks mobile nodes acting as data ferries between cellular-denied villages and district centers.
- **Node Metrics**: Battery level, queued diagnostic packets, BLE signal RSSI, and last handshake timestamp.
- **Topology Visualizer**: Visual representation of the village-to-hub data hopping tree.

---

## 13. Module 9: AI & LLM Copilot Hub

### File Reference: [index.html](file:///Users/gauravmoriya/SIH2026./admin_dashboard/index.html#L981-L1050)
- **Model Engine**: Google Gemini 2.5 Flash / ICAR Agricultural Knowledge Hub.
- **Pre-Engineered Prompts**:
  - `🌾 गेहूं में रतुआ रोग के रासायनिक व जैविक उपचार`
  - `🌧️ अगले 3 दिनों में बारिश के अनुसार कीटनाशक छिड़काव योजना`
  - `💰 सरसों बेचने का सही समय और मंडी भाव रुझान`
- **Multilingual Support**: Real-time conversational streaming in Hindi and English.

---

## 14. Module 10: 2G Rural Telecom Gateway

### File Reference: [index.html](file:///Users/gauravmoriya/SIH2026./admin_dashboard/index.html#L1051-L1135)
- **Interactive USSD Feature Phone Simulator**:
  - Emulates an entry-level keypad phone dialing `*123#`.
  - Functional telephone keypad (`1`-`9`, `*`, `#`, Call, Clear).
  - Multi-stage menu tree: Crop Advisory, Mandi Prices, Weather, Disease Report.
- **Rural SMS Emergency Broadcast**:
  - Push emergency SMS alerts to farmer user-groups.
  - DLT Registration Template ID validation.
  - Live carrier logs showing delivery latency across Jio, Airtel, Vi, and BSNL.

---

## 15. Living Nature Animation Engine & Particle System

### File Reference: [app.js](file:///Users/gauravmoriya/SIH2026./admin_dashboard/app.js#L1400-L1435) & [index.css](file:///Users/gauravmoriya/SIH2026./admin_dashboard/index.css#L230-L260)

The living atmosphere runs seamlessly via CSS keyframes and an ambient JS particle manager:

```javascript
// Floating Nature Particles
const NATURE_EMOJIS = ['🍃', '🌿', '🍂', '🌱', '🌾', '☘️'];

function createFloatingLeaf(container) {
  const leaf = document.createElement('div');
  leaf.className = 'nature-leaf';
  leaf.textContent = NATURE_EMOJIS[Math.floor(Math.random() * NATURE_EMOJIS.length)];
  leaf.style.left = Math.random() * 95 + '%';
  leaf.style.fontSize = (12 + Math.random() * 14) + 'px';
  leaf.style.setProperty('--duration', (14 + Math.random() * 16) + 's');
  container.appendChild(leaf);
  setTimeout(() => leaf.remove(), 30000);
}
```

- Honors `prefers-reduced-motion: reduce`.
- Zero impact on DOM performance or scroll responsiveness.

---

## 16. Toast Notification System & Global Window Bindings

### File Reference: [app.js](file:///Users/gauravmoriya/SIH2026./admin_dashboard/app.js#L1440-L1455)

Because the project is bundled as an ES Module via Vite (`<script type="module" src="./app.js">`), all interactive functions called via inline HTML `onclick` attributes are explicitly attached to the global `window` object:

```javascript
window.switchTab = switchTab;
window.showToast = showToast;
window.toggleRiskDetail = toggleRiskDetail;
window.toggleAction = toggleAction;
window.loadSampleLeaf = loadSampleLeaf;
window.analyzeDisease = analyzeDisease;
window.swTab = swTab;
window.broadcastSMSForDisease = broadcastSMSForDisease;
window.filterMandiCategory = filterMandiCategory;
```

---

## 17. Developer Quickstart & Build Instructions

### Prerequisites
- Node.js 18+ and npm
- Python 3.11+ with FastAPI backend running on port 8000

### Running Locally (Development Mode)
```bash
# Terminal 1: FastAPI Backend
cd /Users/gauravmoriya/SIH2026.
./venv/bin/uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload

# Terminal 2: Admin Dashboard (Vite Dev Server)
cd /Users/gauravmoriya/SIH2026./admin_dashboard
npm run dev
# Dashboard is accessible on: http://localhost:3000
```

### Production Build Validation
```bash
cd /Users/gauravmoriya/SIH2026./admin_dashboard
npm run build
```
Build Output:
```
dist/index.html                 60.39 kB │ gzip: 15.01 kB
dist/assets/index-BS2_u0d3.css  34.20 kB │ gzip:  7.70 kB
dist/assets/index-ay7OzFKf.js   49.45 kB │ gzip: 17.59 kB
✓ built in ~1.9s (0 errors, 0 warnings)
```

---

*Authored for SIH 2026 National Grand Finale • Krishi-Saarthi Offline-First Agricultural Intelligence OS*

<!-- Agri-Saarthi 2026 Sync -->
