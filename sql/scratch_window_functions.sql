-- Week 10 scratch: window functions
-- Practice queries, not part of the sql/analytics/ query library.
-- The week's committed deliverable is sql/analytics/returns_analysis.sql (Thu-Fri).


-- ============================================================
-- Monday: ROW_NUMBER, RANK, DENSE_RANK, NTILE
-- ============================================================

-- 1a. Top 3 trades by volume per ticker, via a CTE. (Check: 15 rows.)
-- A window function cannot be filtered in WHERE, because WHERE is evaluated
-- before the window functions are computed. Wrapping in a CTE is the
-- ANSI-standard way round that, and it ports to Snowflake and Postgres
-- unchanged -- which is this week's stated goal.
WITH
  base AS (
    SELECT
      trades.trade_date,
      instruments.ticker,
      trades.volume,
      ROW_NUMBER()
        OVER (PARTITION BY ticker ORDER BY volume DESC) AS volume_rank
    FROM
      `de-project-finance.market_practice.trades` AS trades
    LEFT JOIN
      `de-project-finance.market_practice.instruments` AS instruments
      USING (instrument_id)
  )
SELECT
  *
FROM
  base
WHERE
  volume_rank IN (1, 2, 3);

-- 1b. The same answer with QUALIFY, which filters on a window function
-- directly and can reference the alias. Shorter, but BigQuery/Snowflake
-- specific -- Postgres has no QUALIFY, so 1a is the portable form.
SELECT
  trades.trade_date,
  instruments.ticker,
  trades.volume,
  ROW_NUMBER()
    OVER (PARTITION BY ticker ORDER BY volume DESC) AS volume_rank
FROM
  `de-project-finance.market_practice.trades` AS trades
LEFT JOIN
  `de-project-finance.market_practice.instruments` AS instruments
  USING (instrument_id)
QUALIFY volume_rank <= 3;

-- 2. ROW_NUMBER vs RANK vs DENSE_RANK over one window.
-- AAPL supplies the ties: three trades at 7,500 and two at 1,000.
--   ROW_NUMBER  numbers every row distinctly, breaking ties arbitrarily:  1, 2, 3
--   RANK        gives ties the same number, then skips:                   1, 1, 1, 4
--   DENSE_RANK  gives ties the same number, no skip:                      1, 1, 1, 2
-- Consequence: "top 3 by volume" means three ROWS under ROW_NUMBER, but
-- the top three DISTINCT volumes under DENSE_RANK -- which for AAPL is
-- six rows, not three. Same English, different answer.
SELECT
  instruments.ticker,
  trades.volume,
  ROW_NUMBER() OVER w AS row_num,
  RANK()       OVER w AS rank_val,
  DENSE_RANK() OVER w AS dense_rank_val
FROM
  `de-project-finance.market_practice.trades` AS trades
LEFT JOIN
  `de-project-finance.market_practice.instruments` AS instruments
  USING (instrument_id)
WHERE instruments.ticker = 'AAPL'
WINDOW w AS (PARTITION BY instruments.ticker ORDER BY trades.volume DESC)
ORDER BY trades.volume DESC;

-- 3. NTILE(4): volume quartiles within each ticker.
-- NTILE splits by ROW COUNT, not by value, so buckets are even and ties
-- are ignored -- identical volumes can land either side of a boundary.
-- Partitioning by ticker asks "is this a big trade for this instrument?"
-- rather than "is this a big trade overall?", which matters because MSFT
-- never trades below 1,500 while JPM and XOM top out at 5,000.
-- Actual split: 3/3/3/2 for the four tickers with 11 trades, 3/3/2/2 for
-- XOM with 10 -- earlier buckets absorb the remainder.
SELECT
  trades.trade_date,
  instruments.ticker,
  trades.volume,
  NTILE(4) OVER (PARTITION BY ticker ORDER BY volume DESC) AS bucket_group
FROM
  `de-project-finance.market_practice.trades` AS trades
LEFT JOIN
  `de-project-finance.market_practice.instruments` AS instruments
  USING (instrument_id);
