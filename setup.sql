-- ══════════════════════════════════════════════════════════════════════════
--  ÉMPOR WATCHES — Supabase Setup SQL
--  Corre este script completo en:
--  Supabase → SQL Editor → New Query → pegar todo → Run
-- ══════════════════════════════════════════════════════════════════════════

-- ── Extensión para UUIDs ──────────────────────────────────────────────────
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ── Tabla: watches ────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.watches (
  id          UUID          DEFAULT uuid_generate_v4() PRIMARY KEY,
  brand       TEXT          NOT NULL,
  model       TEXT          NOT NULL,
  reference   TEXT          DEFAULT '',
  condition   TEXT          DEFAULT 'Excellent',
  price       NUMERIC(12,2),
  currency    TEXT          DEFAULT 'USD',
  year        INTEGER,
  description TEXT          DEFAULT '',
  image_url   TEXT          DEFAULT '',
  status      TEXT          DEFAULT 'available',  -- available | sold | reserved
  featured    BOOLEAN       DEFAULT false,
  created_at  TIMESTAMPTZ   DEFAULT NOW()
);

-- ── Tabla: brands ─────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.brands (
  id          UUID          DEFAULT uuid_generate_v4() PRIMARY KEY,
  name        TEXT          NOT NULL UNIQUE,
  active      BOOLEAN       DEFAULT true,
  sort_order  INTEGER       DEFAULT 0,
  created_at  TIMESTAMPTZ   DEFAULT NOW()
);

-- ── Row Level Security ────────────────────────────────────────────────────
ALTER TABLE public.watches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.brands  ENABLE ROW LEVEL SECURITY;

-- El público puede leer relojes y marcas
CREATE POLICY "Public read watches" ON public.watches
  FOR SELECT USING (true);

CREATE POLICY "Public read brands" ON public.brands
  FOR SELECT USING (true);

-- El admin (usuario autenticado) puede hacer todo
CREATE POLICY "Admin manage watches" ON public.watches
  FOR ALL
  USING      (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Admin manage brands" ON public.brands
  FOR ALL
  USING      (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

-- ── Marcas por defecto ────────────────────────────────────────────────────
INSERT INTO public.brands (name, sort_order) VALUES
  ('Rolex',             1),
  ('Patek Philippe',    2),
  ('Audemars Piguet',   3),
  ('Cartier',           4),
  ('Omega',             5),
  ('IWC',               6),
  ('Hublot',            7)
ON CONFLICT (name) DO NOTHING;

-- ══════════════════════════════════════════════════════════════════════════
--  STORAGE: crea el bucket manualmente en Supabase → Storage → New bucket
--  Nombre del bucket:  watch-images
--  Public bucket:      ✅ Activado (para que las URLs de fotos sean públicas)
-- ══════════════════════════════════════════════════════════════════════════

-- Política de storage: admin puede subir/borrar imágenes
INSERT INTO storage.buckets (id, name, public)
VALUES ('watch-images', 'watch-images', true)
ON CONFLICT (id) DO NOTHING;

CREATE POLICY "Admin upload images" ON storage.objects
  FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'watch-images');

CREATE POLICY "Admin delete images" ON storage.objects
  FOR DELETE
  TO authenticated
  USING (bucket_id = 'watch-images');

CREATE POLICY "Public read images" ON storage.objects
  FOR SELECT
  TO public
  USING (bucket_id = 'watch-images');
