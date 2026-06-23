-- ══════════════════════════════════════════════════════════════════════════
--  ÉMPOR WATCHES — Imágenes del sitio
--  Corre esto en Supabase → SQL Editor → New Query → Run
-- ══════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.site_images (
  key        TEXT        PRIMARY KEY,
  image_url  TEXT        NOT NULL DEFAULT '',
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.site_images ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read site_images" ON public.site_images
  FOR SELECT USING (true);

CREATE POLICY "Admin manage site_images" ON public.site_images
  FOR ALL
  USING      (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

-- Imágenes por defecto (las actuales del sitio)
INSERT INTO public.site_images (key, image_url) VALUES
  ('hero',    'https://images.unsplash.com/photo-1523170335258-f5ed11844a49?auto=format&fit=crop&w=1920&q=80'),
  ('consign', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=700&q=80'),
  ('about',   'https://images.unsplash.com/photo-1606041011872-596597976b25?auto=format&fit=crop&w=700&q=80')
ON CONFLICT (key) DO NOTHING;
