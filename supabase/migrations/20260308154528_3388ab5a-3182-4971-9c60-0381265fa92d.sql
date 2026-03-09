
CREATE POLICY "Users can see blocks against them" ON public.blocks
  FOR SELECT TO authenticated
  USING (auth.uid() = blocked_id);
