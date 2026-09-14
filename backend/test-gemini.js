const dotenv = require("dotenv");
const { GoogleGenAI } = require("@google/genai");

dotenv.config();

const apiKey = process.env.GEMINI_API_KEY;

async function testSDK() {
    try {
        const ai = new GoogleGenAI({ apiKey });
        console.log("Calling ai.models.generateContent with gemini-3.6-flash...");
        const response = await ai.models.generateContent({
            model: "gemini-3.6-flash",
            contents: "Say hello in one short sentence as Agri-Sarathi AI."
        });
        console.log("SDK Success (generateContent):", response.text);
    } catch (e) {
        console.error("SDK generateContent Error:", e.message || e);
    }

    try {
        const ai = new GoogleGenAI({ apiKey });
        console.log("Calling ai.interactions.create with gemini-3.6-flash...");
        const interaction = await ai.interactions.create({
            model: "gemini-3.6-flash",
            input: "Say hello in one short sentence as Agri-Sarathi AI."
        });
        console.log("SDK Success (interactions):", interaction.output_text || interaction.output?.text || interaction);
    } catch (e) {
        console.error("SDK interactions Error:", e.message || e);
    }
}

testSDK();
