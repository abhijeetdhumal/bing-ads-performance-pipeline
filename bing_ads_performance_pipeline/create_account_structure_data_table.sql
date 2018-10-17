DROP TABLE IF EXISTS ba_data.account_structure;

CREATE TABLE ba_data.account_structure (
  ad_id         BIGINT NOT NULL,
  ad_name       VARCHAR,
  ad_group_id   BIGINT NOT NULL,
  ad_group_name TEXT   NOT NULL,
  campaign_id   BIGINT NOT NULL,
  campaign_name TEXT   NOT NULL,
  account_id    BIGINT NOT NULL,
  account_name  TEXT   NOT NULL,
  attributes    JSONB  NOT NULL
);
