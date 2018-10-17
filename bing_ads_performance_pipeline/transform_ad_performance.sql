CREATE TABLE ba_dim_next.device (
  device_id   SMALLSERIAL PRIMARY KEY,
  device_name TEXT NOT NULL
);

INSERT INTO ba_dim_next.device (device_name)
  SELECT DISTINCT device_type
  FROM ba_data.ad_performance
  ORDER BY device_type;


CREATE TABLE ba_dim_next.ad_performance (
  day_fk              BIGINT           NOT NULL,
  ad_fk               BIGINT           NOT NULL,
  device_fk           SMALLINT         NOT NULL,

  clicks              INTEGER          NOT NULL,
  impressions         INTEGER          NOT NULL,
  cost                DOUBLE PRECISION NOT NULL,
  conversions         INTEGER          NOT NULL,
  average_position    DOUBLE PRECISION,
  ctr                 DOUBLE PRECISION,
  cost_per_conversion DOUBLE PRECISION,
  conversion_rate     DOUBLE PRECISION,
  revenue             DOUBLE PRECISION
);

INSERT INTO ba_dim_next.ad_performance
  SELECT
    to_char("date", 'YYYYMMDD') :: INTEGER                       AS day_fk,
    ap.ad_id                                                     AS ad_id,
    device_id                                                    AS device_fk,

    sum(clicks)                                                  AS clicks,
    sum(impressions)                                             AS impressions,
    sum(spend)                                                   AS cost,
    sum(conversions)                                             AS conversions,
    avg(average_position)                                        AS average_position,
    avg(trim(BOTH '%' FROM ctr) :: DOUBLE PRECISION)             AS ctr,
    avg(cost_per_conversion),
    avg(trim(BOTH '%' FROM conversion_rate) :: DOUBLE PRECISION) AS conversion_rate,
    sum(replace(revenue, ',', '') :: DOUBLE PRECISION)           AS revenue
  FROM ba_data.ad_performance ap
    JOIN ba_data.account_structure acs
      ON ap.ad_id = acs.ad_id
    JOIN ba_dim_next.device ON device_name = ap.device_type
  GROUP BY day_fk, ap.ad_id, device_id;

ANALYSE ba_dim_next.ad_performance;

CREATE FUNCTION ba_tmp.constrain_ad_performance()
  RETURNS VOID AS $$
SELECT util.add_fk('ba_dim_next', 'ad_performance', 'ba_dim_next', 'ad');
SELECT util.add_fk('ba_dim_next', 'ad_performance', 'ba_dim_next', 'device');
SELECT util.add_fk('ba_dim_next', 'ad_performance', 'time', 'day');
$$
LANGUAGE SQL;
