"""
Automated Integration Tests for Krishi-Saarthi FastAPI backend.
Tests all endpoints covering the 13 features.
"""
import pytest
import httpx
from app.main import app

@pytest.fixture
def anyio_backend():
    return "asyncio"

@pytest.mark.asyncio
async def test_health_check():
    transport = httpx.ASGITransport(app=app)
    async with httpx.AsyncClient(transport=transport, base_url="http://test") as client:
        response = await client.get("/health")
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "healthy"
        assert "Krishi-Saarthi" in data["app"]

@pytest.mark.asyncio
async def test_root_endpoint():
    transport = httpx.ASGITransport(app=app)
    async with httpx.AsyncClient(transport=transport, base_url="http://test") as client:
        response = await client.get("/")
        assert response.status_code == 200
        data = response.json()
        assert data["docs"] == "/docs"

@pytest.mark.asyncio
async def test_weather_forecast():
    transport = httpx.ASGITransport(app=app)
    async with httpx.AsyncClient(transport=transport, base_url="http://test") as client:
        response = await client.get("/api/v1/weather/forecast?district_code=UP_LKO")
        assert response.status_code == 200
        data = response.json()
        assert data["district_code"] == "UP_LKO"
        assert "forecast_data" in data
        assert "current" in data["forecast_data"]

@pytest.mark.asyncio
async def test_weather_ussd():
    transport = httpx.ASGITransport(app=app)
    async with httpx.AsyncClient(transport=transport, base_url="http://test") as client:
        response = await client.get("/api/v1/weather/ussd?district_code=UP_LKO")
        assert response.status_code == 200
        data = response.json()
        assert "payload" in data
        assert len(data["payload"]) <= 160  # Valid for USSD/SMS

@pytest.mark.asyncio
async def test_mandi_prices():
    transport = httpx.ASGITransport(app=app)
    async with httpx.AsyncClient(transport=transport, base_url="http://test") as client:
        response = await client.get("/api/v1/mandi/prices")
        assert response.status_code == 200
        items = response.json()
        assert isinstance(items, list)
        assert len(items) > 0
        first = items[0]
        assert "crop_name" in first
        assert "price_per_quintal" in first

@pytest.mark.asyncio
async def test_fertilizer_verify_genuine():
    transport = httpx.ASGITransport(app=app)
    async with httpx.AsyncClient(transport=transport, base_url="http://test") as client:
        payload = {"barcode": "8901234567890"}
        response = await client.post("/api/v1/fertilizer/verify", json=payload)
        assert response.status_code == 200
        data = response.json()
        assert data["is_authentic"] is True
        assert "IFFCO" in data["product_name"]

@pytest.mark.asyncio
async def test_fertilizer_verify_counterfeit():
    transport = httpx.ASGITransport(app=app)
    async with httpx.AsyncClient(transport=transport, base_url="http://test") as client:
        payload = {"barcode": "8901111222233"}
        response = await client.post("/api/v1/fertilizer/verify", json=payload)
        assert response.status_code == 200
        data = response.json()
        assert data["is_authentic"] is False
        assert data["is_revoked"] is True
        assert "BANNED" in data["message"]

@pytest.mark.asyncio
async def test_kriging_risk_surface():
    transport = httpx.ASGITransport(app=app)
    async with httpx.AsyncClient(transport=transport, base_url="http://test") as client:
        response = await client.get("/api/v1/kriging/risk-surface?district_code=UP_LKO")
        assert response.status_code == 200
        data = response.json()
        assert "features" in data
        assert "metadata" in data
        assert data["metadata"]["grid_size"] > 0

@pytest.mark.asyncio
async def test_dashboard_stats():
    transport = httpx.ASGITransport(app=app)
    async with httpx.AsyncClient(transport=transport, base_url="http://test") as client:
        response = await client.get("/api/v1/dashboard/stats")
        assert response.status_code == 200
        data = response.json()
        assert data["total_farmers"] >= 1
        assert data["total_diagnoses"] >= 1

@pytest.mark.asyncio
async def test_disease_heatmap():
    transport = httpx.ASGITransport(app=app)
    async with httpx.AsyncClient(transport=transport, base_url="http://test") as client:
        response = await client.get("/api/v1/dashboard/disease-heatmap")
        assert response.status_code == 200
        data = response.json()
        assert "heatmap_data" in data
        assert len(data["heatmap_data"]) > 0

