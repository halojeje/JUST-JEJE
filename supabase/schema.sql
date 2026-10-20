-- ==============================================================================
-- JUST JEJE - Supabase Database Schema
-- Jalankan seluruh script SQL ini di Supabase Dashboard -> SQL Editor -> Run
-- ==============================================================================

-- 1. Tabel Grup Tugas (Task Groups)
CREATE TABLE IF NOT EXISTS public.task_groups (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    created_at BIGINT DEFAULT (extract(epoch from now()) * 1000)::bigint,
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- 2. Tabel Tugas (Tasks)
CREATE TABLE IF NOT EXISTS public.tasks (
    id TEXT PRIMARY KEY,
    group_id TEXT NOT NULL REFERENCES public.task_groups(id) ON DELETE CASCADE,
    text TEXT NOT NULL,
    completed BOOLEAN DEFAULT false,
    created_at BIGINT DEFAULT (extract(epoch from now()) * 1000)::bigint,
    google_task_id TEXT,
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- 3. Tabel Bank Ide / Pool Items (Generate Ideas)
CREATE TABLE IF NOT EXISTS public.pool_items (
    id TEXT PRIMARY KEY,
    text TEXT NOT NULL,
    category TEXT DEFAULT 'Umum',
    created_at BIGINT DEFAULT (extract(epoch from now()) * 1000)::bigint,
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- 4. Tabel Pengaturan Pengguna (User Settings / Theme / Profile)
CREATE TABLE IF NOT EXISTS public.user_settings (
    id TEXT PRIMARY KEY DEFAULT 'default_user',
    username TEXT DEFAULT 'Username',
    theme TEXT DEFAULT 'basic',
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- ------------------------------------------------------------------------------
-- Keamanan & Row Level Security (RLS)
-- Mengizinkan akses baca & tulis menggunakan Publishable / Anon Key
-- ------------------------------------------------------------------------------
ALTER TABLE public.task_groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pool_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_settings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public access for task_groups" ON public.task_groups;
CREATE POLICY "Public access for task_groups" ON public.task_groups
    FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Public access for tasks" ON public.tasks;
CREATE POLICY "Public access for tasks" ON public.tasks
    FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Public access for pool_items" ON public.pool_items;
CREATE POLICY "Public access for pool_items" ON public.pool_items
    FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Public access for user_settings" ON public.user_settings;
CREATE POLICY "Public access for user_settings" ON public.user_settings
    FOR ALL USING (true) WITH CHECK (true);

-- ------------------------------------------------------------------------------
-- Aktifkan Supabase Realtime
-- Agar perubahan di HP Android langsung ter-update di Desktop Widget tanpa refresh
-- ------------------------------------------------------------------------------
ALTER PUBLICATION supabase_realtime ADD TABLE public.task_groups;
ALTER PUBLICATION supabase_realtime ADD TABLE public.tasks;
ALTER PUBLICATION supabase_realtime ADD TABLE public.pool_items;
ALTER PUBLICATION supabase_realtime ADD TABLE public.user_settings;

-- ------------------------------------------------------------------------------
-- Data Awal Contoh (Opsional, hanya dimasukkan jika tabel masih kosong)
-- ------------------------------------------------------------------------------
INSERT INTO public.task_groups (id, title, created_at)
VALUES ('group-today', 'Yang Harus Dikerjakan Hari ini!!', (extract(epoch from now()) * 1000)::bigint)
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.tasks (id, group_id, text, completed, created_at)
VALUES ('task-1', 'group-today', 'Cari tempat printing bagus di dekat rumah sa...', false, (extract(epoch from now()) * 1000)::bigint)
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.pool_items (id, text, category, created_at)
VALUES 
    ('pool-1', 'Tulis summary buat Lomba', 'Produktif', (extract(epoch from now()) * 1000)::bigint),
    ('pool-2', 'Main sama anabul di cafe Kemang', 'Anabul & Santai', (extract(epoch from now()) * 1000)::bigint),
    ('pool-3', 'Review materi kuliah / riset artikel', 'Belajar', (extract(epoch from now()) * 1000)::bigint),
    ('pool-4', 'Stretching & minum air putih 1 botol', 'Olahraga', (extract(epoch from now()) * 1000)::bigint)
ON CONFLICT (id) DO NOTHING;
