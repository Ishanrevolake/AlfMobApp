-- Apply after the existing AlphaWebApp schema and trainer-role migration.
BEGIN;
CREATE TABLE IF NOT EXISTS public.client_daily_logs (
  client_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  log_date date NOT NULL,
  kind text NOT NULL CHECK (kind IN ('meal','exercise')),
  item_id text NOT NULL,
  payload jsonb NOT NULL DEFAULT '{}'::jsonb,
  updated_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY(client_id, log_date, kind, item_id)
);
ALTER TABLE public.client_daily_logs ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Daily logs owner read" ON public.client_daily_logs;
CREATE POLICY "Daily logs owner read" ON public.client_daily_logs FOR SELECT TO authenticated USING (client_id = auth.uid() OR public.is_staff());
DROP POLICY IF EXISTS "Daily logs owner insert" ON public.client_daily_logs;
CREATE POLICY "Daily logs owner insert" ON public.client_daily_logs FOR INSERT TO authenticated WITH CHECK (client_id = auth.uid());
DROP POLICY IF EXISTS "Daily logs owner update" ON public.client_daily_logs;
CREATE POLICY "Daily logs owner update" ON public.client_daily_logs FOR UPDATE TO authenticated USING (client_id = auth.uid()) WITH CHECK (client_id = auth.uid());
GRANT SELECT, INSERT, UPDATE ON public.client_daily_logs TO authenticated;
INSERT INTO storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
VALUES ('message-attachments','message-attachments',false,52428800,ARRAY['image/jpeg','image/png','image/webp','video/mp4','video/quicktime','audio/mpeg','audio/mp4','audio/wav','audio/ogg'])
ON CONFLICT(id) DO NOTHING;
DROP POLICY IF EXISTS "Message attachment upload" ON storage.objects;
CREATE POLICY "Message attachment upload" ON storage.objects FOR INSERT TO authenticated WITH CHECK (
 bucket_id = 'message-attachments' AND (storage.foldername(name))[1] = auth.uid()::text
 AND EXISTS (SELECT 1 FROM public.ask_alpha_threads t WHERE t.id::text = (storage.foldername(name))[2] AND (t.user_id = auth.uid() OR public.is_staff()))
);
DROP POLICY IF EXISTS "Message attachment read" ON storage.objects;
CREATE POLICY "Message attachment read" ON storage.objects FOR SELECT TO authenticated USING (
 bucket_id = 'message-attachments' AND EXISTS (SELECT 1 FROM public.ask_alpha_threads t WHERE t.id::text = (storage.foldername(name))[2] AND (t.user_id = auth.uid() OR public.is_staff()))
);
COMMIT;
