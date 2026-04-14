-- ============================================================================
-- IT CLUB — Supabase Schema Setup (IDEMPOTENT — safe to run multiple times)
-- Run this in Supabase Dashboard → SQL Editor → New Query → Run
-- ============================================================================

-- ── Tables ──────────────────────────────────────────────────────────────────

-- Users table (mirrors Supabase auth.users with app-specific fields)
CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  college VARCHAR(255) NOT NULL DEFAULT '',
  department VARCHAR(255) NOT NULL DEFAULT '',
  role VARCHAR(20) NOT NULL DEFAULT 'student',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Clubs table
CREATE TABLE IF NOT EXISTS public.clubs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  description TEXT NOT NULL DEFAULT '',
  logo_base64 TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Events table
CREATE TABLE IF NOT EXISTS public.events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title VARCHAR(255) NOT NULL,
  description TEXT NOT NULL DEFAULT '',
  club_id UUID REFERENCES public.clubs(id) ON DELETE SET NULL,
  club_name VARCHAR(255) NOT NULL DEFAULT '',
  venue VARCHAR(255) NOT NULL DEFAULT '',
  start_date_time TIMESTAMPTZ NOT NULL,
  end_date_time TIMESTAMPTZ NOT NULL,
  registration_deadline TIMESTAMPTZ NOT NULL,
  max_participants INTEGER NOT NULL DEFAULT 0,
  banner_url TEXT,
  tag VARCHAR(50) NOT NULL DEFAULT 'General',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Registrations table
CREATE TABLE IF NOT EXISTS public.registrations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID NOT NULL REFERENCES public.events(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  registered_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(event_id, user_id)
);

-- ── Indexes ─────────────────────────────────────────────────────────────────

CREATE INDEX IF NOT EXISTS idx_events_club_id ON public.events(club_id);
CREATE INDEX IF NOT EXISTS idx_events_start ON public.events(start_date_time);
CREATE INDEX IF NOT EXISTS idx_registrations_event ON public.registrations(event_id);
CREATE INDEX IF NOT EXISTS idx_registrations_user ON public.registrations(user_id);
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);

-- ── Enable RLS ──────────────────────────────────────────────────────────────

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.clubs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.registrations ENABLE ROW LEVEL SECURITY;

-- ── RLS Policies: users ─────────────────────────────────────────────────────

DROP POLICY IF EXISTS "Anyone can read users" ON public.users;
CREATE POLICY "Anyone can read users" ON public.users FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can insert own profile" ON public.users;
CREATE POLICY "Users can insert own profile" ON public.users FOR INSERT WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "Authenticated can insert profile" ON public.users;
CREATE POLICY "Authenticated can insert profile" ON public.users FOR INSERT WITH CHECK (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Users can update own profile" ON public.users;
CREATE POLICY "Users can update own profile" ON public.users FOR UPDATE USING (auth.uid() = id);

-- ── RLS Policies: clubs ─────────────────────────────────────────────────────

DROP POLICY IF EXISTS "Anyone can read clubs" ON public.clubs;
CREATE POLICY "Anyone can read clubs" ON public.clubs FOR SELECT USING (true);

DROP POLICY IF EXISTS "Authenticated can insert clubs" ON public.clubs;
CREATE POLICY "Authenticated can insert clubs" ON public.clubs FOR INSERT WITH CHECK (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Authenticated can update clubs" ON public.clubs;
CREATE POLICY "Authenticated can update clubs" ON public.clubs FOR UPDATE USING (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Authenticated can delete clubs" ON public.clubs;
CREATE POLICY "Authenticated can delete clubs" ON public.clubs FOR DELETE USING (auth.role() = 'authenticated');

-- ── RLS Policies: events ────────────────────────────────────────────────────

DROP POLICY IF EXISTS "Anyone can read events" ON public.events;
CREATE POLICY "Anyone can read events" ON public.events FOR SELECT USING (true);

DROP POLICY IF EXISTS "Authenticated can insert events" ON public.events;
CREATE POLICY "Authenticated can insert events" ON public.events FOR INSERT WITH CHECK (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Authenticated can update events" ON public.events;
CREATE POLICY "Authenticated can update events" ON public.events FOR UPDATE USING (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Authenticated can delete events" ON public.events;
CREATE POLICY "Authenticated can delete events" ON public.events FOR DELETE USING (auth.role() = 'authenticated');

-- ── RLS Policies: registrations ─────────────────────────────────────────────

DROP POLICY IF EXISTS "Anyone can read registrations" ON public.registrations;
CREATE POLICY "Anyone can read registrations" ON public.registrations FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can register themselves" ON public.registrations;
CREATE POLICY "Users can register themselves" ON public.registrations FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can unregister themselves" ON public.registrations;
CREATE POLICY "Users can unregister themselves" ON public.registrations FOR DELETE USING (auth.uid() = user_id);
