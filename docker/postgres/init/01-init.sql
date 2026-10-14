-- NihonPath Local Dev - PostgreSQL Initialization
-- §4.2: PostgreSQL 16+ dengan ekstensi citext

CREATE EXTENSION IF NOT EXISTS citext;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Verifikasi skema awal & health check table
CREATE TABLE IF NOT EXISTS _system_health (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  service_name citext NOT NULL UNIQUE,
  status VARCHAR(50) NOT NULL,
  initialized_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

INSERT INTO _system_health (service_name, status)
VALUES ('nihonpath-db', 'healthy')
ON CONFLICT (service_name) DO UPDATE SET initialized_at = NOW();
