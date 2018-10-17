DROP TABLE IF EXISTS ba_data.ad_performance CASCADE;

CREATE TABLE ba_data.ad_performance (

  date                DATE             NOT NULL,
  device_type         TEXT             NOT NULL,

  account_id          BIGINT           NOT NULL,
  account_name        TEXT             NOT NULL,
  account_number      TEXT             NOT NULL,
  account_status      TEXT             NOT NULL,

  campaign_id         BIGINT           NOT NULL,
  campaign_name       TEXT             NOT NULL,
  campaign_status     TEXT             NOT NULL,

  ad_group_id         BIGINT           NOT NULL,
  ad_group_name       TEXT             NOT NULL,
  ad_group_status     TEXT             NOT NULL,

  ad_id               BIGINT           NOT NULL,
  ad_title            TEXT,
  ad_description      TEXT,
  ad_type             TEXT             NOT NULL,
  ad_labels           TEXT,

  impressions         INTEGER          NOT NULL,
  clicks              INTEGER          NOT NULL,
  ctr                 TEXT,
  spend               DOUBLE PRECISION NOT NULL,
  average_position    DOUBLE PRECISION,
  conversions         INTEGER          NOT NULL,
  conversion_rate     TEXT,
  cost_per_conversion DOUBLE PRECISION,
  revenue             TEXT
);

-- needed for upserting
SELECT util.add_index('ba_data', 'ad_performance', column_names := ARRAY ['date']);

-- create an exact copy of the data table. New data will be copied here
DROP TABLE IF EXISTS ba_data.ad_performance_upsert;

CREATE TABLE ba_data.ad_performance_upsert AS
  SELECT *
  FROM ba_data.ad_performance
  LIMIT 0;


CREATE OR REPLACE FUNCTION ba_data.upsert_ad_performance()
  RETURNS VOID AS '

-- rather than doing a proper upsert, first data for the dates and ad_ids in the upsert table
DELETE FROM ba_data.ad_performance
USING ba_data.ad_performance_upsert
WHERE ad_performance_upsert.date = ad_performance.date
      AND ad_performance_upsert.ad_id = ad_performance.ad_id;

-- copy new data in
INSERT INTO ba_data.ad_performance
  SELECT *
  FROM ba_data.ad_performance_upsert;

-- remove tmp data
TRUNCATE ba_data.ad_performance_upsert;

'
LANGUAGE SQL;
