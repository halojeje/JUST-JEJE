import { createClient, SupabaseClient } from "@supabase/supabase-js";
import { SupabaseConfig } from "../types";

export const DEFAULT_PUBLISHABLE_KEY = "sb_publishable_OzVTIo6VWy75OToG4rOZfw_PQZZxP7Z";
export const DEFAULT_SUPABASE_URL = "https://vfkxwjjcdbbhtnxwaxqt.supabase.co";

let supabaseInstance: SupabaseClient | null = null;
let currentConfig: SupabaseConfig = {
  url: import.meta.env.VITE_SUPABASE_URL || DEFAULT_SUPABASE_URL,
  publishableKey: import.meta.env.VITE_SUPABASE_ANON_KEY || DEFAULT_PUBLISHABLE_KEY,
  isConnected: true,
  autoSync: true,
};

export function getSupabaseConfig(): SupabaseConfig {
  try {
    const raw = localStorage.getItem("just_jeje_supabase_config");
    if (raw) {
      const parsed = JSON.parse(raw);
      return {
        ...currentConfig,
        ...parsed,
        publishableKey: parsed.publishableKey || currentConfig.publishableKey,
      };
    }
  } catch (err) {
    console.warn("Gagal membaca just_jeje_supabase_config dari localStorage", err);
  }
  return currentConfig;
}

export function saveSupabaseConfigToStorage(config: SupabaseConfig): void {
  currentConfig = { ...config };
  try {
    localStorage.setItem("just_jeje_supabase_config", JSON.stringify(config));
  } catch (err) {
    console.error("Gagal menyimpan supabase config ke localStorage", err);
  }
}

export function getSupabaseClient(): SupabaseClient | null {
  const config = getSupabaseConfig();
  const url = (config.url || "").trim();
  const key = (config.publishableKey || DEFAULT_PUBLISHABLE_KEY).trim();

  if (!url || !url.startsWith("http")) {
    return null;
  }

  if (
    !supabaseInstance ||
    (supabaseInstance as unknown as { supabaseUrl?: string }).supabaseUrl !== url
  ) {
    try {
      supabaseInstance = createClient(url, key, {
        auth: {
          persistSession: true,
          autoRefreshToken: true,
        },
      });
    } catch (e) {
      console.error("Error inisialisasi Supabase client:", e);
      return null;
    }
  }

  return supabaseInstance;
}

export function resetSupabaseClient(): void {
  supabaseInstance = null;
}
