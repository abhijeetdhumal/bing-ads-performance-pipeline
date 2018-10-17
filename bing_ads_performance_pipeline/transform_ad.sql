DROP TABLE IF EXISTS ba_dim_next.ad;

CREATE TABLE ba_dim_next.ad (
  ad_id         BIGINT NOT NULL,
  ad_name       TEXT   NOT NULL,
  ad_group_id   BIGINT NOT NULL,
  ad_group_name TEXT   NOT NULL,
  campaign_id   BIGINT NOT NULL,
  campaign_name TEXT   NOT NULL,
  account_id    BIGINT NOT NULL,
  account_name  TEXT   NOT NULL,
  attributes    JSONB  NOT NULL
);

INSERT INTO ba_dim_next.ad
  SELECT DISTINCT
    ad.ad_id                          AS ad_id,
    COALESCE(ad.ad_name, '(not set)') AS ad_name,
    ad.ad_group_id                    AS ad_group_id,
    ad.ad_group_name                  AS ad_group_name,
    ad.campaign_id                    AS campaign_id,
    ad.campaign_name                  AS campaign_name,
    ad.account_id                     AS account_id,
    ad.account_name                   AS account_name,
    ad.attributes                     AS attributes

  FROM ba_tmp.ad;


SELECT util.add_pk('ba_dim_next', 'ad');

ANALYZE ba_dim_next.ad;
