const dotenv = require("dotenv");
const { GoogleGenAI } = require("@google/genai");

dotenv.config();

const apiKey = process.env.GEMINI_API_KEY;
const ai = new GoogleGenAI({ apiKey });

async function listModels() {
    try {
        const response = await ai.models.list();
        console.log("=== Available Models ===");
        for await (const m of response) {
            console.log(`Model: ${m.name} | Display: ${m.displayName} | Methods: ${m.supportedGenerationMethods?.join(', ')}`);
        }
    } catch (e) {
        console.error("List error:", e.message || e);
    }
}

listModels();
