-- 1. Total and average volume per instrument. (Check: MSFT 63,000 total; JPM 16,000.)
SELECT
  instruments.ticker,
  SUM(trades.volume) total_volume,
  ROUND(AVG(trades.volume), 2) avg_volume
FROM
  `de-project-finance.market_practice.instruments` AS instruments
LEFT JOIN
  `de-project-finance.market_practice.trades` AS trades
  USING (instrument_id)
GROUP BY ALL;

-- 2. Same query, filtered to instruments whose total volume exceeds 35,000. (Check: exactly 2 — JNJ and MSFT.)
SELECT
  instruments.ticker,
  SUM(trades.volume) total_volume,
  ROUND(AVG(trades.volume), 2) avg_volume
FROM
  `de-project-finance.market_practice.instruments` AS instruments
LEFT JOIN
  `de-project-finance.market_practice.trades` AS trades
  USING (instrument_id)
GROUP BY ALL
HAVING
  SUM(trades.volume) > 35000;

-- 3. Group by instrument and side.
-- WHERE can't replace HAVING here because WHERE filters rows before GROUP BY aggregates
-- them, so the aggregate value (SUM(volume)) doesn't exist yet at that point — HAVING
-- runs after aggregation, so it's the only stage where filtering on it is possible.
SELECT
  instruments.ticker,
  trades.side,
  SUM(trades.volume) total_volume,
  ROUND(AVG(trades.volume), 2) avg_volume
FROM
  `de-project-finance.market_practice.instruments` AS instruments
LEFT JOIN
  `de-project-finance.market_practice.trades` AS trades
  USING (instrument_id)
GROUP BY ALL;
