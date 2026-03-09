
-- Profile prompts table
CREATE TABLE public.profile_prompts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  prompt_question text NOT NULL,
  prompt_answer text NOT NULL,
  display_order integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.profile_prompts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view all prompts" ON public.profile_prompts
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "Users can insert own prompts" ON public.profile_prompts
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own prompts" ON public.profile_prompts
  FOR UPDATE TO authenticated USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own prompts" ON public.profile_prompts
  FOR DELETE TO authenticated USING (auth.uid() = user_id);

-- Premium subscriptions table
CREATE TABLE public.premium_subscriptions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL UNIQUE,
  plan text NOT NULL DEFAULT 'free',
  unlimited_likes boolean NOT NULL DEFAULT false,
  unlimited_rewinds boolean NOT NULL DEFAULT false,
  see_who_likes_you boolean NOT NULL DEFAULT false,
  boost_count integer NOT NULL DEFAULT 0,
  super_like_count integer NOT NULL DEFAULT 3,
  created_at timestamptz NOT NULL DEFAULT now(),
  expires_at timestamptz
);

ALTER TABLE public.premium_subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own subscription" ON public.premium_subscriptions
  FOR SELECT TO authenticated USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own subscription" ON public.premium_subscriptions
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own subscription" ON public.premium_subscriptions
  FOR UPDATE TO authenticated USING (auth.uid() = user_id);

-- Boosts table
CREATE TABLE public.boosts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  expires_at timestamptz NOT NULL
);

ALTER TABLE public.boosts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own boosts" ON public.boosts
  FOR SELECT TO authenticated USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own boosts" ON public.boosts
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
