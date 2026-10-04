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


-- ============================================================
-- Wednesday: chained CTEs
-- ============================================================

-- 1. Rewrite the Week 8 Thursday subquery (trades above the overall average
-- price, 11 rows) as chained CTEs. (Check: same 11 rows.)
-- The average gets its own named step and is attached with a CROSS JOIN, so
-- the WHERE compares two plain columns and no nested SELECT is left.
-- CROSS JOIN is safe here ONLY because price_avg has exactly one row -- it
-- has no key to join on, so every trade is paired with that one row. With
-- two rows every trade would appear twice and the row count would double.
-- (The per-instrument version in sql/analytics/above_average_trades.sql
-- is already written as chained CTEs, so there is no subquery in it to
-- rewrite.)
WITH
  base AS (
    SELECT
      price
    FROM
      `de-project-finance.market_practice.trades`
  ),
  price_avg AS (
    SELECT
      AVG(price) AS avg_price
    FROM `de-project-finance.market_practice.trades`
  )
SELECT
  base.*
FROM
  base
CROSS JOIN
  price_avg
WHERE
  price > avg_price;

-- 2. Three-stage query: daily returns -> 7-day moving average -> rank within
-- month. This is the working core of sql/analytics/returns_analysis.sql.
-- Checks (all run): 645 rows; 30 null ma_7 (6 per ticker); 30 rank-1 rows
-- (5 tickers x 6 months); no rank-1 row has a null return.
--
--   * Every window is PARTITION BY ticker. Without it the LAG and the
--     average would run down the whole table and blend instruments trading
--     at 118 and 468 into one number.
--   * ROWS BETWEEN 6 PRECEDING AND CURRENT ROW is a 7-row window: the 6 before
--     plus the current row. 7 PRECEDING would be 8 rows.
--   * SQL averages whatever rows a window holds, so the first rows would carry
--     a value built from 1-6 prices, labelled as a 7-day average. pandas'
--     rolling(n) returned null until the window was full; SQL does not.
--     The CASE nulls ma_7 until the 7th row, leaving 6 nulls per ticker.
--     The gate (>= 7) and the frame (6 PRECEDING) are two separate 7s that
--     must be changed together.
--   * The condition is >= 7, not = 7. With = 7 only the 7th row per ticker
--     has a value (640 nulls instead of 30).
--   * Month is DATE_TRUNC(price_date, MONTH), which keeps the year, so
--     January 2026 and January 2027 could never share a rank group.
--   * Rank 1 is each ticker's best return in that month. DESC puts the null
--     first return of each ticker last, so it cannot reach rank 1.
-- Cross-check: AAPL's January best day is 2026-01-28 at +3.18%, the same row
-- as its best day over the whole period in Tuesday's query.
WITH
  base AS (
    SELECT
      ticker,
      price_date,
      DATE_TRUNC(price_date, MONTH) AS price_month,
      open,
      close,
      LAG(close) OVER (PARTITION BY ticker ORDER BY price_date) AS old_close
    FROM
      `de-project-finance.market_practice.prices`
  ),
  percentage_change AS (
    SELECT
      base.*,
      SAFE_DIVIDE((close - old_close), old_close) * 100 AS pct_chg
    FROM
      base
  ),
  moving_avg AS (
    SELECT
      *,
      CASE
        WHEN
          ROW_NUMBER() OVER (PARTITION BY ticker ORDER BY price_date ASC)
          >= 7
          THEN
            AVG(close)
              OVER (
                PARTITION BY ticker
                ORDER BY price_date
                ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
              )
        ELSE NULL
        END AS ma_7
    FROM
      percentage_change
  )
SELECT
  *,
  ROW_NUMBER()
    OVER (PARTITION BY ticker, price_month ORDER BY pct_chg DESC) AS pct_chg_rank
FROM
  moving_avg;

-- 3. Recursive CTE: when it is the right tool. Not written, by choice.
-- A normal CTE is a named step computed once; a recursive one has an anchor
-- plus a step that reads its own output, repeating until no new rows appear.
-- It suits data of unknown depth -- hierarchies, linked chains, generated
-- date ranges -- where the number of self-joins can't be written in advance.
-- Nothing in the returns query needs it: every stage is fixed-depth.
