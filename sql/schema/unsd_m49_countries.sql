-- UNSD M49 Countries Reference Table
-- Source: United Nations Statistics Division (UNSD) - M49 Standard
-- Contains countries, territories, and their regional classifications
DROP TABLE IF EXISTS countries CASCADE;
CREATE TABLE countries (
    -- Primary identifier: M49 numeric code
    m49_code INTEGER PRIMARY KEY,
    -- ISO codes (international standards)
    iso_alpha2 CHAR(2) NOT NULL UNIQUE,
    iso_alpha3 CHAR(3) NOT NULL UNIQUE,
    -- Country/territory name
    country_or_area VARCHAR(100) NOT NULL,
    -- Global classification
    global_code INTEGER NOT NULL,
    global_name VARCHAR(50) NOT NULL,
    -- Regional hierarchy
    region_code INTEGER,
    region_name VARCHAR(50),
    sub_region_code INTEGER,
    sub_region_name VARCHAR(50),
    intermediate_region_code INTEGER,
    intermediate_region_name VARCHAR(50),
    -- Classification flags
    is_ldc BOOLEAN NOT NULL DEFAULT FALSE,
    -- Least Developed Countries
    is_lldc BOOLEAN NOT NULL DEFAULT FALSE,
    -- Land Locked Developing Countries
    is_sids BOOLEAN NOT NULL DEFAULT FALSE,
    -- Small Island Developing States
    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- Indexes for common queries
CREATE INDEX idx_unsd_countries_name ON countries(country_or_area);
CREATE INDEX idx_unsd_countries_region ON countries(region_code);
CREATE INDEX idx_unsd_countries_subregion ON countries(sub_region_code);
CREATE INDEX idx_unsd_countries_ldc ON countries(is_ldc)
WHERE is_ldc = TRUE;
CREATE INDEX idx_unsd_countries_lldc ON countries(is_lldc)
WHERE is_lldc = TRUE;
CREATE INDEX idx_unsd_countries_sids ON countries(is_sids)
WHERE is_sids = TRUE;
-- Comments for documentation
COMMENT ON TABLE countries IS 'UNSD M49 standard country classification with regional groupings and development status';
COMMENT ON COLUMN countries.m49_code IS 'UN M49 numeric country code (primary key)';
COMMENT ON COLUMN countries.iso_alpha2 IS 'ISO 3166-1 alpha-2 code (2 characters)';
COMMENT ON COLUMN countries.iso_alpha3 IS 'ISO 3166-1 alpha-3 code (3 characters)';
COMMENT ON COLUMN countries.country_or_area IS 'Official country or territory name';
COMMENT ON COLUMN countries.is_ldc IS 'Least Developed Countries designation';
COMMENT ON COLUMN countries.is_lldc IS 'Land Locked Developing Countries designation';
COMMENT ON COLUMN countries.is_sids IS 'Small Island Developing States designation';