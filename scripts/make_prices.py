# scripts/make_prices.py  -- run once
import pandas as pd, numpy as np

BASE = {"AAPL": 225.0, "MSFT": 415.0, "JPM": 212.0, "XOM": 118.0, "JNJ": 158.0}
DAYS = pd.bdate_range("2026-01-01", "2026-06-30")   # business days only

rows = []
for i, (ticker, base) in enumerate(BASE.items()):
    rng = np.random.default_rng(1000 + i)
    close = base
    for d in DAYS:
        drift = rng.normal(0.0004, 0.014)           # ~1.4% daily vol
        close = round(close * (1 + drift), 2)
        o = round(close * (1 + rng.normal(0, 0.004)), 2)
        h = round(max(o, close) * (1 + abs(rng.normal(0, 0.005))), 2)
        l = round(min(o, close) * (1 - abs(rng.normal(0, 0.005))), 2)
        rows.append({"ticker": ticker, "price_date": d.date(),
                     "open": o, "high": h, "low": l, "close": close,
                     "volume": int(rng.integers(5_000_000, 60_000_000))})

pd.DataFrame(rows).to_csv("data/prices.csv", index=False)
