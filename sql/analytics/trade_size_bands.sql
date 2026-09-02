-- 3. Bucket trades into SMALL (<1000), MEDIUM (1000-4999) and LARGE (>=5000). (Check: 9 / 28 / 17.)
SELECT
  instruments.ticker,
  trades.price,
  trades.volume,
  CASE
    WHEN trades.volume < 1000 THEN 'SMALL'
    WHEN trades.volume BETWEEN 1000 AND 4999 THEN 'MEDIUM'
    WHEN trades.volume >= 5000 THEN 'LARGE'
    ELSE 'UNDEFINED'
    END AS trade_bucket
FROM
  `de-project-finance.market_practice.trades` AS trades
LEFT JOIN
  `de-project-finance.market_practice.instruments` AS instruments
  USING (instrument_id);
