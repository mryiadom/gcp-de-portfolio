-- Week 8 Monday — SELECT, WHERE, ORDER BY, NULL handling
-- Practice queries, not part of the sql/analytics/ query library (that starts Tuesday).

-- 1. Return all trades priced above 220, newest first. (Check: 19 rows.)
SELECT
  *
FROM
  `de-project-finance.market_practice.trades`
WHERE
  price > 220
ORDER BY
  trade_date DESC;

-- 2. Return trades with a price between 150 and 250. (Check: 29 rows.)
SELECT
  *
FROM
  `de-project-finance.market_practice.trades`
WHERE
  price BETWEEN 150 AND 250;

-- 3. WHERE side = NULL vs WHERE side IS NULL — both return 0 rows here.
-- `=` compares against NULL and evaluates to NULL (unknown), not TRUE, for every row,
-- so WHERE excludes them all regardless of whether the column actually contains NULLs.
-- IS NULL is the operator built to test for NULL correctly.
SELECT
  *
FROM
  `de-project-finance.market_practice.trades`
WHERE
  side = NULL;

SELECT
  *
FROM
  `de-project-finance.market_practice.trades`
WHERE
  side IS NULL;
