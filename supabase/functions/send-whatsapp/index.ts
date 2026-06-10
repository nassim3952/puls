// supabase/functions/send-whatsapp/index.ts
// ─────────────────────────────────────────────────────────────────────────────
// Edge Function pour envoyer un message WhatsApp via WaSender
// Avec support CORS
// ─────────────────────────────────────────────────────────────────────────────

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';

interface RequestBody {
  phone: string;
  message: string;
}

interface WaSenderResponse {
  success: boolean;
  result?: {
    messageId: string;
  };
  message?: string;
}

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
};

serve(async (req: Request) => {
  // ── Gérer les requêtes CORS OPTIONS ─────────────────────────────────────
  if (req.method === 'OPTIONS') {
    return new Response('OK', { headers: corsHeaders });
  }

  // Accepter uniquement POST
  if (req.method !== 'POST') {
    return new Response(
      JSON.stringify({ success: false, error: 'Method not allowed' }),
      {
        status: 405,
        headers: { 'Content-Type': 'application/json', ...corsHeaders },
      }
    );
  }

  try {
    const body: RequestBody = await req.json();
    const { phone, message } = body;

    // Validations
    if (!phone || !message) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'phone et message sont requis',
        }),
        {
          status: 400,
          headers: { 'Content-Type': 'application/json', ...corsHeaders },
        }
      );
    }

    // Récupère la clé API depuis les variables d'environnement
    const apiKey = Deno.env.get('WASENDER_API_KEY');
    if (!apiKey) {
      console.error('WASENDER_API_KEY not configured');
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Configuration serveur manquante',
        }),
        {
          status: 500,
          headers: { 'Content-Type': 'application/json', ...corsHeaders },
        }
      );
    }

    // Appel WaSender API
    const wasenderResponse = await fetch('https://wasenderapi.com/api/send-message', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${apiKey}`,
      },
      body: JSON.stringify({
        to: phone,
        text: message,
      }),
    });

    const wasenderData: WaSenderResponse = await wasenderResponse.json();

    // Gestion de la réponse WaSender
    if (!wasenderResponse.ok || !wasenderData.success) {
      console.error('WaSender error:', wasenderData.message || wasenderResponse.statusText);
      return new Response(
        JSON.stringify({
          success: false,
          error: wasenderData.message || 'Erreur WaSender',
        }),
        {
          status: 400,
          headers: { 'Content-Type': 'application/json', ...corsHeaders },
        }
      );
    }

    // Succès
    return new Response(
      JSON.stringify({
        success: true,
        messageId: wasenderData.result?.messageId || 'unknown',
      }),
      {
        status: 200,
        headers: { 'Content-Type': 'application/json', ...corsHeaders },
      }
    );
  } catch (error) {
    console.error('Unexpected error:', error);
    return new Response(
      JSON.stringify({
        success: false,
        error: 'Erreur serveur',
      }),
      {
        status: 500,
        headers: { 'Content-Type': 'application/json', ...corsHeaders },
      }
    );
  }
});