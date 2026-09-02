-- 1. Total volume per instrument per month. (Check: 30 rows — every instrument traded in every month.)
SELECT
  DATE_TRUNC(trades.trade_date, MONTH) AS trade_month,
  instruments.ticker,
  SUM(trades.volume) AS total_volume
FROM
  `de-project-finance.market_practice.trades` AS trades
LEFT JOIN
  `de-project-finance.market_practice.instruments` AS instruments
  USING (instrument_id)
GROUP BY ALL
ORDER BY trade_month;

-- 2. Which calendar month had the highest total volume? (Check: May, at 40,500.)
SELECT
  DATE_TRUNC(trades.trade_date, MONTH) AS trade_month,
  SUM(trades.volume) AS total_volume
FROM
  `de-project-finance.market_practice.trades` AS trades
GROUP BY ALL
ORDER BY total_volume DESC;
