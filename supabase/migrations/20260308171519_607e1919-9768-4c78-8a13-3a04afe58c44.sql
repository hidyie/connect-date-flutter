CREATE POLICY "Users can update read status on messages in their matches"
ON public.messages
FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM matches
    WHERE matches.id = messages.match_id
    AND (matches.user_id = auth.uid() OR matches.target_user_id = auth.uid())
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM matches
    WHERE matches.id = messages.match_id
    AND (matches.user_id = auth.uid() OR matches.target_user_id = auth.uid())
  )
);