window.APP_CONFIG = {
  SUPABASE_URL: "https://chcfhxkggbrlxaopnfum.supabase.co",
  SUPABASE_PUBLISHABLE_KEY: "sb_publishable_rwCYiLLLcYCOm7X9JXxAtQ_9ailfQ6D"
};

window.getSupabase = function () {
  if (!window.supabase) {
    throw new Error("Supabase library did not load.");
  }

  if (
    !window.APP_CONFIG ||
    !window.APP_CONFIG.SUPABASE_URL ||
    !window.APP_CONFIG.SUPABASE_PUBLISHABLE_KEY
  ) {
    throw new Error("Supabase configuration is missing.");
  }

  if (!window._supabaseClient) {
    window._supabaseClient = window.supabase.createClient(
      window.APP_CONFIG.SUPABASE_URL,
      window.APP_CONFIG.SUPABASE_PUBLISHABLE_KEY,
      {
        auth: {
          persistSession: true,
          autoRefreshToken: true,
          detectSessionInUrl: false,
          storageKey: "synagogue-message-board-auth"
        }
      }
    );
  }

  return window._supabaseClient;
};
