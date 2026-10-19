-- Up Migration
CREATE EXTENSION IF NOT EXISTS citext;

CREATE TABLE users (
  id uuid PRIMARY KEY,
  email citext UNIQUE,
  email_verified_at timestamptz,
  display_name text,
  locale text NOT NULL DEFAULT 'id' CHECK (locale IN ('id','en')),
  timezone text NOT NULL DEFAULT 'Asia/Jakarta',
  target_level smallint CHECK (target_level BETWEEN 1 AND 5),
  is_guest boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz
);

CREATE TABLE auth_identities (
  id uuid PRIMARY KEY,
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  provider text NOT NULL CHECK (provider IN ('google','apple','email')),
  provider_subject text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (provider, provider_subject)
);

CREATE TABLE devices (
  id uuid PRIMARY KEY,
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  platform text NOT NULL,
  app_version text,
  os_version text,
  push_token text,
  last_seen_at timestamptz
);

CREATE TABLE refresh_tokens (
  id uuid PRIMARY KEY,
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  device_id uuid NOT NULL,
  family_id uuid NOT NULL,
  token_hash bytea NOT NULL UNIQUE,
  expires_at timestamptz NOT NULL,
  revoked_at timestamptz,
  replaced_by uuid,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX ON refresh_tokens (user_id, family_id);

-- Konten (read-mostly)
CREATE TABLE content_items (
  id uuid PRIMARY KEY,
  external_key text NOT NULL UNIQUE,
  type text NOT NULL CHECK (type IN ('vocab','kanji','grammar','kana','sentence','passage','listening','test')),
  jlpt_level smallint NOT NULL CHECK (jlpt_level BETWEEN 0 AND 5),
  payload jsonb NOT NULL,
  content_version int NOT NULL,
  status text NOT NULL DEFAULT 'published' CHECK (status IN ('draft','published','retired')),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX ON content_items (jlpt_level, type);

CREATE TABLE lessons (
  id uuid PRIMARY KEY,
  jlpt_level smallint NOT NULL,
  unit_no int NOT NULL,
  lesson_no int NOT NULL,
  kind text NOT NULL,
  title jsonb NOT NULL,
  UNIQUE (jlpt_level, unit_no, lesson_no, kind)
);

CREATE TABLE lesson_items (
  lesson_id uuid NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
  item_id uuid NOT NULL REFERENCES content_items(id),
  position int NOT NULL,
  PRIMARY KEY (lesson_id, position)
);

CREATE TABLE content_packs (
  id uuid PRIMARY KEY,
  jlpt_level smallint NOT NULL,
  kind text NOT NULL CHECK (kind IN ('core','audio','strokes','passages','tests')),
  version int NOT NULL,
  sha256 text NOT NULL,
  size_bytes bigint NOT NULL,
  storage_key text NOT NULL,
  min_app_version text NOT NULL,
  is_premium boolean NOT NULL DEFAULT false,
  published_at timestamptz,
  UNIQUE (jlpt_level, kind, version)
);

-- Data pengguna
CREATE TABLE user_sync_state (
  user_id uuid PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  last_seq bigint NOT NULL DEFAULT 0
);

CREATE TABLE user_cards (
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  card_id uuid NOT NULL,
  item_external_key text NOT NULL,
  facet text NOT NULL,
  state smallint NOT NULL CHECK (state BETWEEN 0 AND 3),
  due timestamptz NOT NULL,
  stability real NOT NULL,
  difficulty real NOT NULL,
  elapsed_days int NOT NULL DEFAULT 0,
  scheduled_days int NOT NULL DEFAULT 0,
  reps int NOT NULL,
  lapses int NOT NULL,
  step smallint,
  last_review_at timestamptz,
  suspended boolean NOT NULL DEFAULT false,
  buried_until date,
  updated_at timestamptz NOT NULL,
  user_seq bigint NOT NULL,
  origin_device_id uuid NOT NULL,
  PRIMARY KEY (user_id, card_id)
);

CREATE INDEX ON user_cards (user_id, user_seq);

CREATE TABLE review_logs (
  user_id uuid NOT NULL,
  id uuid NOT NULL,
  card_id uuid NOT NULL,
  rating smallint NOT NULL CHECK (rating BETWEEN 1 AND 4),
  state_before smallint NOT NULL,
  reviewed_at timestamptz NOT NULL,
  duration_ms int,
  scheduled_days int,
  elapsed_days int,
  stability_before real,
  difficulty_before real,
  exercise_type text,
  device_id uuid NOT NULL,
  user_seq bigint NOT NULL,
  received_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, reviewed_at, id)
) PARTITION BY RANGE (reviewed_at);

CREATE TABLE review_logs_default PARTITION OF review_logs DEFAULT;

CREATE INDEX ON review_logs (user_id, user_seq);
CREATE INDEX ON review_logs (user_id, card_id, reviewed_at);

CREATE TABLE user_settings (
  user_id uuid PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  data jsonb NOT NULL,
  version int NOT NULL,
  updated_at timestamptz NOT NULL,
  user_seq bigint NOT NULL
);

CREATE TABLE lesson_progress (
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  lesson_key text NOT NULL,
  status text NOT NULL,
  best_score real,
  completed_at timestamptz,
  updated_at timestamptz NOT NULL,
  user_seq bigint NOT NULL,
  PRIMARY KEY (user_id, lesson_key)
);

CREATE TABLE test_attempts (
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  id uuid NOT NULL,
  test_key text NOT NULL,
  started_at timestamptz NOT NULL,
  finished_at timestamptz,
  score jsonb,
  user_seq bigint NOT NULL,
  PRIMARY KEY (user_id, id)
);

CREATE TABLE subscriptions (
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  platform text NOT NULL CHECK (platform IN ('apple','google')),
  product_id text NOT NULL,
  original_txn_id text NOT NULL,
  status text NOT NULL,
  expires_at timestamptz,
  last_verified_at timestamptz,
  PRIMARY KEY (platform, original_txn_id)
);

-- Down Migration
DROP TABLE IF EXISTS subscriptions CASCADE;
DROP TABLE IF EXISTS test_attempts CASCADE;
DROP TABLE IF EXISTS lesson_progress CASCADE;
DROP TABLE IF EXISTS user_settings CASCADE;
DROP TABLE IF EXISTS review_logs_default CASCADE;
DROP TABLE IF EXISTS review_logs CASCADE;
DROP TABLE IF EXISTS user_cards CASCADE;
DROP TABLE IF EXISTS user_sync_state CASCADE;
DROP TABLE IF EXISTS content_packs CASCADE;
DROP TABLE IF EXISTS lesson_items CASCADE;
DROP TABLE IF EXISTS lessons CASCADE;
DROP TABLE IF EXISTS content_items CASCADE;
DROP TABLE IF EXISTS refresh_tokens CASCADE;
DROP TABLE IF EXISTS devices CASCADE;
DROP TABLE IF EXISTS auth_identities CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP EXTENSION IF EXISTS citext CASCADE;
