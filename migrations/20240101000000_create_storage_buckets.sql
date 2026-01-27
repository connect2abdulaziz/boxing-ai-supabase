-- Create storage buckets for Boxing AI MVP
-- Run this migration: supabase migration up

-- Create 'videos' bucket (private - for storing uploaded videos)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'videos',
  'videos',
  false,
  104857600, -- 100MB limit
  ARRAY['video/mp4', 'video/mpeg', 'video/quicktime', 'video/x-msvideo', 'video/webm']
)
ON CONFLICT (id) DO NOTHING;

-- Create 'results' bucket (public - for storing analysis results that frontend polls)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'results',
  'results',
  true,
  1048576, -- 1MB limit (JSON files are small)
  ARRAY['application/json']
)
ON CONFLICT (id) DO NOTHING;

-- Set up storage policies for 'videos' bucket
-- Allow service role to upload/download
CREATE POLICY "Service role can upload videos"
ON storage.objects FOR INSERT
TO service_role
WITH CHECK (bucket_id = 'videos');

CREATE POLICY "Service role can read videos"
ON storage.objects FOR SELECT
TO service_role
USING (bucket_id = 'videos');

CREATE POLICY "Service role can delete videos"
ON storage.objects FOR DELETE
TO service_role
USING (bucket_id = 'videos');

-- Set up storage policies for 'results' bucket
-- Allow service role to upload
CREATE POLICY "Service role can upload results"
ON storage.objects FOR INSERT
TO service_role
WITH CHECK (bucket_id = 'results');

-- Allow public read (for frontend polling)
CREATE POLICY "Public can read results"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'results');
