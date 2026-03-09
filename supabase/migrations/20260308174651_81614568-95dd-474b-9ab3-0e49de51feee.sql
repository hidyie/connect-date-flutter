
-- Create notifications table
CREATE TABLE public.notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  type text NOT NULL, -- 'new_match', 'new_message'
  title text NOT NULL,
  body text NOT NULL,
  data jsonb DEFAULT '{}',
  read boolean NOT NULL DEFAULT false,
  created_at timestamp with time zone NOT NULL DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- RLS policies
CREATE POLICY "Users can view own notifications" ON public.notifications
  FOR SELECT TO authenticated USING (auth.uid() = user_id);

CREATE POLICY "Users can update own notifications" ON public.notifications
  FOR UPDATE TO authenticated USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own notifications" ON public.notifications
  FOR DELETE TO authenticated USING (auth.uid() = user_id);

-- System can insert (via trigger with security definer)
CREATE POLICY "System can insert notifications" ON public.notifications
  FOR INSERT TO authenticated WITH CHECK (true);

-- Enable realtime
ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;

-- Trigger function for new matches
CREATE OR REPLACE FUNCTION public.notify_new_match()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
  sender_name text;
BEGIN
  -- Only fire when status changes to 'matched'
  IF NEW.status = 'matched' AND (OLD IS NULL OR OLD.status != 'matched') THEN
    -- Get the name of the user who initiated
    SELECT display_name INTO sender_name FROM public.profiles WHERE user_id = NEW.user_id LIMIT 1;
    
    -- Notify both users
    INSERT INTO public.notifications (user_id, type, title, body, data)
    VALUES 
      (NEW.target_user_id, 'new_match', '새로운 매칭! 💕', sender_name || '님과 매칭되었습니다!', jsonb_build_object('match_id', NEW.id)),
      (NEW.user_id, 'new_match', '새로운 매칭! 💕', '매칭이 성사되었습니다!', jsonb_build_object('match_id', NEW.id));
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_match_status_change
  AFTER UPDATE ON public.matches
  FOR EACH ROW EXECUTE FUNCTION public.notify_new_match();

-- Trigger function for new messages
CREATE OR REPLACE FUNCTION public.notify_new_message()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
  sender_name text;
  recipient_id uuid;
  match_record record;
BEGIN
  -- Get sender name
  SELECT display_name INTO sender_name FROM public.profiles WHERE user_id = NEW.sender_id LIMIT 1;
  
  -- Get recipient from match
  SELECT * INTO match_record FROM public.matches WHERE id = NEW.match_id LIMIT 1;
  
  IF match_record.user_id = NEW.sender_id THEN
    recipient_id := match_record.target_user_id;
  ELSE
    recipient_id := match_record.user_id;
  END IF;
  
  -- Insert notification for recipient
  INSERT INTO public.notifications (user_id, type, title, body, data)
  VALUES (recipient_id, 'new_message', '새 메시지 💬', sender_name || ': ' || LEFT(NEW.content, 50), jsonb_build_object('match_id', NEW.match_id));
  
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_new_message
  AFTER INSERT ON public.messages
  FOR EACH ROW EXECUTE FUNCTION public.notify_new_message();
