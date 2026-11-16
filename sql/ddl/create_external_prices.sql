-- sql/ddl/create_external_prices.sql
-- Week 12 Wednesday: external table over prices.csv in Cloud Storage
-- Explicit schema (not auto-detect). skip_leading_rows = 1 skips the header line.

CREATE SCHEMA IF NOT EXISTS market_elt
OPTIONS (location = 'europe-west2');

CREATE OR REPLACE EXTERNAL TABLE market_elt.raw_prices (
  ticker      STRING,
  price_date  DATE,
  open        NUMERIC,
  high        NUMERIC,
  low         NUMERIC,
  close       NUMERIC,
  volume      INT64
)
OPTIONS (
  format = 'CSV',
  uris = ['gs://ronald-equity-analytics-raw-dev/raw/prices/ingest_date=2026-10-11/*.csv'],
  skip_leading_rows = 1
);
