import { getSupabaseClient } from "./supabase";
import { TaskGroup, Task, PoolItem } from "../types";

export interface SyncResult {
  success: boolean;
  message: string;
}

export interface RemoteData {
  taskGroups: TaskGroup[];
  poolItems: PoolItem[];
  username?: string;
  theme?: string;
}

/**
 * Menguji apakah koneksi ke Supabase dan tabel yang dibutuhkan sudah ada & bisa diakses.
 */
export async function testSupabaseConnection(): Promise<SyncResult> {
  const supabase = getSupabaseClient();
  if (!supabase) {
    return {
      success: false,
      message: "Supabase Project URL belum diatur. Masukkan URL project Anda terlebih dahulu.",
    };
  }

  try {
    const { error } = await supabase
      .from("task_groups")
      .select("id")
      .limit(1);

    if (error) {
      if (error.code === "42P01") {
        return {
          success: false,
          message: "Koneksi berhasil, namun tabel belum dibuat! Silakan jalankan script supabase/schema.sql di Supabase SQL Editor.",
        };
      }
      return {
        success: false,
        message: `Koneksi gagal: ${error.message}`,
      };
    }

    return {
      success: true,
      message: "Berhasil terhubung ke Supabase Database!",
    };
  } catch (err: unknown) {
    const msg = err instanceof Error ? err.message : String(err);
    return {
      success: false,
      message: `Error koneksi: ${msg}`,
    };
  }
}

/**
 * Mengambil seluruh data (Task Groups, Tasks, Pool Items, Settings) dari Supabase.
 */
export async function fetchRemoteData(): Promise<RemoteData | null> {
  const supabase = getSupabaseClient();
  if (!supabase) return null;

  try {
    // 1. Ambil Groups & Tasks
    const [groupsRes, tasksRes, poolRes, settingsRes] = await Promise.all([
      supabase.from("task_groups").select("*").order("created_at", { ascending: true }),
      supabase.from("tasks").select("*").order("created_at", { ascending: true }),
      supabase.from("pool_items").select("*").order("created_at", { ascending: true }),
      supabase.from("user_settings").select("*").eq("id", "default_user").maybeSingle(),
    ]);

    if (groupsRes.error || tasksRes.error || poolRes.error) {
      console.warn("Gagal fetch data dari Supabase:", groupsRes.error || tasksRes.error || poolRes.error);
      return null;
    }

    const rawTasks = (tasksRes.data || []) as Array<{
      id: string;
      group_id: string;
      text: string;
      completed: boolean;
      created_at: number;
      google_task_id?: string;
    }>;

    // Kelompokkan task ke dalam grup masing-masing
    const taskGroups: TaskGroup[] = ((groupsRes.data || []) as Array<{ id: string; title: string }>).map((g) => {
      const groupTasks: Task[] = rawTasks
        .filter((t) => t.group_id === g.id)
        .map((t) => ({
          id: t.id,
          text: t.text,
          completed: !!t.completed,
          createdAt: Number(t.created_at) || Date.now(),
          googleTaskId: t.google_task_id,
        }));

      return {
        id: g.id,
        title: g.title,
        tasks: groupTasks,
      };
    });

    const poolItems: PoolItem[] = ((poolRes.data || []) as Array<{
      id: string;
      text: string;
      category?: string;
      created_at: number;
    }>).map((p) => ({
      id: p.id,
      text: p.text,
      category: p.category || "Umum",
      createdAt: Number(p.created_at) || Date.now(),
    }));

    return {
      taskGroups,
      poolItems,
      username: settingsRes.data?.username,
      theme: settingsRes.data?.theme,
    };
  } catch (err) {
    console.error("Error fetching remote data from Supabase:", err);
    return null;
  }
}

/**
 * Mengunggah data lokal ke Supabase (Upsert).
 */
export async function pushAllToSupabase(
  taskGroups: TaskGroup[],
  poolItems: PoolItem[],
  username: string,
  theme: string
): Promise<SyncResult> {
  const supabase = getSupabaseClient();
  if (!supabase) {
    return { success: false, message: "Supabase client belum aktif." };
  }

  try {
    // 1. Upsert Groups
    if (taskGroups.length > 0) {
      const groupRows = taskGroups.map((g) => ({
        id: g.id,
        title: g.title,
        updated_at: new Date().toISOString(),
      }));

      const { error: groupErr } = await supabase
        .from("task_groups")
        .upsert(groupRows, { onConflict: "id" });

      if (groupErr) throw groupErr;

      // 2. Upsert Tasks
      const allTasks = taskGroups.flatMap((g) =>
        g.tasks.map((t) => ({
          id: t.id,
          group_id: g.id,
          text: t.text,
          completed: t.completed,
          created_at: t.createdAt,
          google_task_id: t.googleTaskId || null,
          updated_at: new Date().toISOString(),
        }))
      );

      if (allTasks.length > 0) {
        const { error: taskErr } = await supabase
          .from("tasks")
          .upsert(allTasks, { onConflict: "id" });
        if (taskErr) throw taskErr;
      }
    }

    // 3. Upsert Pool Items
    if (poolItems.length > 0) {
      const poolRows = poolItems.map((p) => ({
        id: p.id,
        text: p.text,
        category: p.category || "Umum",
        created_at: p.createdAt,
        updated_at: new Date().toISOString(),
      }));

      const { error: poolErr } = await supabase
        .from("pool_items")
        .upsert(poolRows, { onConflict: "id" });
      if (poolErr) throw poolErr;
    }

    // 4. Upsert User Settings
    const { error: settingsErr } = await supabase.from("user_settings").upsert(
      {
        id: "default_user",
        username: username || "Username",
        theme: theme || "basic",
        updated_at: new Date().toISOString(),
      },
      { onConflict: "id" }
    );
    if (settingsErr) throw settingsErr;

    return {
      success: true,
      message: "Data berhasil disinkronkan ke Supabase Cloud!",
    };
  } catch (err: unknown) {
    const msg = err instanceof Error ? err.message : String(err);
    console.error("Gagal sinkronisasi ke Supabase:", err);
    return {
      success: false,
      message: `Gagal upload ke Supabase: ${msg}`,
    };
  }
}

/**
 * Berlangganan Realtime Postgres Changes di Supabase.
 * Menghubungkan WebSocket agar setiap perubahan data dari perangkat lain langsung diterima.
 */
export function setupRealtimeSubscription(
  onRemoteChange: (payload: unknown) => void
): () => void {
  const supabase = getSupabaseClient();
  if (!supabase) return () => {};

  try {
    const channel = supabase
      .channel("just_jeje_live_changes")
      .on(
        "postgres_changes",
        { event: "*", schema: "public", table: "tasks" },
        (payload) => onRemoteChange(payload)
      )
      .on(
        "postgres_changes",
        { event: "*", schema: "public", table: "task_groups" },
        (payload) => onRemoteChange(payload)
      )
      .on(
        "postgres_changes",
        { event: "*", schema: "public", table: "pool_items" },
        (payload) => onRemoteChange(payload)
      )
      .on(
        "postgres_changes",
        { event: "*", schema: "public", table: "user_settings" },
        (payload) => onRemoteChange(payload)
      )
      .subscribe((status) => {
        if (status === "SUBSCRIBED") {
          console.log("Supabase Realtime tersambung untuk JUST JEJE!");
        }
      });

    return () => {
      supabase.removeChannel(channel);
    };
  } catch (err) {
    console.warn("Gagal inisialisasi Realtime subscription:", err);
    return () => {};
  }
}