@pytest.mark.asyncio
async def test_ai_key_status():
    transport = httpx.ASGITransport(app=app)
    async with httpx.AsyncClient(transport=transport, base_url="http://test") as client:
        response = await client.get("/api/v1/ai/key-status")
        assert response.status_code == 200
        data = response.json()
        assert "configured" in data
        assert "capabilities" in data

@pytest.mark.asyncio
async def test_ai_chat_offline_and_knowledge():
    transport = httpx.ASGITransport(app=app)
    async with httpx.AsyncClient(transport=transport, base_url="http://test") as client:
        payload = {"message": "गेहूं में पीला रतुआ का इलाज क्या है?", "language": "hi"}
        response = await client.post("/api/v1/ai/chat", json=payload)
        assert response.status_code == 200
        data = response.json()
        assert data["success"] is True
        assert "पीला रतुआ" in data["reply"] or "प्रोपिकोनाज़ोल" in data["reply"]

@pytest.mark.asyncio
async def test_telecom_ussd_session_flow():
    transport = httpx.ASGITransport(app=app)
    async with httpx.AsyncClient(transport=transport, base_url="http://test") as client:
        # 1. Dial *123# -> root menu (CON)
        init_req = {"session_id": "sess-999", "msisdn": "9876543210", "user_input": "*123#", "service_code": "*123#"}
        resp = await client.post("/api/v1/telecom/ussd/session", json=init_req)
        assert resp.status_code == 200
        data = resp.json()
        assert data["action"] == "CON"
        assert "कृषि-सारथी" in data["response"]

        # 2. Select option 1 (Crop Disease) -> submenu (CON)
        step1_req = {"session_id": "sess-999", "msisdn": "9876543210", "user_input": "1", "service_code": "*123#"}
        resp1 = await client.post("/api/v1/telecom/ussd/session", json=step1_req)
        assert resp1.status_code == 200
        data1 = resp1.json()
        assert data1["action"] == "CON"
        assert "फसल चुनें" in data1["response"]

        # 3. Select option 1 (Wheat) -> wheat submenu (CON)
        step2_req = {"session_id": "sess-999", "msisdn": "9876543210", "user_input": "1", "service_code": "*123#"}
        resp2 = await client.post("/api/v1/telecom/ussd/session", json=step2_req)
        assert resp2.status_code == 200
        data2 = resp2.json()
        assert data2["action"] == "CON"
        assert "पीला रतुआ" in data2["response"]

        # 4. Select option 1 (Yellow Rust) -> final response (END)
        step3_req = {"session_id": "sess-999", "msisdn": "9876543210", "user_input": "1", "service_code": "*123#"}
        resp3 = await client.post("/api/v1/telecom/ussd/session", json=step3_req)
        assert resp3.status_code == 200
        data3 = resp3.json()
        assert data3["action"] == "END"
        assert "प्रोपिकोनाज़ोल" in data3["response"]

@pytest.mark.asyncio
async def test_telecom_sms_send_and_inbound():
    transport = httpx.ASGITransport(app=app)
    async with httpx.AsyncClient(transport=transport, base_url="http://test") as client:
        # Outbound SMS dispatch
        outbound = {
            "recipient": "9876543210",
            "message": "मौसम चेतावनी: 24 घंटे में भारी बारिश की संभावना।",
            "priority": "HIGH"
        }
        res = await client.post("/api/v1/telecom/sms/send", json=outbound)
        assert res.status_code == 200
        data = res.json()
        assert data["success"] is True
        assert data["status"] == "DELIVERED"
        assert "carrier" in data

        # Inbound SMS webhook
        inbound = {
            "sender": "9876543210",
            "body": "MANDI ONION"
        }
        in_res = await client.post("/api/v1/telecom/sms/inbound", json=inbound)
        assert in_res.status_code == 200
        in_data = in_res.json()
        assert in_data["inbound_received"] is True
        assert in_data["reply_dispatched"]["status"] == "DELIVERED"

        # Check logs
        logs_res = await client.get("/api/v1/telecom/sms/logs")
        assert logs_res.status_code == 200
        logs_data = logs_res.json()
        assert logs_data["count"] >= 1
