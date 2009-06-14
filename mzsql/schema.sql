DROP TABLE IF EXISTS parameters;
CREATE TABLE parameters (
  id  INTEGER NOT NULL PRIMARY KEY,
  name  VARCHAR(64) NOT NULL DEFAULT '',
  value TEXT NOT NULL DEFAULT ''
);
CREATE INDEX param_idx ON parameters (name);

CREATE TABLE ms1 (
  id                  INTEGER NOT NULL PRIMARY KEY,
  peak_count          INTEGER NOT NULL DEFAULT 0,
  filter_line         VARCHAR(255) NOT NULL DEFAULT '',
  retention_time      FLOAT NOT NULL DEFAULT 0.0,
  low_mz              FLOAT NOT NULL DEFAULT 0.0,
  high_mz             FLOAT NOT NULL DEFAULT 0.0,
  base_peak_mz        FLOAT NOT NULL DEFAULT 0.0,
  base_peak_intensity FLOAT NOT NULL DEFAULT 0.0,
  total_ion_current   FLOAT NOT NULL DEFAULT 0.0,
  encoded_mz          TEXT NOT NULL DEFAULT '',
  encoded_intensity   TEXT NOT NULL DEFAULT ''
);

CREATE TABLE ms2 (
  id                  INTEGER NOT NULL PRIMARY KEY,
  peak_count          INTEGER NOT NULL DEFAULT 0,
  filter_line         VARCHAR(255) NOT NULL DEFAULT '',
  retention_time      FLOAT NOT NULL DEFAULT 0.0,
  low_mz              FLOAT NOT NULL DEFAULT 0.0,
  high_mz             FLOAT NOT NULL DEFAULT 0.0,
  base_peak_mz        FLOAT NOT NULL DEFAULT 0.0,
  base_peak_intensity FLOAT NOT NULL DEFAULT 0.0,
  total_ion_current   FLOAT NOT NULL DEFAULT 0.0,
  collision_energy    FLOAT NOT NULL DEFAULT 0.0,
  precursor_intensity FLOAT NOT NULL DEFAULT 0.0,
  precursor_charge    INTEGER NOT NULL DEFAULT 0,
  precursor_mz        FLOAT NOT NULL DEFAULT 0.0,
  peak_mz_list        TEXT NOT NULL DEFAULT '',
  peak_intensity_list TEXT NOT NULL DEFAULT ''
);
