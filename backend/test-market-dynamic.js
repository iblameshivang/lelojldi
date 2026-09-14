/**
 * Verification Script for Real Dynamic Crop Selection & Government Mandi API
 */
const http = require('http');

function makeRequest(path, method = 'GET', body = null) {
    return new Promise((resolve, reject) => {
        const payload = body ? JSON.stringify(body) : null;
        const options = {
            hostname: 'localhost',
            port: 3000,
            path: path,
            method: method,
            headers: {
                'Content-Type': 'application/json',
                ...(payload ? { 'Content-Length': Buffer.byteLength(payload) } : {})
            }
        };

        const req = http.request(options, (res) => {
            let data = '';
            res.on('data', chunk => data += chunk);
            res.on('end', () => {
                try {
                    const parsed = JSON.parse(data);
                    resolve({ status: res.statusCode, body: parsed });
                } catch (e) {
                    resolve({ status: res.statusCode, raw: data });
                }
            });
        });

        req.on('error', reject);
        if (payload) req.write(payload);
        req.end();
    });
}

async function verifyAll() {
    console.log("==================================================================");
    console.log("🌾 VERIFYING DYNAMIC REAL MARKET COMMODITIES & AGMARKNET DATA");
    console.log("==================================================================");

    // 1. Available Crops endpoint returns real commodities
    console.log("\n[1] GET /api/market/available-crops for Solan, HP");
    const cropsRes = await makeRequest('/api/market/available-crops?state=Himachal%20Pradesh&district=Solan');
    console.log("Status:", cropsRes.status);
    console.log("Success:", cropsRes.body?.success);
    console.log("Source:", cropsRes.body?.source);
    console.log("Available Real Commodities Count:", cropsRes.body?.crops?.length);
    console.log("Real Commodities List:", cropsRes.body?.crops);

    if (!Array.isArray(cropsRes.body?.crops) || cropsRes.body.crops.length === 0) {
        throw new Error("Available crops endpoint returned no commodities");
    }

    // 2. All Crops Query returns records
    console.log("\n[2] GET /api/market/search (All Crops)");
    const allRes = await makeRequest('/api/market/search?state=Himachal%20Pradesh&district=Solan');
    console.log("Status:", allRes.status);
    console.log("Total Verified Records Found:", allRes.body?.count);
    console.log("Extracted Available Crops from Payload:", allRes.body?.availableCrops);

    // 3. Wheat Query
    console.log("\n[3] GET /api/market/search?crop=Wheat");
    const wheatRes = await makeRequest('/api/market/search?crop=Wheat&state=Himachal%20Pradesh&district=Solan');
    console.log("Status:", wheatRes.status);
    console.log("Wheat Records Found:", wheatRes.body?.count);
    if (wheatRes.body?.results?.length > 0) {
        const top = wheatRes.body.results[0];
        console.log(`Top Record: ${top.commodity} (${top.variety}) in ${top.market}, ${top.state}`);
        console.log(`Prices: Modal ₹${top.modalPrice} | Min ₹${top.minPrice} | Max ₹${top.maxPrice}`);
        console.log(`Source: ${top.source} | Date: ${top.date}`);
    }

    // 4. Test Selecting another real commodity from available crops (e.g. Apple or Tomato or Bhindi)
    const testCrop = cropsRes.body.crops.find(c => c !== 'Wheat') || cropsRes.body.crops[0];
    console.log(`\n[4] GET /api/market/search?crop=${encodeURIComponent(testCrop)} (Real Dynamic Crop Selection)`);
    const dynamicCropRes = await makeRequest(`/api/market/search?crop=${encodeURIComponent(testCrop)}&state=Himachal%20Pradesh&district=Solan`);
    console.log("Status:", dynamicCropRes.status);
    console.log(`Records Found for ${testCrop}:`, dynamicCropRes.body?.count);
    if (dynamicCropRes.body?.results?.length > 0) {
        const top = dynamicCropRes.body.results[0];
        console.log(`Top Record: ${top.commodity} (${top.variety}) in ${top.market}, ${top.district}`);
        console.log(`Modal: ₹${top.modalPrice} | Min: ₹${top.minPrice} | Max: ₹${top.maxPrice}`);
    }

    // 5. Zero Fake Data: Dragonfruit check
    console.log("\n[5] Zero Fake Data Check: Non-existent commodity (Dragonfruit)");
    const fakeCropRes = await makeRequest('/api/market/search?crop=Dragonfruit&state=Punjab');
    console.log("Count:", fakeCropRes.body?.count);
    console.log("Message:", fakeCropRes.body?.message);
    if (fakeCropRes.body?.results?.length !== 0) {
        throw new Error("Fake crop returned results!");
    }

    // 6. Security Check: Ensure API key is NOT in response payload
    const rawAll = JSON.stringify(allRes.body);
    const hasRawKey = rawAll.includes('579b464db66ec23bdd000001');
    const hasKeyName = rawAll.includes('DATA_GOV_API_KEY');
    console.log("\n[6] Security & Privacy Check:");
    console.log("API Key exposed in response?", hasRawKey ? "❌ FAIL (Exposed)" : "✅ PASS (Not exposed)");
    console.log("DATA_GOV_API_KEY string exposed?", hasKeyName ? "❌ FAIL (Exposed)" : "✅ PASS (Not exposed)");

    if (hasRawKey || hasKeyName) {
        throw new Error("Security violation: API Key was exposed in client response");
    }

    console.log("\n==================================================================");
    console.log("✅ ALL DYNAMIC MARKET & REAL COMMODITY VERIFICATION TESTS PASSED!");
    console.log("==================================================================");
}

verifyAll().catch(err => {
    console.error("Verification failed:", err);
    process.exit(1);
});
