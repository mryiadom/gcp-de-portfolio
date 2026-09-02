-- run once; pick EU so your data stays in-region
CREATE SCHEMA IF NOT EXISTS market_practice
OPTIONS (location = 'EU');

CREATE OR REPLACE TABLE market_practice.venues (
  venue_code  STRING NOT NULL,
  venue_name  STRING NOT NULL,
  country     STRING NOT NULL,
  PRIMARY KEY (venue_code) NOT ENFORCED
);

CREATE OR REPLACE TABLE market_practice.instruments (
  instrument_id  INT64  NOT NULL,
  ticker         STRING NOT NULL,
  name           STRING NOT NULL,
  sector         STRING NOT NULL,
  PRIMARY KEY (instrument_id) NOT ENFORCED
);

CREATE OR REPLACE TABLE market_practice.trades (
  trade_id       INT64        NOT NULL,
  instrument_id  INT64        NOT NULL,
  trade_date     DATE         NOT NULL,
  price          NUMERIC      NOT NULL,
  volume         INT64        NOT NULL,
  venue_code     STRING       NOT NULL,
  side           STRING       NOT NULL,
  PRIMARY KEY (trade_id) NOT ENFORCED,
  FOREIGN KEY (instrument_id)
    REFERENCES market_practice.instruments(instrument_id) NOT ENFORCED,
  FOREIGN KEY (venue_code)
    REFERENCES market_practice.venues(venue_code) NOT ENFORCED
);
