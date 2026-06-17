import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*", // ou ton domaine précis
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization",
};

serve(async (req) => {
  // Preflight CORS
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: CORS_HEADERS });
  }

  try {
    const payload = await req.json();

    // 👇 log du payload envoyé à l'API externe
    console.log("Payload envoyé à surveysingles:", JSON.stringify(payload));

    const response = await fetch(
      "https://api-fans-med.satisfactive.fr/surveysingles",
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
      }
    );

    const data = await response.text();

    // 👇 log du statut + corps de la réponse de l'API externe
    console.log("Réponse surveysingles - status:", response.status);
    console.log("Réponse surveysingles - body:", data);

    return new Response(data, {
      status: response.status,
      headers: {
        ...CORS_HEADERS,
        "Content-Type": response.headers.get("Content-Type") ?? "application/json",
      },
    });
  } catch (e) {
    console.log("Exception dans proxy-survey:", String(e));
    return new Response(JSON.stringify({ error: String(e) }), {
      status: 500,
      headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
    });
  }
});