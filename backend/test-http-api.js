const http = require("http");

function postQuery(endpoint, payload) {
    return new Promise((resolve, reject) => {
        const data = JSON.stringify(payload);
        const req = http.request({
            hostname: "localhost",
            port: 3000,
            path: endpoint,
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "Content-Length": Buffer.byteLength(data)
            }
        }, (res) => {
            let body = "";
            res.on("data", chunk => body += chunk);
            res.on("end", () => {
                try {
                    resolve({ status: res.statusCode, data: JSON.parse(body) });
                } catch (e) {
                    resolve({ status: res.statusCode, body });
                }
            });
        });
        req.on("error", reject);
        req.write(data);
        req.end();
    });
}

async function runTests() {
    console.log("=== RUNNING LIVE HTTP TESTS AGAINST BACKEND ON PORT 3000 ===");

    // Test 1: Exactly the user's question
    console.log("\n--- TEST 1: User's Text Mode Question ---");
    const q1 = "What kind of problem can happen in the wheat crop?";
    const r1 = await postQuery("/api/assistant/chat", {
        message: q1,
        language: "English",
        crops: ["Wheat"],
        location: { city: "Solan", district: "Solan", state: "Himachal Pradesh" }
    });
    console.log(`Status: ${r1.status} | Model: ${r1.data?.model} | Success: ${r1.data?.success}`);
    console.log(`Answer:\n${r1.data?.answer}\n`);

    // Test 2: Hindi Disease Diagnosis
    console.log("\n--- TEST 2: Hindi Crop Problem ---");
    const q2 = "गेहूं में पीली पत्तियां क्यों हो रही हैं?";
    const r2 = await postQuery("/api/assistant/chat", {
        message: q2,
        language: "Hindi",
        crops: ["Wheat"]
    });
    console.log(`Status: ${r2.status} | Success: ${r2.data?.success}`);
    console.log(`Answer:\n${r2.data?.answer}\n`);

    // Test 3: Market Question Grounding
    console.log("\n--- TEST 3: Market Mandi Benchmark Query ---");
    const q3 = "What is the latest market price of wheat in Solan and Lucknow?";
    const r3 = await postQuery("/api/assistant/chat", {
        message: q3,
        language: "English"
    });
    console.log(`Status: ${r3.status} | Grounded: ${r3.data?.metadata?.grounded} | Success: ${r3.data?.success}`);
    console.log(`Answer:\n${r3.data?.answer}\n`);

    console.log("=== ALL LIVE HTTP TESTS FINISHED SUCCESSFULLY ===");
}

runTests().catch(err => {
    console.error("Test error:", err);
    process.exit(1);
});
