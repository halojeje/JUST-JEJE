import { TaskGroup, PoolItem, GoogleSyncConfig, SupabaseConfig } from "../types";
import { DEFAULT_PUBLISHABLE_KEY, DEFAULT_SUPABASE_URL } from "./supabase";

const STORAGE_KEYS = {
  TASK_GROUPS: "just_jeje_task_groups",
  GENERATE_POOL: "just_jeje_generate_pool",
  GOOGLE_CONFIG: "just_jeje_google_config",
  SUPABASE_CONFIG: "just_jeje_supabase_config",
};

export const DEFAULT_TASK_GROUPS: TaskGroup[] = [
  {
    id: "group-today",
    title: "Yang Harus Dikerjakan Hari ini!!",
    tasks: [
      {
        id: "task-1",
        text: "Cari tempat printing bagus di dekat rumah sa...",
        completed: false,
        createdAt: Date.now() - 3600000,
      },
    ],
  },
];

export const DEFAULT_POOL_ITEMS: PoolItem[] = [
  {
    id: "pool-1",
    text: "Tulis summary buat Lomba",
    category: "Produktif",
    createdAt: Date.now() - 7200000,
  },
  {
    id: "pool-2",
    text: "Main sama anabul di cafe Kemang",
    category: "Anabul & Santai",
    createdAt: Date.now() - 3600000,
  },
  {
    id: "pool-3",
    text: "Review materi kuliah / riset artikel",
    category: "Belajar",
    createdAt: Date.now() - 1800000,
  },
  {
    id: "pool-4",
    text: "Stretching & minum air putih 1 botol",
    category: "Olahraga",
    createdAt: Date.now() - 900000,
  },
];

export const DEFAULT_GOOGLE_CONFIG: GoogleSyncConfig = {
  clientId: "",
  isConnected: false,
  autoSync: false,
};

export function loadTaskGroups(): TaskGroup[] {
  try {
    const data = localStorage.getItem(STORAGE_KEYS.TASK_GROUPS);
    if (data) {
      return JSON.parse(data);
    }
  } catch (e) {
    console.error("Failed to load task groups", e);
  }
  return DEFAULT_TASK_GROUPS;
}

export function saveTaskGroups(groups: TaskGroup[]): void {
  try {
    localStorage.setItem(STORAGE_KEYS.TASK_GROUPS, JSON.stringify(groups));
  } catch (e) {
    console.error("Failed to save task groups", e);
  }
}

export function loadPoolItems(): PoolItem[] {
  try {
    const data = localStorage.getItem(STORAGE_KEYS.GENERATE_POOL);
    if (data) {
      return JSON.parse(data);
    }
  } catch (e) {
    console.error("Failed to load pool items", e);
  }
  return DEFAULT_POOL_ITEMS;
}

export function savePoolItems(items: PoolItem[]): void {
  try {
    localStorage.setItem(STORAGE_KEYS.GENERATE_POOL, JSON.stringify(items));
  } catch (e) {
    console.error("Failed to save pool items", e);
  }
}

export function loadGoogleConfig(): GoogleSyncConfig {
  try {
    const data = localStorage.getItem(STORAGE_KEYS.GOOGLE_CONFIG);
    if (data) {
      return JSON.parse(data);
    }
  } catch (e) {
    console.error("Failed to load google config", e);
  }
  return DEFAULT_GOOGLE_CONFIG;
}

export function saveGoogleConfig(config: GoogleSyncConfig): void {
  try {
    localStorage.setItem(STORAGE_KEYS.GOOGLE_CONFIG, JSON.stringify(config));
  } catch (e) {
    console.error("Failed to save google config", e);
  }
}

export const DEFAULT_SUPABASE_CONFIG: SupabaseConfig = {
  url: import.meta.env.VITE_SUPABASE_URL || DEFAULT_SUPABASE_URL,
  publishableKey: import.meta.env.VITE_SUPABASE_ANON_KEY || DEFAULT_PUBLISHABLE_KEY,
  isConnected: true,
  autoSync: true,
};

export function loadSupabaseConfig(): SupabaseConfig {
  try {
    const data = localStorage.getItem(STORAGE_KEYS.SUPABASE_CONFIG);
    if (data) {
      const parsed = JSON.parse(data);
      return {
        ...DEFAULT_SUPABASE_CONFIG,
        ...parsed,
        publishableKey: parsed.publishableKey || DEFAULT_SUPABASE_CONFIG.publishableKey,
      };
    }
  } catch (e) {
    console.error("Failed to load supabase config", e);
  }
  return DEFAULT_SUPABASE_CONFIG;
}

export function saveSupabaseConfig(config: SupabaseConfig): void {
  try {
    localStorage.setItem(STORAGE_KEYS.SUPABASE_CONFIG, JSON.stringify(config));
  } catch (e) {
    console.error("Failed to save supabase config", e);
  }
}

