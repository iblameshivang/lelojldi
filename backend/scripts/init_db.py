"""
Database initialization and demo seeding script for Krishi-Saarthi.
Initializes tables and seeds rich agricultural data for SIH 2026 demo.
"""
import asyncio
import hashlib
import uuid
from datetime import datetime, date, timedelta, timezone

from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker

import sys
import os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.db.base import Base
from app.config import settings
from app.models.farmer import Farmer, FarmPlot
from app.models.diagnosis import CropDiagnosis, SyncStatus
from app.models.mandi import MandiPrice
from app.models.weather import WeatherCache
from app.models.fertilizer import FertilizerRegistry
from app.models.disease_telemetry import DiseaseTelemetry
from app.models.insurance import InsuranceClaim


async def init_and_seed():
    print(f"[+] Connecting to database: {settings.DATABASE_URL}")
    
    engine_kwargs = {"echo": False}
    if "sqlite" in settings.DATABASE_URL:
        engine_kwargs["connect_args"] = {"check_same_thread": False}
    else:
        engine_kwargs.update({
            "pool_size": 10,
            "max_overflow": 5,
        })

    engine = create_async_engine(settings.DATABASE_URL, **engine_kwargs)
    
    async with engine.begin() as conn:
        print("[+] Creating all tables...")
        await conn.run_sync(Base.metadata.create_all)
        print("[+] Tables initialized successfully!")

    async_session = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

    async with async_session() as session:
        # Check if already seeded
        from sqlalchemy import select
        existing_farmers = await session.execute(select(Farmer))
        if existing_farmers.scalars().first():
            print("[*] Database already contains data. Skipping seed.")
            return

        print("[+] Seeding demo data for SIH 2026...")

        # 1. Farmers
        f1_id = uuid.uuid4()
        f2_id = uuid.uuid4()
        f3_id = uuid.uuid4()

        farmer1 = Farmer(
            id=f1_id,
            aadhaar_hash=hashlib.sha256("123456789012".encode()).hexdigest(),
            phone_hash=hashlib.sha256("+919876543210".encode()).hexdigest(),
            device_id="DEV-KS-LKO-001",
            preferred_language="hi",
            full_name="रमेश कुमार (Ramesh Kumar)",
            district_code="UP_LKO",
            state_code="UP",
            is_active=True,
            last_sync_at=datetime.now(timezone.utc),
        )

        farmer2 = Farmer(
            id=f2_id,
            aadhaar_hash=hashlib.sha256("234567890123".encode()).hexdigest(),
            phone_hash=hashlib.sha256("+919876543211".encode()).hexdigest(),
            device_id="DEV-KS-VNS-002",
            preferred_language="hi",
            full_name="सुनीता देवी (Sunita Devi)",
            district_code="UP_VNS",
            state_code="UP",
            is_active=True,
            last_sync_at=datetime.now(timezone.utc),
        )

        farmer3 = Farmer(
            id=f3_id,
            aadhaar_hash=hashlib.sha256("345678901234".encode()).hexdigest(),
            phone_hash=hashlib.sha256("+919876543212".encode()).hexdigest(),
            device_id="DEV-KS-IND-003",
            preferred_language="en",
            full_name="Vikram Singh Patidar",
            district_code="MP_IND",
            state_code="MP",
            is_active=True,
            last_sync_at=datetime.now(timezone.utc),
        )

        session.add_all([farmer1, farmer2, farmer3])

        # 2. Farm Plots
        p1_id = uuid.uuid4()
        p2_id = uuid.uuid4()
        plot1 = FarmPlot(
            id=p1_id,
            farmer_id=f1_id,
            plot_name="उत्तर खेत (North Field - Wheat)",
            boundary_geojson='{"type":"Polygon","coordinates":[[[80.9462,26.8467],[80.9482,26.8467],[80.9482,26.8487],[80.9462,26.8487],[80.9462,26.8467]]]}',
            area_sqm=8200.0,
            soil_type="Alluvial Loam",
            current_crop="गेहूं (Wheat - HD 2967)",
            sowing_date=datetime.now(timezone.utc) - timedelta(days=45),
            gps_lat=26.8467,
            gps_lon=80.9462,
        )

        plot2 = FarmPlot(
            id=p2_id,
            farmer_id=f1_id,
            plot_name="नहर वाला खेत (Canal Plot - Mustard)",
            boundary_geojson='{"type":"Polygon","coordinates":[[[80.9500,26.8500],[80.9520,26.8500],[80.9520,26.8520],[80.9500,26.8520],[80.9500,26.8500]]]}',
            area_sqm=4500.0,
            soil_type="Sandy Loam",
            current_crop="सरसों (Mustard - Pusa Bold)",
            sowing_date=datetime.now(timezone.utc) - timedelta(days=60),
            gps_lat=26.8500,
            gps_lon=80.9500,
        )

        session.add_all([plot1, plot2])

        # 3. Crop Diagnoses
        diag1 = CropDiagnosis(
            id=uuid.uuid4(),
            farmer_id=f1_id,
            plot_id=p1_id,
            image_hash=hashlib.sha256("leaf_rust_sample_01".encode()).hexdigest(),
            disease_name="Yellow Rust (Puccinia striiformis)",
            disease_name_hi="पीला रतुआ (Yellow Rust)",
            confidence=0.942,
            severity="high",
            crop_type="गेहूं (Wheat)",
            treatment_recommendation="Spray Propiconazole 25% EC @ 1ml/L water immediately. Avoid excessive nitrogen fertilizer.",
            treatment_recommendation_hi="तत्काल प्रोपिकोनाजोल 25% EC 1 मिली प्रति लीटर पानी में मिलाकर छिड़कें। यूरिया का अत्यधिक प्रयोग न करें।",
            gps_lat=26.8468,
            gps_lon=80.9465,
            district_code="UP_LKO",
            sync_status=SyncStatus.SYNCED,
            diagnosed_at=datetime.now(timezone.utc) - timedelta(hours=3),
        )

        diag2 = CropDiagnosis(
            id=uuid.uuid4(),
            farmer_id=f1_id,
            plot_id=p2_id,
            image_hash=hashlib.sha256("white_rust_mustard_02".encode()).hexdigest(),
            disease_name="White Rust (Albugo candida)",
            disease_name_hi="सफेद रतुआ (White Rust)",
            confidence=0.887,
            severity="medium",
            crop_type="सरसों (Mustard)",
            treatment_recommendation="Foliar spray of Mancozeb 75% WP @ 2g/L water at 15-day intervals.",
            treatment_recommendation_hi="मैनकोजेब 75% WP 2 ग्राम प्रति लीटर पानी में 15 दिन के अंतराल पर छिड़कें।",
            gps_lat=26.8502,
            gps_lon=80.9504,
            district_code="UP_LKO",
            sync_status=SyncStatus.SYNCED,
            diagnosed_at=datetime.now(timezone.utc) - timedelta(days=1),
        )

        diag3 = CropDiagnosis(
            id=uuid.uuid4(),
            farmer_id=f2_id,
            image_hash=hashlib.sha256("late_blight_potato_03".encode()).hexdigest(),
            disease_name="Late Blight (Phytophthora infestans)",
            disease_name_hi="आलू का पछेता झुलसा (Late Blight)",
            confidence=0.965,
            severity="critical",
            crop_type="आलू (Potato)",
            treatment_recommendation="Apply Cymoxanil 8% + Mancozeb 64% WP @ 3g/L water immediately. Destroy severely affected plants.",
            treatment_recommendation_hi="तुरंत साइमोक्सानिल 8% + मैनकोजेब 64% WP 3 ग्राम प्रति लीटर पानी में छिड़कें। गंभीर रूप से प्रभावित पौधों को हटा दें।",
            gps_lat=25.3176,
            gps_lon=82.9739,
            district_code="UP_VNS",
            sync_status=SyncStatus.SYNCED,
            diagnosed_at=datetime.now(timezone.utc) - timedelta(hours=6),
        )

        session.add_all([diag1, diag2, diag3])

        # 4. Mandi Prices
        crops_data = [
            ("गेहूं", "Wheat", "Sharbati", 2450.0, 2680.0, 2550.0, "up", 2.4, "UP_LKO", "Lucknow Mandi"),
            ("धान", "Paddy", "Basmati 1121", 3800.0, 4250.0, 4100.0, "stable", 0.0, "UP_LKO", "Lucknow Mandi"),
            ("सरसों", "Mustard", "Black Mustard", 5200.0, 5650.0, 5450.0, "up", 3.1, "UP_LKO", "Lucknow Mandi"),
            ("आलू", "Potato", "Desi Red", 1100.0, 1450.0, 1300.0, "down", -4.2, "UP_LKO", "Lucknow Mandi"),
            ("प्याज", "Onion", "Nashik Red", 2100.0, 2800.0, 2500.0, "up", 5.8, "UP_LKO", "Lucknow Mandi"),
            ("टमाटर", "Tomato", "Hybrid Local", 1400.0, 1900.0, 1700.0, "down", -6.5, "UP_LKO", "Lucknow Mandi"),
            ("चना", "Gram / Chana", "Desi", 5800.0, 6300.0, 6100.0, "stable", 0.5, "UP_LKO", "Lucknow Mandi"),
            ("मक्का", "Maize", "Yellow", 1950.0, 2200.0, 2100.0, "up", 1.8, "UP_VNS", "Varanasi Mandi"),
            ("सोयाबीन", "Soybean", "Yellow JS 335", 4300.0, 4750.0, 4550.0, "down", -1.2, "MP_IND", "Indore Mandi"),
            ("लहसुन", "Garlic", "Desi", 9500.0, 14000.0, 12000.0, "up", 8.4, "MP_IND", "Indore Mandi"),
            ("कपास", "Cotton", "Medium Staple", 6800.0, 7400.0, 7150.0, "stable", -0.3, "MP_IND", "Indore Mandi"),
            ("मसूर", "Lentil / Masoor", "Malka", 6200.0, 6700.0, 6450.0, "up", 1.5, "UP_KNP", "Kanpur Mandi"),
        ]

        today = date.today()
        for c_hi, c_en, variety, min_p, max_p, modal_p, trend, chg, d_code, m_name in crops_data:
            mandi_entry = MandiPrice(
                id=uuid.uuid4(),
                market_code=f"MKT_{d_code}",
                market_name=m_name,
                district_code=d_code,
                state_code=d_code.split("_")[0],
                crop_name=c_en,
                crop_name_hi=c_hi,
                variety=variety,
                min_price=min_p,
                max_price=max_p,
                modal_price=modal_p,
                price_per_quintal=modal_p,
                price_trend=trend,
                price_change_pct=chg,
                price_date=today,
                source="agmarknet",
            )
            session.add(mandi_entry)

        # 5. Weather Cache
        weather_lucknow = WeatherCache(
            id=uuid.uuid4(),
            district_code="UP_LKO",
            state_code="UP",
            district_name="Lucknow (लखनऊ)",
            forecast_data={
                "current": {
                    "temp_c": 28.5,
                    "humidity_pct": 68,
                    "wind_speed_kmh": 12.4,
                    "wind_direction": "ENE",
                    "condition": "Partly Cloudy",
                    "condition_hi": "आंशिक बादल",
                    "rainfall_mm": 0.0,
                },
                "forecast_5day": [
                    {"day": "Today", "day_hi": "आज", "temp_max": 31, "temp_min": 22, "rain_prob": 15, "summary": "Clear sky with mild breeze"},
                    {"day": "Day 2", "day_hi": "कल", "temp_max": 32, "temp_min": 23, "rain_prob": 20, "summary": "Sunny with light clouds"},
                    {"day": "Day 3", "day_hi": "परसों", "temp_max": 29, "temp_min": 21, "rain_prob": 65, "summary": "Light to moderate rain expected"},
                    {"day": "Day 4", "day_hi": "चौथा दिन", "temp_max": 27, "temp_min": 20, "rain_prob": 75, "summary": "Thunderstorms possible"},
                    {"day": "Day 5", "day_hi": "पांचवा दिन", "temp_max": 28, "temp_min": 20, "rain_prob": 30, "summary": "Scattered showers clearing"},
                ],
                "advisories": [
                    "गेहूं की फसल में सिंचाई Day 3 की बारिश के पूर्वानुमान को ध्यान में रखकर ही करें।",
                    "कीटनाशक छिड़काव अगले 48 घंटों में पूरा कर लें, Day 3 को वर्षा की संभावना है।",
                    "सब्जियों में जल निकासी (drainage) की व्यवस्था दुरुस्त रखें।",
                ]
            },
            compressed_payload="LKO|28.5|68|12|PC|0|31-22-15|32-23-20|29-21-65|27-20-75|28-20-30",
            source="imd",
            fetched_at=datetime.now(timezone.utc),
            expires_at=datetime.now(timezone.utc) + timedelta(hours=12),
        )

        weather_varanasi = WeatherCache(
            id=uuid.uuid4(),
            district_code="UP_VNS",
            state_code="UP",
            district_name="Varanasi (वाराणसी)",
            forecast_data={
                "current": {
                    "temp_c": 30.2,
                    "humidity_pct": 72,
                    "wind_speed_kmh": 9.5,
                    "wind_direction": "E",
                    "condition": "Humid / Hazy",
                    "condition_hi": "धुंध और उमस",
                    "rainfall_mm": 0.0,
                },
                "forecast_5day": [
                    {"day": "Today", "day_hi": "आज", "temp_max": 33, "temp_min": 24, "rain_prob": 25, "summary": "Warm & humid"},
                    {"day": "Day 2", "day_hi": "कल", "temp_max": 31, "temp_min": 23, "rain_prob": 40, "summary": "Afternoon clouds"},
                    {"day": "Day 3", "day_hi": "परसों", "temp_max": 28, "temp_min": 22, "rain_prob": 80, "summary": "Moderate rain"},
                    {"day": "Day 4", "day_hi": "चौथा दिन", "temp_max": 28, "temp_min": 21, "rain_prob": 50, "summary": "Intermittent drizzle"},
                    {"day": "Day 5", "day_hi": "पांचवा दिन", "temp_max": 30, "temp_min": 22, "rain_prob": 20, "summary": "Sunny periods"},
                ],
                "advisories": [
                    "आलू और टमाटर में पछेता झुलसा (Late Blight) का जोखिम उच्च आर्द्रता के कारण बढ़ रहा है।",
                    "नमी अधिक रहने पर फफूंदनाशक का सुरक्षात्मक छिड़काव करें।",
                ]
            },
            compressed_payload="VNS|30.2|72|9|HZ|0|33-24-25|31-23-40|28-22-80|28-21-50|30-22-20",
            source="imd",
            fetched_at=datetime.now(timezone.utc),
            expires_at=datetime.now(timezone.utc) + timedelta(hours=12),
        )

        session.add_all([weather_lucknow, weather_varanasi])

        # 6. Fertilizer Registry (Genuine & Fake Samples)
        fert1 = FertilizerRegistry(
            id=uuid.uuid4(),
            product_name="IFFCO Nano Urea (Liquid)",
            manufacturer="Indian Farmers Fertiliser Cooperative (IFFCO)",
            batch_number="IFFCO-NU-2026-B88",
            qr_hash=hashlib.sha256("IFFCO-NU-2026-B88-GENUINE-QR-SECRET".encode()).hexdigest(),
            seal_pattern_hash=hashlib.sha256("SEAL-PAT-88".encode()).hexdigest(),
            barcode="8901234567890",
            product_type="nano_urea",
            weight_kg="500ml",
            mrp="₹225",
            valid_from=datetime.now(timezone.utc) - timedelta(days=90),
            valid_until=datetime.now(timezone.utc) + timedelta(days=640),
            is_revoked=False,
            registry_signature="MEQCIBG384mKs...ECDSA_GOVT_REGISTRY_SIGNATURE",
            verification_count="124",
            last_verified_at=datetime.now(timezone.utc) - timedelta(hours=2),
            last_verified_location="Lucknow District Coop Society",
        )

        fert2 = FertilizerRegistry(
            id=uuid.uuid4(),
            product_name="Gromor DAP 18-46-0",
            manufacturer="Coromandel International Limited",
            batch_number="CRMDL-DAP-2026-X12",
            qr_hash=hashlib.sha256("CRMDL-DAP-2026-X12-GENUINE".encode()).hexdigest(),
            seal_pattern_hash=hashlib.sha256("SEAL-PAT-X12".encode()).hexdigest(),
            barcode="8909876543210",
            product_type="dap",
            weight_kg="50kg",
            mrp="₹1,350",
            valid_from=datetime.now(timezone.utc) - timedelta(days=30),
            valid_until=datetime.now(timezone.utc) + timedelta(days=700),
            is_revoked=False,
            registry_signature="MEYCIQCZ483...ECDSA_COROMANDEL_SIG",
            verification_count="48",
            last_verified_at=datetime.now(timezone.utc) - timedelta(days=1),
            last_verified_location="Varanasi Agro Center",
        )

        fert_fake = FertilizerRegistry(
            id=uuid.uuid4(),
            product_name="Counterfeit / Blacklisted Batch (Paras Neem Urea)",
            manufacturer="Unknown / Unauthorized entity",
            batch_number="FAKE-UREA-2025-009",
            qr_hash=hashlib.sha256("FAKE-UREA-2025-009-REVOKED".encode()).hexdigest(),
            seal_pattern_hash=hashlib.sha256("FAKE-SEAL-009".encode()).hexdigest(),
            barcode="8901111222233",
            product_type="urea",
            weight_kg="45kg",
            mrp="₹266",
            valid_from=datetime.now(timezone.utc) - timedelta(days=365),
            valid_until=datetime.now(timezone.utc) - timedelta(days=10),
            is_revoked=True,
            revoked_reason="BANNED BATCH: Laboratory test detected sub-standard 18% nitrogen (standard is 46%). Chemical seal failed cryptographic verification.",
            registry_signature="INVALID_OR_COMPROMISED_KEY",
            verification_count="512",
            last_verified_at=datetime.now(timezone.utc) - timedelta(hours=4),
            last_verified_location="Raebareli Seized Consignment",
        )

        session.add_all([fert1, fert2, fert_fake])

        # 7. Disease Telemetry (For Spatial Kriging)
        telemetry_samples = [
            ("Yellow Rust", 26.8467, 80.9462, 0.94, "high", "Wheat", "UP_LKO"),
            ("Yellow Rust", 26.8900, 80.9700, 0.91, "critical", "Wheat", "UP_LKO"),
            ("Yellow Rust", 26.9200, 81.0100, 0.85, "medium", "Wheat", "UP_LKO"),
            ("Yellow Rust", 27.0500, 80.8900, 0.78, "medium", "Wheat", "UP_STP"),
            ("Yellow Rust", 26.7800, 81.1200, 0.65, "low", "Wheat", "UP_BRB"),
            ("Late Blight", 25.3176, 82.9739, 0.96, "critical", "Potato", "UP_VNS"),
            ("Late Blight", 25.3500, 82.9100, 0.89, "high", "Potato", "UP_VNS"),
            ("Late Blight", 25.2800, 83.0200, 0.82, "high", "Potato", "UP_VNS"),
            ("White Rust", 26.8500, 80.9500, 0.88, "medium", "Mustard", "UP_LKO"),
            ("Rice Blast", 26.4499, 80.3319, 0.92, "critical", "Paddy", "UP_KNP"),
        ]

        for d_name, lat, lon, conf, sev, crop, dist in telemetry_samples:
            dt = DiseaseTelemetry(
                id=uuid.uuid4(),
                disease_name=d_name,
                gps_lat=lat,
                gps_lon=lon,
                district_code=dist,
                state_code="UP",
                confidence=conf,
                severity=sev,
                crop_type=crop,
                wind_speed_kmh=14.0,
                wind_direction_deg=65.0,
                temperature_c=27.0,
                humidity_pct=72.0,
                reported_at=datetime.now(timezone.utc) - timedelta(hours=12),
                processed_for_kriging=False,
            )
            session.add(dt)

        # 8. Insurance Claim
        claim1 = InsuranceClaim(
            id=uuid.uuid4(),
            farmer_id=f1_id,
            policy_number="PMFBY-UP-2026-981245",
            claim_type="hailstorm",
            evidence_video_hash=hashlib.sha256("hailstorm_wheat_damage_video_stream".encode()).hexdigest(),
            evidence_video_url="https://krishi-saarthi.org/evidence/hailstorm_plot1_ramesh.mp4",
            evidence_photos=["https://krishi-saarthi.org/evidence/photo_01.jpg", "https://krishi-saarthi.org/evidence/photo_02.jpg"],
            metadata_signature="ECDSA_TAMPER_PROOF_SENSOR_SIGNATURE_0x98f4c2e",
            device_metadata={
                "device_id": "DEV-KS-LKO-001",
                "sensor_gyro": {"x": 0.02, "y": 0.98, "z": 0.12},
                "gps_accuracy_m": 2.4,
                "timestamp_utc": datetime.now(timezone.utc).isoformat(),
                "tamper_detected": False,
            },
            blockchain_tx_id="0x7f9a8b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a",
            blockchain_network="polygon_pos_testnet",
            claim_status="approved",
            reviewer_notes="Damage confirmed via tamper-proof georeferenced video and weather triangulation (hailstorm detected on 2026-03-02). Settlement initiated.",
            settlement_amount=42500.0,
            gps_lat=26.8467,
            gps_lon=80.9462,
            district_code="UP_LKO",
            submitted_at=datetime.now(timezone.utc) - timedelta(days=2),
            reviewed_at=datetime.now(timezone.utc) - timedelta(days=1),
            settled_at=datetime.now(timezone.utc) - timedelta(hours=8),
        )
        session.add(claim1)

        await session.commit()
        print("[+] Seed complete! Successfully added:")
        print("    - 3 Farmers")
        print("    - 2 Farm plots")
        print("    - 3 Crop diagnoses (with English/Hindi treatments)")
        print(f"    - {len(crops_data)} Mandi price records")
        print("    - 2 Detailed weather caches with 5-day forecasts & advisories")
        print("    - 3 Fertilizer registry items (including counterfeit sample)")
        print(f"    - {len(telemetry_samples)} Disease telemetry points for Kriging")
        print("    - 1 Tamper-proof Insurance claim with blockchain anchor")

    await engine.dispose()
    print("[+] Database is fully prepared for SIH 2026 demonstration!")


if __name__ == "__main__":
    asyncio.run(init_and_seed())
