-- Create analysis_jobs table to track video analysis jobs
CREATE TABLE IF NOT EXISTS analysis_jobs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  job_id TEXT UNIQUE NOT NULL,
  video_path TEXT NOT NULL,
  mode TEXT NOT NULL CHECK (mode IN ('bag', 'pads', 'sparring')),
  strategy TEXT NOT NULL DEFAULT 'interval-8' CHECK (strategy IN ('interval-8', 'interval-9', 'smart')),
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed')),
  
  -- Results (stored as JSONB)
  result JSONB,
  frames_count INTEGER,
  error_message TEXT,
  
  -- Timestamps
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  
  -- Indexes for faster queries
  CONSTRAINT valid_status CHECK (status IN ('pending', 'processing', 'completed', 'failed'))
);

-- Create indexes for faster lookups
CREATE INDEX IF NOT EXISTS idx_analysis_jobs_job_id ON analysis_jobs(job_id);
CREATE INDEX IF NOT EXISTS idx_analysis_jobs_status ON analysis_jobs(status);
CREATE INDEX IF NOT EXISTS idx_analysis_jobs_created_at ON analysis_jobs(created_at DESC);

-- Enable Row Level Security (RLS)
ALTER TABLE analysis_jobs ENABLE ROW LEVEL SECURITY;

-- Policy: Allow service role full access
CREATE POLICY "Service role can manage all jobs"
ON analysis_jobs
FOR ALL
TO service_role
USING (true)
WITH CHECK (true);

-- Policy: Allow authenticated users to read their own jobs (if you add user_id later)
-- For now, allow public read (you can restrict this later)
CREATE POLICY "Public can read completed jobs"
ON analysis_jobs
FOR SELECT
TO public
USING (status = 'completed');

-- Policy: Allow anon to read by job_id (for polling)
CREATE POLICY "Anon can read jobs by job_id"
ON analysis_jobs
FOR SELECT
TO anon
USING (true);
