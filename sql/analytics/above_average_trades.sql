-- 1. Find every trade priced above the average price for its own instrument. (Check: 29 rows.)
-- Written as a join (CTE + LEFT JOIN back to the per-ticker average) rather than a
-- correlated subquery — this reads more clearly because the per-ticker average is named
-- as its own step you can inspect independently, instead of being recomputed per row.
WITH
  base AS (
    SELECT
      trades.instrument_id,
      instruments.ticker,
      trades.price
    FROM
      `de-project-finance.market_practice.trades` AS trades
    LEFT JOIN
      `de-project-finance.market_practice.instruments` AS instruments
      USING (instrument_id)
  ),
  avg_by_ticker AS (
    SELECT
      ticker,
      AVG(price) AS avg_price
    FROM
      base
    GROUP BY
      ticker
  )
SELECT
  base.ticker,
  base.price,
  avg_by_ticker.avg_price
FROM
  base
LEFT JOIN
  avg_by_ticker
  USING (ticker)
WHERE
  base.price > avg_by_ticker.avg_price
ORDER BY
  base.ticker, base.price;

-- 2. Now find trades above the overall average price of 238.08. (Check: 11 rows.)
-- Differs so much from exercise 1 because each instrument trades at its own price level
-- (e.g. MSFT $400s-$490s vs XOM $110s-$125s). Comparing against its own average catches
-- roughly half of any instrument's trades, but the single blended overall average is
-- dragged up by the higher-priced instruments, so most trades from the cheaper
-- instruments never clear it at all, regardless of where they sit in their own range.
-- A plain (non-correlated) subquery reads clearly here since there's no per-group value
-- to name separately — it's just one number, computed once.
SELECT
  trades.price
FROM
  `de-project-finance.market_practice.trades` AS trades
WHERE
  trades.price > (
    SELECT AVG(price) FROM `de-project-finance.market_practice.trades`
  )
ORDER BY
  trades.price;
