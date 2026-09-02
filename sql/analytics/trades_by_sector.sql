-- 1. Join trades to instruments and return ticker, sector, price. (Check: INNER JOIN gives 54 rows.)
SELECT
  instruments.ticker,
  instruments.sector,
  trades.price
FROM
  `de-project-finance.market_practice.instruments` AS instruments
INNER JOIN
  `de-project-finance.market_practice.trades` AS trades
  USING (instrument_id);

-- 2. Same join, rewritten as a LEFT JOIN from instruments. (Check: 55 rows.)
-- The extra row is NVDA — it's in the instruments lookup but has no trades against it,
-- so LEFT JOIN still includes it (every row from the left table is kept), with all
-- trade-side columns, including price, coming back NULL.
SELECT
  instruments.ticker,
  instruments.sector,
  trades.price
FROM
  `de-project-finance.market_practice.instruments` AS instruments
LEFT JOIN
  `de-project-finance.market_practice.trades` AS trades
  USING (instrument_id);

-- 3. Count trades per sector. (Check: Technology 22, Healthcare 11, Financials 11, Energy 10.)
SELECT
  COUNT(*) AS sector_count,
  sector
FROM
  `de-project-finance.market_practice.instruments` AS instruments
INNER JOIN
  `de-project-finance.market_practice.trades` AS trades
  USING (instrument_id)
GROUP BY ALL;
