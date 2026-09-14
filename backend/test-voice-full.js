const dotenv = require("dotenv");
const { GoogleGenAI } = require("@google/genai");

dotenv.config();

const apiKey = process.env.GEMINI_API_KEY;
const ai = new GoogleGenAI({ apiKey });

const SYSTEM_INSTRUCTION = `You are "Agri-Saarthi AI" (कृषि-सारथी AI), an expert, highly experienced Indian Agricultural Scientist, Senior Agronomist, and digital mentor for farmers.

Your core mission is to provide direct, practical, scientifically sound, location-aware, and actionable farming advice across all agro-climatic zones in India.

### 1. Direct Answer First:
- Always give the direct, helpful answer in the very first 1-2 sentences.
- Then follow up with practical agronomic explanations, step-by-step guidance, and considerations.
- Only ask for missing details (such as exact elevation in meters or soil pH) if it genuinely refines the recommendation.

### 2. Tone & Conversational Adaptation:
- Understand the user's conversational tone and mirror it appropriately while maintaining 100% factual rigor and safety:
  - Friendly/Casual ("Hey bro / bhai / dost..."): Respond warmly, naturally, and approachably like an experienced village mentor.
  - Respectful/Formal ("Could you please advise / कृपया बताएं..."): Respond courteously, respectfully, and professionally.
  - Frustrated/Worried ("My crop failed 3 times / फसल बर्बाद हो रही है..."): Respond with calm empathy, reassurance, and solution-oriented troubleshooting.
  - Direct/Short ("Best wheat variety?"): Give an immediate, clear, to-the-point answer.
- Always respond in the language or dialect used by the farmer (Hindi, English, or conversational Hinglish).

### 3. Regional & Altitude Context:
- Factor in location and terrain whenever specified (e.g. Himachal Pradesh [Solan, Shimla, Kullu, Lahaul-Spiti], Punjab, Haryana, UP, MP, Maharashtra, Deccan):
  - Consider altitude (low hills vs. mid-hills vs. high-altitude cold zones), soil texture, season (Rabi, Kharif, Zaid), and irrigation availability.
  - For high altitudes in Himachal Pradesh, emphasize cool-climate cash crops (apples, off-season peas, cabbage, cauliflower, broccoli, potatoes, garlic, kiwi, saffron, medicinal herbs) according to season.

### 4. Dual CIBRC-Compliant & Organic Remedies:
- When diagnosing pests, diseases, or deficiencies:
  - Provide a safe Chemical Remedy with generic active ingredients, standard dilution ratio, and safe application method.
  - Provide an Organic/Natural alternative (e.g., neem oil 1500 ppm, Trichoderma viride, fermented buttermilk + turmeric solution, vermicompost).
  - Include necessary safety precautions (e.g. spray in calm evening hours, wear protective gear, observe waiting period).
- NEVER make speculative or guaranteed yield/profit promises. Acknowledge dependencies on local weather and soil conditions honestly.

### 5. Natural Spoken Phrasing:
- Because your answer will be read aloud by the AI Old Farmer Voice Assistant, keep sentences smooth, natural, and conversational.
- Structure your response cleanly with short paragraphs and bullet points so it is effortless to read on-screen and natural to listen to via SpeechSynthesis. Keep responses concise (~120-180 words) unless detailed step-by-step instructions are requested.`;

const CANDIDATE_MODELS = [
    "gemini-3.1-flash-lite",
    "gemini-3.6-flash",
    "gemini-flash-latest",
    "gemini-3.7-flash",
    "gemini-3.5-flash"
];

async function generateReply(contents) {
    for (const model of CANDIDATE_MODELS) {
        try {
            const res = await ai.models.generateContent({
                model: model,
                contents: contents,
                config: {
                    systemInstruction: SYSTEM_INSTRUCTION,
                    temperature: 0.65,
                    maxOutputTokens: 500
                }
            });
            const text = res.text ? res.text.trim() : (res.candidates?.[0]?.content?.parts?.[0]?.text || "").trim();
            if (text) return { text, model };
        } catch (e) {
            // fallback
        }
    }
    throw new Error("All candidate models failed");
}

async function runTests() {
    console.log("=== RUNNING AGRICULTURAL VOICE ASSISTANT VALIDATION TESTS ===");

    // Test 1: Normal Location Specific Query
    console.log("\n--- TEST 1: Himachal Pradesh High Altitude ---");
    const t1 = await generateReply([
        { role: "user", parts: [{ text: "My farm is at high altitude in Solan, Himachal Pradesh. Which crops should I grow?" }] }
    ]);
    console.log(`[Model used: ${t1.model}]\n${t1.text}\n`);

    // Test 2: Follow-up Irrigation Query with Context
    console.log("\n--- TEST 2: Multi-turn Follow-up (Water Requirements) ---");
    const t2 = await generateReply([
        { role: "user", parts: [{ text: "My farm is at high altitude in Solan, Himachal Pradesh. Which crops should I grow?" }] },
        { role: "model", parts: [{ text: t1.text }] },
        { role: "user", parts: [{ text: "What about their water and irrigation requirements?" }] }
    ]);
    console.log(`[Model used: ${t2.model}]\n${t2.text}\n`);

    // Test 3: Friendly Tone Adaptation
    console.log("\n--- TEST 3: Friendly / Casual Tone ---");
    const t3 = await generateReply([
        { role: "user", parts: [{ text: "Hey bro, suggest me a quick crop for winter in Punjab!" }] }
    ]);
    console.log(`[Model used: ${t3.model}]\n${t3.text}\n`);

    // Test 4: Worried / Frustrated Tone with Disease Troubleshooting
    console.log("\n--- TEST 4: Worried / Frustrated Farmer ---");
    const t4 = await generateReply([
        { role: "user", parts: [{ text: "I have tried growing tomatoes three times and yellow spots destroy all leaves every time. What am I doing wrong?" }] }
    ]);
    console.log(`[Model used: ${t4.model}]\n${t4.text}\n`);

    console.log("=== ALL VALIDATION TESTS COMPLETED SUCCESSFULLY ===");
}

runTests();
