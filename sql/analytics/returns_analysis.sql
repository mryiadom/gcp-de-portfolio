-- returns_analysis.sql
-- Question: which ticker led the market in each month, and who led most often?
--
-- Input: market_practice.prices, daily OHLCV for 5 tickers, 2026-01-01 to
-- 2026-06-30 (645 rows, 129 business days each). A daily return needs one price
-- per ticker per day, so this uses prices rather than the irregular trades table.
--
-- Written as two statements. Part 1 is the daily series (returns and a 7-day
-- moving average); Part 2 reduces to one row per ticker-month and ranks the
-- tickers against each other. Each stage is its own CTE so it can be run and
-- checked on its own.
--
-- ANSI window functions (LAG, RANK, ROWS frames) port to Snowflake and Postgres.
-- BigQuery-specific, and the parts to change when porting: MIN_BY/MAX_BY,
-- COUNTIF as a window function, and DATE_TRUNC(date, MONTH) argument order.
-- A single cell contains the answer to the final question: see months_ranked_first.
--
-- Result: AAPL and JPM tie, each ranking first in 2 of the 6 months (AAPL in
-- Jan and Feb, JPM in Mar and Jun); JNJ led in Apr and MSFT in May; XOM never.


-- ============================================================
-- Part 1: daily returns and a 7-day moving average, per ticker
-- Checks: 645 rows; 30 null ma_7 (6 per ticker).
-- ============================================================
WITH
  daily_returns AS (
    SELECT
      ticker,
      price_date,
      close,
      -- Previous trading day's close, within the same ticker. PARTITION BY
      -- ticker is what stops AAPL's first day borrowing a price from another
      -- ticker. Each ticker's first day has no previous close, so it is NULL.
      LAG(close) OVER (PARTITION BY ticker ORDER BY price_date) AS prev_close
    FROM
      `de-project-finance.market_practice.prices`
  ),
  with_returns AS (
    SELECT
      *,
      -- Close-to-close, in percent. Using open here would measure the
      -- overnight gap instead, a different quantity.
      SAFE_DIVIDE(close - prev_close, prev_close) * 100 AS daily_rtns
    FROM
      daily_returns
  ),
  moving_avg AS (
    SELECT
      *,
      -- 7-row moving average of the close. 6 PRECEDING + the current row is
      -- 7 rows (7 PRECEDING would be 8). SQL averages whatever rows a window
      -- holds, so without the CASE the first 6 rows would show an "average" of
      -- 1-6 prices labelled as a 7-day one. The gate (>= 7) and the frame
      -- (6 PRECEDING) are two separate 7s and must be changed together.
      CASE
        WHEN
          ROW_NUMBER() OVER (PARTITION BY ticker ORDER BY price_date) >= 7
          THEN
            AVG(close) OVER (
              PARTITION BY ticker
              ORDER BY price_date
              ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
            )
        END AS ma_7
    FROM
      with_returns
  )
SELECT
  ticker,
  price_date,
  close,
  ROUND(daily_rtns, 2) AS daily_rtns,
  ROUND(ma_7, 2) AS ma_7
FROM
  moving_avg
ORDER BY
  ticker, price_date;


-- ============================================================
-- Part 2: monthly return per ticker, ranked across tickers
-- Checks: 30 rows (5 tickers x 6 months); ranks 1-5 in every month.
-- ============================================================
WITH
  daily_returns AS (
    SELECT
      ticker,
      price_date,
      DATE_TRUNC(price_date, MONTH) AS price_month, -- keeps the year
      close,
      -- Same gated 7-row average as Part 1, used here for a month-end trend flag.
      CASE
        WHEN
          ROW_NUMBER() OVER (PARTITION BY ticker ORDER BY price_date) >= 7
          THEN
            AVG(close) OVER (
              PARTITION BY ticker
              ORDER BY price_date
              ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
            )
        END AS ma_7
    FROM
      `de-project-finance.market_practice.prices`
  ),
  monthly AS (
    -- One row per ticker-month. MIN_BY/MAX_BY (BigQuery) return the close on the
    -- first and last day of the month. The portable equivalent is FIRST_VALUE
    -- plus LAST_VALUE, but LAST_VALUE needs ROWS BETWEEN UNBOUNDED PRECEDING AND
    -- UNBOUNDED FOLLOWING: with an ORDER BY its default frame ends at the
    -- current row and it just returns that row's own close.
    SELECT
      ticker,
      price_month,
      MIN_BY(close, price_date) AS first_close,
      MAX_BY(close, price_date) AS last_close,
      MAX_BY(ma_7, price_date) AS month_end_ma_7
    FROM
      daily_returns
    GROUP BY
      ticker, price_month
  ),
  monthly_returns AS (
    SELECT
      *,
      -- First close of the month to last close of the month. The alternative,
      -- measuring from the previous month's last close, gives different
      -- figures and leaves January null (no December data). The first-to-last
      -- version omits the first day's own move.
      SAFE_DIVIDE(last_close - first_close, first_close) * 100 AS monthly_rtns
    FROM
      monthly
  ),
  ranked AS (
    SELECT
      *,
      -- Partitioned by MONTH, not ticker: this ranks the five tickers against
      -- each other within each month. PARTITION BY ticker would instead rank
      -- one ticker's months against each other, and those ranks could not be
      -- compared across tickers. RANK lets two exact ties share a place.
      RANK() OVER (PARTITION BY price_month ORDER BY monthly_rtns DESC) AS month_rank
    FROM
      monthly_returns
  )
SELECT
  price_month,
  ticker,
  ROUND(monthly_rtns, 2) AS monthly_rtns,
  month_rank,
  -- Did the month close above its 7-day moving average? NULL means fewer than
  -- 7 rows of history, which cannot happen at a month end in this data.
  last_close > month_end_ma_7 AS closed_above_ma_7,
  -- How many months this ticker ranked first, repeated on each of its rows.
  COUNTIF(month_rank = 1) OVER (PARTITION BY ticker) AS months_ranked_first
FROM
  ranked
ORDER BY
  price_month, month_rank;
