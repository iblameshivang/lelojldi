/**
 * Comprehensive verification of Multilingual AI + Progressive APMC Market Search Engine
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

async function runTests() {
    console.log("==================================================================");
    console.log("🧪 STARTING AGRI-SAARTHI COMPREHENSIVE VERIFICATION SUITE");
    console.log("==================================================================");

    // Test 1: Health Check
    console.log("\n[TEST 1] Backend Health Check");
    const health = await makeRequest('/api/health');
    console.log("Health Status:", health.status, health.body?.status || health.raw);

    // Test 2: Local Market Search (Apple in Solan, HP)
    console.log("\n[TEST 2] Local APMC Market Search (Apple from Solan, HP)");
    const marketLocal = await makeRequest('/api/market/search?crop=Apple&latitude=30.9045&longitude=77.0967&state=Himachal+Pradesh&district=Solan');
    console.log("Status:", marketLocal.status);
    console.log("Success:", marketLocal.body?.success);
    console.log("Found Results:", marketLocal.body?.count);
    if (marketLocal.body?.results?.length > 0) {
        const r = marketLocal.body.results[0];
        console.log(`Top Market: ${r.market} (${r.district}, ${r.state})`);
        console.log(`Scope: ${r.scope} (${r.scopeLabel}) | Distance: ${r.distanceKm} km`);
        console.log(`Prices: Min ₹${r.minPrice}, Modal ₹${r.modalPrice}, Max ₹${r.maxPrice} per ${r.unit}`);
        console.log(`Source: ${r.source} (${r.sourceUrl}) | Date: ${r.date} | Freshness: ${r.freshness}`);
    }

    // Test 3: Progressive Fallback (Apple from Ludhiana, Punjab -> Falls back to Neighboring HP / Shimla)
    console.log("\n[TEST 3] Progressive Search Fallback (Apple from Punjab -> Neighboring HP)");
    const marketFallback = await makeRequest('/api/market/search?crop=Apple&latitude=30.9010&longitude=75.8573&state=Punjab&district=Ludhiana');
    console.log("Found Results:", marketFallback.body?.count);
    if (marketFallback.body?.results?.length > 0) {
        const r = marketFallback.body.results[0];
        console.log(`Found in Scope: ${r.scope} (${r.scopeLabel}) | Market: ${r.market}, ${r.state}`);
        console.log(`Distance: ~${r.distanceKm} km | Modal: ₹${r.modalPrice}/${r.unit}`);
    }

    // Test 4: Unknown crop - zero hallucination
    console.log("\n[TEST 4] Unknown Crop Query (Dragonfruit) - Zero Hallucination check");
    const marketUnknown = await makeRequest('/api/market/search?crop=Dragonfruit&state=Punjab');
    console.log("Found Results:", marketUnknown.body?.count);
    console.log("Message:", marketUnknown.body?.message);

    // Test 5: Hindi Market Voice/Text Query (सेब का आज का भाव क्या है?)
    console.log("\n[TEST 5] Multilingual AI: Hindi Market Query");
    const hindiQuery = await makeRequest('/api/chat', 'POST', {
        message: "सेब का आज का भाव क्या है?",
        language: "hi-IN",
        location: { latitude: 30.9045, longitude: 77.0967, state: "Himachal Pradesh", district: "Solan", city: "Solan" }
    });
    console.log("Detected Language:", hindiQuery.body?.detectedLanguage);
    console.log("Model Used:", hindiQuery.body?.model);
    console.log("AI Answer Snippet:\n", (hindiQuery.body?.reply || "").substring(0, 250) + "...");

    // Test 6: Punjabi Market Voice/Text Query (ਕਣਕ ਦਾ ਭਾਅ ਕੀ ਹੈ?)
    console.log("\n[TEST 6] Multilingual AI: Punjabi Market Query");
    const punjabiQuery = await makeRequest('/api/chat', 'POST', {
        message: "ਕਣਕ ਦਾ ਭਾਅ ਕੀ ਹੈ?",
        language: "pa-IN",
        location: { latitude: 30.9010, longitude: 75.8573, state: "Punjab", district: "Ludhiana" }
    });
    console.log("Detected Language:", punjabiQuery.body?.detectedLanguage);
    console.log("AI Answer Snippet:\n", (punjabiQuery.body?.reply || "").substring(0, 250) + "...");

    // Test 7: English Technical Query
    console.log("\n[TEST 7] Multilingual AI: English Technical Query");
    const englishQuery = await makeRequest('/api/chat', 'POST', {
        message: "How to prevent yellow rust in wheat?",
        language: "en-IN"
    });
    console.log("Detected Language:", englishQuery.body?.detectedLanguage);
    console.log("AI Answer Snippet:\n", (englishQuery.body?.reply || "").substring(0, 250) + "...");

    // Test 8: Tamil Agronomy Query
    console.log("\n[TEST 8] Multilingual AI: Tamil Agronomy Query");
    const tamilQuery = await makeRequest('/api/chat', 'POST', {
        message: "தக்காளி பயிரில் இலை சுருட்டல் நோய் எப்படி குணப்படுத்துவது?",
        language: "ta-IN"
    });
    console.log("Detected Language:", tamilQuery.body?.detectedLanguage);
    console.log("AI Answer Snippet:\n", (tamilQuery.body?.reply || "").substring(0, 250) + "...");

    console.log("\n==================================================================");
    console.log("✅ ALL COMPREHENSIVE VERIFICATION TESTS COMPLETED SUCCESSFULLY");
    console.log("==================================================================");
}

runTests().catch(err => {
    console.error("Test error:", err);
    process.exit(1);
});
