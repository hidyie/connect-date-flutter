
CREATE TABLE public.emergency_contacts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  contact_name text NOT NULL,
  contact_phone text NOT NULL,
  contact_email text,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.emergency_contacts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own emergency contacts - select" ON public.emergency_contacts FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own emergency contacts - insert" ON public.emergency_contacts FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can manage own emergency contacts - update" ON public.emergency_contacts FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own emergency contacts - delete" ON public.emergency_contacts FOR DELETE USING (auth.uid() = user_id);

CREATE TABLE public.safety_checkins (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  match_id uuid REFERENCES public.matches(id),
  partner_name text NOT NULL,
  meeting_location text,
  timer_minutes integer NOT NULL DEFAULT 60,
  started_at timestamptz NOT NULL DEFAULT now(),
  expires_at timestamptz NOT NULL,
  checked_in boolean NOT NULL DEFAULT false,
  checked_in_at timestamptz,
  alert_sent boolean NOT NULL DEFAULT false
);

ALTER TABLE public.safety_checkins ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own checkins - select" ON public.safety_checkins FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own checkins - insert" ON public.safety_checkins FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can manage own checkins - update" ON public.safety_checkins FOR UPDATE USING (auth.uid() = user_id);
