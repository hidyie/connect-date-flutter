
-- Music preferences table
CREATE TABLE public.music_preferences (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL UNIQUE,
  spotify_connected boolean NOT NULL DEFAULT false,
  top_artists text[] DEFAULT '{}',
  top_tracks text[] DEFAULT '{}',
  favorite_genres text[] DEFAULT '{}',
  spotify_display_name text,
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.music_preferences ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view all music prefs" ON public.music_preferences
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "Users can insert own music prefs" ON public.music_preferences
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own music prefs" ON public.music_preferences
  FOR UPDATE TO authenticated USING (auth.uid() = user_id);

-- Photo verification table
CREATE TABLE public.photo_verifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL UNIQUE,
  selfie_url text NOT NULL,
  status text NOT NULL DEFAULT 'pending',
  verified_at timestamptz,
  ai_confidence numeric,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.photo_verifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own verification" ON public.photo_verifications
  FOR SELECT TO authenticated USING (auth.uid() = user_id);

CREATE POLICY "Users can view others verified status" ON public.photo_verifications
  FOR SELECT TO authenticated USING (status = 'verified');

CREATE POLICY "Users can insert own verification" ON public.photo_verifications
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own verification" ON public.photo_verifications
  FOR UPDATE TO authenticated USING (auth.uid() = user_id);
