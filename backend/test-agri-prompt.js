const dotenv = require("dotenv");
const { GoogleGenAI } = require("@google/genai");

dotenv.config();

const apiKey = process.env.GEMINI_API_KEY;
const ai = new GoogleGenAI({ apiKey });

const SYSTEM_INSTRUCTION = `You are "Agri-Saarthi" (कृषि-सारथी), an expert agricultural advisory AI.
Provide direct, practical, scientifically sound, location-aware farming recommendations.
Tone should adapt to the farmer's mood (warm, friendly, respectful, or reassuring).
Never guarantee yields or profits. Keep spoken answers clean and easy to listen to.`;

const modelsToTest = [
    "gemini-3.6-flash",
    "gemini-3.7-flash",
    "gemini-3.5-flash",
    "gemini-3.1-flash-lite",
    "gemini-flash-latest"
];

async function testAgriQuery() {
    for (const model of modelsToTest) {
        try {
            console.log(`\n--- Testing ${model} ---`);
            const res = await ai.models.generateContent({
                model: model,
                contents: [{ role: "user", parts: [{ text: "My farm is at a high altitude in Himachal Pradesh. What crops should I grow?" }] }],
                config: {
                    systemInstruction: SYSTEM_INSTRUCTION,
                    temperature: 0.7,
                    maxOutputTokens: 300
                }
            });
            console.log(`[SUCCESS with ${model}]:`);
            console.log(res.text);
            break;
        } catch (e) {
            console.log(`[FAILED on ${model}]: ${e.message || e}`);
        }
    }
}

testAgriQuery();
