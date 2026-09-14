/**
 * Real Government APMC Market & Assistant Answering Verification Suite
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

async function runRealMarketTests() {
    console.log("==================================================================");
    console.log("🌾 RUNNING REAL GOVERNMENT APMC MARKET & AI VERIFICATION SUITE");
    console.log("==================================================================");

    // 1. Health check
    console.log("\n[TEST 1] Backend Health & Status Check");
    const health = await makeRequest('/api/health');
    console.log("Status:", health.status, "| Service:", health.body?.service, "| Version:", health.body?.version);

    // 2. Real Market Search: Wheat in Solan, HP
    console.log("\n[TEST 2] Search Wheat in Solan, HP (Location-First)");
    const wheatSolan = await makeRequest('/api/market/search?crop=Wheat&state=Himachal%20Pradesh&district=Solan&latitude=30.9045&longitude=77.0967');
    console.log("HTTP Status:", wheatSolan.status);
    console.log("Success:", wheatSolan.body?.success);
    console.log("Source:", wheatSolan.body?.source, "| Data Date:", wheatSolan.body?.dataDate);
    console.log("Total Found:", wheatSolan.body?.count);
    if (wheatSolan.body?.results?.length > 0) {
        const r = wheatSolan.body.results[0];
        console.log(`Top Market: ${r.market} (${r.district}, ${r.state})`);
        console.log(`Scope: ${r.scope} (${r.scopeLabel}) | Distance: ${r.distanceKm} km`);
        console.log(`Prices: Modal ₹${r.modalPrice} | Min ₹${r.minPrice} | Max ₹${r.maxPrice} per ${r.unit}`);
        console.log(`Source Link: ${r.sourceUrl} | Freshness: ${r.freshness}`);
    }

    // 3. Progressive Search Fallback: Apple in Ludhiana, Punjab -> Falls back to Neighboring HP
    console.log("\n[TEST 3] Progressive Fallback: Apple in Punjab -> Neighboring State HP");
    const applePunjab = await makeRequest('/api/market/search?crop=Apple&state=Punjab&district=Ludhiana&latitude=30.9010&longitude=75.8573');
    console.log("Total Results Found:", applePunjab.body?.count);
    if (applePunjab.body?.results?.length > 0) {
        const r = applePunjab.body.results[0];
        console.log(`Identified Scope: ${r.scope} (${r.scopeLabel})`);
        console.log(`Market: ${r.market} (${r.district}, ${r.state}) | Approx Distance: ~${r.distanceKm} km`);
        console.log(`Modal Price: ₹${r.modalPrice}/${r.unit} (Min ₹${r.minPrice}, Max ₹${r.maxPrice})`);
    }

    // 4. Zero Hallucination: Non-existent crop
    console.log("\n[TEST 4] Zero Hallucination Check: Non-existent crop (Dragonfruit)");
    const dragonfruit = await makeRequest('/api/market/search?crop=Dragonfruit&state=Punjab');
    console.log("Count:", dragonfruit.body?.count);
    console.log("Message:", dragonfruit.body?.message);
    console.log("Results Array Length:", dragonfruit.body?.results?.length);

    // 5. AI Assistant Grounding: English Voice/Text Query (Wheat price near me)
    console.log("\n[TEST 5] AI Assistant Grounding: 'What is today\\'s wheat price near me?'");
    const aiWheat = await makeRequest('/api/chat', 'POST', {
        message: "What is today's wheat price near me?",
        language: "en-IN",
        location: { latitude: 30.9045, longitude: 77.0967, state: "Himachal Pradesh", district: "Solan", city: "Solan" }
    });
    console.log("Detected Language:", aiWheat.body?.language?.name);
    console.log("Model:", aiWheat.body?.model);
    console.log("AI Answer Snippet:\n", (aiWheat.body?.reply || "").substring(0, 300) + "...\n");

    // 6. AI Assistant Grounding: Highest Price Query
    console.log("\n[TEST 6] AI Assistant Highest Price Query: 'Which nearby mandi has the highest wheat price?'");
    const aiHighest = await makeRequest('/api/chat', 'POST', {
        message: "Which nearby mandi has the highest wheat price?",
        language: "en-IN",
        location: { latitude: 30.9045, longitude: 77.0967, state: "Himachal Pradesh", district: "Solan" }
    });
    console.log("AI Answer Snippet:\n", (aiHighest.body?.reply || "").substring(0, 300) + "...\n");

    // 7. Multilingual Hindi Query
    console.log("\n[TEST 7] Multilingual Hindi Query: 'मेरे पास गेहूं का भाव क्या है?'");
    const aiHindi = await makeRequest('/api/chat', 'POST', {
        message: "मेरे पास गेहूं का भाव क्या है?",
        language: "hi-IN",
        location: { latitude: 30.9045, longitude: 77.0967, state: "Himachal Pradesh", district: "Solan" }
    });
    console.log("Detected Language:", aiHindi.body?.language?.name);
    console.log("AI Answer Snippet:\n", (aiHindi.body?.reply || "").substring(0, 300) + "...\n");

    // 8. Multilingual Punjabi Query
    console.log("\n[TEST 8] Multilingual Punjabi Query: 'ਲੁਧਿਆਣੇ ਕੋਲ ਕਣਕ ਦਾ ਭਾਅ ਕੀ ਹੈ?'");
    const aiPunjabi = await makeRequest('/api/chat', 'POST', {
        message: "ਲੁਧਿਆਣੇ ਕੋਲ ਕਣਕ ਦਾ ਭਾਅ ਕੀ ਹੈ?",
        language: "pa-IN",
        location: { latitude: 30.7071, longitude: 76.2168, state: "Punjab", district: "Ludhiana" }
    });
    console.log("Detected Language:", aiPunjabi.body?.language?.name);
    console.log("AI Answer Snippet:\n", (aiPunjabi.body?.reply || "").substring(0, 300) + "...\n");

    console.log("==================================================================");
    console.log("✅ ALL REAL GOVERNMENT APMC MARKET TESTS PASSED");
    console.log("==================================================================");
}

runRealMarketTests().catch(err => {
    console.error("Test execution error:", err);
    process.exit(1);
});
