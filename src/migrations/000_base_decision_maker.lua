return {
  postgres = {
    up = [[
      CREATE TABLE IF NOT EXISTS "decision_makers" (
        "id"           UUID                         PRIMARY KEY,
        "name"         TEXT                         UNIQUE,
        "created_at"   TIMESTAMP WITHOUT TIME ZONE  DEFAULT (CURRENT_TIMESTAMP(0) AT TIME ZONE 'UTC'),
        "scheme"       TEXT,
        "host"         TEXT,
        "port"         INTEGER,
        "path"         TEXT
      );

      DO $$
      BEGIN
        CREATE INDEX IF NOT EXISTS "decision_makers_host_idx" ON "decision_makers" ("host");
      EXCEPTION WHEN UNDEFINED_COLUMN THEN
        -- Do nothing, accept existing state
      END$$;
    ]],
  },

  cassandra = {
    up = [[
      CREATE TABLE IF NOT EXISTS decision_makers(
        id          uuid PRIMARY KEY,
        name        text,
        created_at  timestamp,
        scheme      text,
        host        text,
        port        bigint,
        path        text
      );
      CREATE INDEX IF NOT EXISTS ON decision_makers(name);
      CREATE INDEX IF NOT EXISTS ON decision_makers(host);
    ]],
  }
}