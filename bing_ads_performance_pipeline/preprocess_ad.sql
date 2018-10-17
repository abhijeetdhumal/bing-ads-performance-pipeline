CREATE TABLE ba_tmp.ad
  AS
    SELECT DISTINCT
      ad_id,
      last_value(ad_name)
      OVER ad AS ad_name,
      last_value(ad_group_id)
      OVER ad AS ad_group_id,
      last_value(ad_group_name)
      OVER ad AS ad_group_name,
      last_value(campaign_id)
      OVER ad AS campaign_id,
      last_value(campaign_name)
      OVER ad AS campaign_name,
      last_value(account_id)
      OVER ad AS account_id,
      last_value(account_name)
      OVER ad AS account_name,
      last_value(attributes)
      OVER ad AS attributes
    FROM ba_data.account_structure
    WHERE ad_id IN (SELECT DISTINCT ad_id
                    FROM ba_data.ad_performance)
    WINDOW ad AS (
      PARTITION BY ad_id
      RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING );

ANALYZE ba_tmp.ad;
