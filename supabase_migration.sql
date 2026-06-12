-- ====================================================================
-- NULISIN — Supabase SQL Migration Script
-- Jalankan di: Supabase Dashboard → SQL Editor → New Query → Run
-- ====================================================================

-- ─── EXTENSIONS ─────────────────────────────────────────────────────
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ─── TABEL PROFILES ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.profiles (
  id           UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name    TEXT NOT NULL DEFAULT '',
  avatar_url   TEXT,
  profession   TEXT,
  interests    TEXT,
  bio          TEXT,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── TABEL CATEGORIES ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.categories (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name             TEXT NOT NULL UNIQUE,
  description      TEXT,
  cover_image_url  TEXT,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── TABEL ARTICLES ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.articles (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  author_id        UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  title            TEXT NOT NULL,
  content          TEXT NOT NULL DEFAULT '',
  cover_image_url  TEXT,
  is_published     BOOLEAN NOT NULL DEFAULT TRUE,
  published_at     TIMESTAMPTZ,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── TABEL ARTICLE_CATEGORIES (many-to-many) ─────────────────────────
CREATE TABLE IF NOT EXISTS public.article_categories (
  article_id   UUID NOT NULL REFERENCES public.articles(id) ON DELETE CASCADE,
  category_id  UUID NOT NULL REFERENCES public.categories(id) ON DELETE CASCADE,
  PRIMARY KEY (article_id, category_id)
);

-- ─── TABEL COMMENTS ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.comments (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  article_id  UUID NOT NULL REFERENCES public.articles(id) ON DELETE CASCADE,
  user_id     UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  content     TEXT NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── FUNCTIONS & TRIGGERS ────────────────────────────────────────────

-- Auto-update 'updated_at' timestamp
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE OR REPLACE TRIGGER articles_updated_at
  BEFORE UPDATE ON public.articles
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE OR REPLACE TRIGGER comments_updated_at
  BEFORE UPDATE ON public.comments
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- Auto-set 'published_at' when article is published
CREATE OR REPLACE FUNCTION public.handle_article_publish()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.is_published = TRUE AND OLD.is_published = FALSE THEN
    NEW.published_at = NOW();
  ELSIF NEW.is_published = TRUE AND NEW.published_at IS NULL THEN
    NEW.published_at = NOW();
  END IF;
  RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER articles_publish_at
  BEFORE INSERT OR UPDATE ON public.articles
  FOR EACH ROW EXECUTE FUNCTION public.handle_article_publish();

-- Auto-create profile when user registers
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1))
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ─── ROW LEVEL SECURITY (RLS) ────────────────────────────────────────

-- Profiles: semua orang bisa lihat, hanya pemilik yang bisa edit
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public profiles are viewable by everyone." ON public.profiles;
DROP POLICY IF EXISTS "Users can insert their own profile." ON public.profiles;
DROP POLICY IF EXISTS "Users can update their own profile." ON public.profiles;

CREATE POLICY "Public profiles are viewable by everyone."
  ON public.profiles FOR SELECT USING (TRUE);

CREATE POLICY "Users can insert their own profile."
  ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update their own profile."
  ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- Articles: semua orang bisa lihat yang published, pemilik CRUD
ALTER TABLE public.articles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Published articles viewable by everyone." ON public.articles;
DROP POLICY IF EXISTS "Authors can CRUD their own articles." ON public.articles;

CREATE POLICY "Published articles viewable by everyone."
  ON public.articles FOR SELECT
  USING (is_published = TRUE OR auth.uid() = author_id);

CREATE POLICY "Authors can insert their own articles."
  ON public.articles FOR INSERT
  WITH CHECK (auth.uid() = author_id);

CREATE POLICY "Authors can update their own articles."
  ON public.articles FOR UPDATE
  USING (auth.uid() = author_id);

CREATE POLICY "Authors can delete their own articles."
  ON public.articles FOR DELETE
  USING (auth.uid() = author_id);

-- Categories: semua bisa lihat, tidak ada write lewat client
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Categories viewable by everyone." ON public.categories;

CREATE POLICY "Categories viewable by everyone."
  ON public.categories FOR SELECT USING (TRUE);

CREATE POLICY "Authenticated users can create categories."
  ON public.categories FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- Article Categories: semua bisa lihat, pemilik artikel bisa manage
ALTER TABLE public.article_categories ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Article categories viewable by everyone." ON public.article_categories;
DROP POLICY IF EXISTS "Authors can manage article categories." ON public.article_categories;

CREATE POLICY "Article categories viewable by everyone."
  ON public.article_categories FOR SELECT USING (TRUE);

CREATE POLICY "Authors can manage article categories."
  ON public.article_categories FOR ALL
  USING (
    auth.uid() = (SELECT author_id FROM public.articles WHERE id = article_id)
  );

-- Comments: semua bisa lihat, hanya user login yang bisa create, pemilik delete
ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Comments are viewable by everyone." ON public.comments;
DROP POLICY IF EXISTS "Authenticated users can create comments." ON public.comments;
DROP POLICY IF EXISTS "Users can delete their own comments." ON public.comments;

CREATE POLICY "Comments are viewable by everyone."
  ON public.comments FOR SELECT USING (TRUE);

CREATE POLICY "Authenticated users can create comments."
  ON public.comments FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own comments."
  ON public.comments FOR DELETE
  USING (auth.uid() = user_id);

-- ─── STORAGE BUCKETS ─────────────────────────────────────────────────

INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO NOTHING;

INSERT INTO storage.buckets (id, name, public)
VALUES ('article-covers', 'article-covers', true)
ON CONFLICT (id) DO NOTHING;

-- Storage policies — avatars
DROP POLICY IF EXISTS "Avatar images are publicly accessible." ON storage.objects;
DROP POLICY IF EXISTS "Users can upload their own avatar." ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own avatar." ON storage.objects;

CREATE POLICY "Avatar images are publicly accessible."
  ON storage.objects FOR SELECT
  USING (bucket_id = 'avatars');

CREATE POLICY "Users can upload their own avatar."
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'avatars' AND auth.uid() IS NOT NULL);

CREATE POLICY "Users can update their own avatar."
  ON storage.objects FOR UPDATE
  USING (bucket_id = 'avatars' AND auth.uid() IS NOT NULL);

-- Storage policies — article covers
DROP POLICY IF EXISTS "Article covers are publicly accessible." ON storage.objects;
DROP POLICY IF EXISTS "Authors can upload article covers." ON storage.objects;

CREATE POLICY "Article covers are publicly accessible."
  ON storage.objects FOR SELECT
  USING (bucket_id = 'article-covers');

CREATE POLICY "Authors can upload article covers."
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'article-covers' AND auth.uid() IS NOT NULL);

-- ─── SEED DATA (Kategori Default) ────────────────────────────────────

INSERT INTO public.categories (name, description) VALUES
  ('Filsafat',  'Pemikiran, etika, dan metafisika'),
  ('Teknologi', 'Inovasi, AI, dan dunia digital'),
  ('Sastra',    'Puisi, prosa, dan analisis karya'),
  ('Esai',      'Tulisan opini dan refleksi personal'),
  ('Sains',     'Penemuan ilmiah dan riset terbaru'),
  ('Budaya',    'Seni, tradisi, dan masyarakat'),
  ('Sejarah',   'Peristiwa dan tokoh bersejarah'),
  ('Kesehatan', 'Kesehatan fisik, mental, dan gaya hidup')
ON CONFLICT (name) DO NOTHING;

-- ─── SELESAI ─────────────────────────────────────────────────────────
-- Semua tabel, RLS, trigger, dan storage sudah siap.
-- Lanjutkan ke file SETUP_BACKEND.md untuk langkah selanjutnya.
