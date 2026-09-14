# Krishi-Saarthi: Project Guide & Architecture Documentation

Welcome to the comprehensive guide for the Krishi-Saarthi project. This document explains how the different modules of the system work together, how AI models function (and how you can train them), and how to test the application locally on your Mac.

---

## 1. System Architecture

Krishi-Saarthi is an **Offline-First Agricultural OS** designed to work in low-connectivity areas while providing cutting-edge AI assistance to farmers. 

The system consists of:
- **Flutter Mobile App:** Cross-platform app designed for Android and iOS. It contains a local SQLite database (`LocalDB`) that caches weather data, API responses, and user queries. It seamlessly falls back to offline modes when the internet is disconnected.
- **FastAPI Backend (Python):** The central server that handles AI chat (Gemini and local LLM), computer vision for crop diseases, weather data aggregation (Open-Meteo), and GIS mapping.
- **Admin Dashboard (Vite + React/Vanilla):** A web interface for Krishi Vigyan Kendra (KVK) officials to view GIS maps, soil health data, and alerts.

---

## 2. How the AI Systems Work

### A. Conversational Agronomist (Chat)
1. **Online Mode (Gemini 2.5 Flash):** When the internet is available and an API key is provided, queries are sent to Gemini. The system prompt forces Gemini to answer using strict ICAR (Indian Council of Agricultural Research) and CIBRC (Central Insecticides Board & Registration Committee) guidelines. Exact NPK values and technical chemical names are strictly enforced.
2. **Quota Protection:** The system tracks usage. If the 15 requests/hour free-tier limit is hit, it automatically engages the offline fallback to prevent charges.
3. **Offline Mode (Local LLM - Llama.cpp):** If the internet drops or the API rate limit is exceeded, the backend spins up a local, quantized GGUF model (`TinyLlama`). This model runs entirely on your Mac's CPU/GPU and provides generative answers without the internet.
4. **Offline Mode (Static ICAR Knowledge):** If the Local LLM fails or isn't installed, the system falls back to a hardcoded ICAR knowledge base, providing exact verified treatments for diseases like Wheat Rust or Paddy Blast.

### B. Disease Diagnosis (Vision)
1. **Gemini Vision:** Analyzes images of diseased leaves and returns a structured JSON response containing the disease name, pathogen, severity, and CIBRC-approved chemical and organic cures.
2. **Offline Fallback:** Reverts to a simulated quantized MobileNet edge model that provides known heuristic-based answers for common crops.

---

## 3. How to Train or Fine-Tune the ML Models

Currently, the AI utilizes pre-trained Foundation Models (Gemini) and Quantized Models (TinyLlama). If you want to train your own specific crop disease model (e.g., a custom MobileNet-v3 for the mobile app):

### Steps to Train a Custom Computer Vision Model:
1. **Data Collection:** Gather thousands of labeled images of crop diseases (e.g., from PlantVillage dataset).
2. **Setup Environment:** Use TensorFlow or PyTorch.
   ```bash
   pip install tensorflow keras
   ```
3. **Transfer Learning:** Load a pre-trained model like MobileNetV3 and replace the top layer to classify your specific diseases.
4. **Quantization (TFLite):** 
   - Convert the trained `.h5` or `.pb` model to `.tflite` format using TensorFlow Lite Converter.
   - Use integer quantization (INT8) to reduce the model size from 15MB to ~3MB so it runs instantly on mobile phones offline.
5. **Integration:** Place the `.tflite` file in the Flutter `assets/` folder and use the `tflite_flutter` package to run inference locally on the device camera stream.

---

## 4. Running & Testing on Your Mac

Since you are setting up Docker Desktop and Flutter Desktop for Mac, here is how you test everything locally.

### Step 1: Start the Backend (FastAPI)
Open a terminal and run:
```bash
cd backend
source venv/bin/activate
# Install requirements if not done
pip install -r requirements.txt
# Start the server
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```
*The API will be available at `http://localhost:8000`. You can test endpoints using Thunder Client in VS Code.*

### Step 2: Start the Admin Dashboard (Web)
Open a new terminal:
```bash
cd admin_dashboard
npm install
npm run dev
```
*The dashboard will run at `http://localhost:3000`. Open it in your browser to see the OpenStreetMap GIS implementation.*

### Step 3: Run the Flutter App (Mac Desktop or Simulator)
Open a new terminal:
```bash
cd mobile_app
flutter pub get
# To run as a macOS desktop app:
flutter run -d macos
# To run on an iOS Simulator (if Xcode is installed):
flutter run -d ios
```

### Step 4: Testing Offline Capabilities
To test the offline robustness of the app:
1. Turn off your Mac's Wi-Fi.
2. Try sending a chat message or checking the weather in the Flutter app.
3. You should see the **Red Alert** UI indicating offline mode.
4. The chat should successfully fall back to the Local LLM or ICAR Static Knowledge Base.
5. Turn Wi-Fi back on and verify that data syncs and online models are restored.

---

## 5. Security Note regarding API Keys
- Your Gemini API Key and Carto API Key must **NEVER** be hardcoded in the frontend or pushed to GitHub.
- They are handled securely by the backend in `.env` files. 
- The API limits (15 requests/hour) are actively monitored by the `RateLimiter` class in `backend/app/services/rate_limiter.py` to prevent any unexpected billing.

## Conclusion
The implementation plan for Phase 18 has been executed. The UI is professional, maps are rendering via OSM without watermarks, weather is caching locally, and the AI is robustly configured to provide highly accurate, ICAR-grounded advice with local LLM fallbacks.

<!-- Agri-Saarthi 2026 Sync -->
