const dotenv = require("dotenv");
const { GoogleGenAI } = require("@google/genai");

dotenv.config();

const apiKey = process.env.GEMINI_API_KEY;
const ai = new GoogleGenAI({ apiKey });

const testModels = [
    "gemini-2.5-flash",
    "gemini-2.5-pro",
    "gemini-2.0-flash",
    "gemini-1.5-flash",
    "gemini-3.6-flash",
    "gemini-3.7-flash",
    "gemini-flash-latest"
];

async function checkModels() {
    console.log("Checking Gemini models availability...");
    for (const model of testModels) {
        try {
            const start = Date.now();
            const res = await ai.models.generateContent({
                model: model,
                contents: "Test OK. Reply: 'Model " + model + " active'",
                config: { maxOutputTokens: 20 }
            });
            const text = res.text ? res.text.trim() : (res.candidates?.[0]?.content?.parts?.[0]?.text || "NO_TEXT");
            console.log(`[OK] ${model} (${Date.now() - start}ms): ${text.replace(/\n/g, ' ')}`);
        } catch (err) {
            console.log(`[FAILED] ${model}: ${err.message || err}`);
        }
    }
}

checkModels();
