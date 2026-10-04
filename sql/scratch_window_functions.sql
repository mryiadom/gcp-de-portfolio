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


-- ============================================================
-- Tuesday: LAG, LEAD and period-over-period returns
-- Uses market_practice.prices (daily OHLCV), not trades: a daily return
-- needs one price per ticker per day, and trades are irregular.
-- ============================================================

-- 1. Daily percentage return per ticker with LAG, close to previous close.
-- (Check: 5 null rows, one per ticker -- each ticker's first day has no
-- previous close. If only 1 were null, PARTITION BY ticker would be missing
-- and the window would run down the whole table.)
-- The return compares close with the previous CLOSE. Using open instead
-- measures the overnight gap, a different quantity, and gives wrong
-- best-day values (AAPL 3.05 rather than 3.18).
WITH
  base AS (
    SELECT
      * EXCEPT (volume, high, low),
      LAG(close) OVER (PARTITION BY ticker ORDER BY price_date) AS old_close,
    FROM
      `de-project-finance.market_practice.prices`
  )
SELECT
  *,
  ROUND(SAFE_DIVIDE((close - old_close), old_close) * 100, 2) AS pct_change
FROM
  base;

-- 2a. Each ticker's single best day, CTE form (portable to Postgres).
-- (Check: AAPL 2026-01-28 +3.18%, MSFT 2026-05-29 +3.73%.)
-- ROW_NUMBER rather than RANK, so a tie still returns exactly one row.
-- A MAX() OVER (PARTITION BY ticker) finds the best VALUE but not which
-- row held it, and GROUP BY would drop the date entirely.
WITH
  base AS (
    SELECT
      * EXCEPT (volume, high, low),
      LAG(close) OVER (PARTITION BY ticker ORDER BY price_date) AS old_close,
    FROM
      `de-project-finance.market_practice.prices`
  ),
  final AS (
    SELECT
      ticker,
      price_date,
      ROUND(SAFE_DIVIDE((close - old_close), old_close) * 100, 2) AS pct_change
    FROM
      base
  ),
  best_trade_day AS (
    SELECT
      *,
      ROW_NUMBER()
        OVER (PARTITION BY ticker ORDER BY pct_change DESC) AS pct_rank
    FROM
      final
  )
SELECT
  * EXCEPT (pct_rank)
FROM
  best_trade_day
WHERE
  pct_rank = 1;

-- 2b. The same with QUALIFY: shorter, BigQuery/Snowflake only.
-- Note pct_change must stay numeric. Turning it into a string with CONCAT
-- would make ORDER BY sort alphabetically ('9.99%' > '10.01%'), which
-- only happens to work while every return has one digit before the point.
WITH
  base AS (
    SELECT
      * EXCEPT (volume, high, low),
      LAG(close) OVER (PARTITION BY ticker ORDER BY price_date) AS old_close,
    FROM
      `de-project-finance.market_practice.prices`
  ),
  final AS (
    SELECT
      ticker,
      price_date,
      ROUND(SAFE_DIVIDE((close - old_close), old_close) * 100, 2) AS pct_change
    FROM
      base
  )
SELECT
  *,
  ROW_NUMBER()
    OVER (PARTITION BY ticker ORDER BY pct_change DESC) AS pct_rank
FROM
  final
QUALIFY
  pct_rank = 1;

-- 3. LEAD: flag any day followed by a fall of more than 2%. (42 WATCH days.)
-- The subtraction runs in the OPPOSITE order from the LAG version above.
-- With LAG the other price is the earlier one, so (close - old_close) is
-- right. With LEAD the other price is the LATER one, so it must be
-- (next_close - close) / close: tomorrow minus today, against today.
-- Copying the LAG formula flags days followed by a RISE instead -- all 49
-- of the days it flagged were followed by a price increase.
-- Each ticker's last day has no next day, so its pct_change is null and
-- falls through to PASS ("no data" reported as "fine").
WITH
  base AS (
    SELECT
      * EXCEPT (volume, high, low),
      LEAD(close) OVER (PARTITION BY ticker ORDER BY price_date) AS next_close,
    FROM
      `de-project-finance.market_practice.prices`
  ),
  pct_chg AS (
    SELECT
      ticker,
      price_date,
      ROUND(SAFE_DIVIDE((next_close - close), close) * 100, 2) AS pct_change
    FROM
      base
  )
SELECT
  *,
  CASE WHEN pct_change < -2 THEN 'WATCH' ELSE 'PASS' END AS pct_change_status
FROM
  pct_chg;
