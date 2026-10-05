# scripts/make_raw_trades.py  -- run once
import pandas as pd, numpy as np

# export your trades table to data/trades_clean.csv first, or rebuild it here
df = pd.read_csv("data/trades_clean.csv", parse_dates=["trade_date"])

rng = np.random.default_rng(20260729)

# 1. null out 6 prices and 3 volumes, spread across instruments
price_idx = rng.choice(df.index, size=6, replace=False)
vol_idx   = rng.choice(df.index.difference(price_idx), size=3, replace=False)
df.loc[price_idx, "price"] = np.nan
df.loc[vol_idx,   "volume"] = np.nan

# 2. duplicate two whole rows
dupes = df.sample(2, random_state=7)
df = pd.concat([df, dupes], ignore_index=True)

# 3. no dtype tampering needed: a CSV stores no types, so trade_date reads back
#    as a string and volume as float64 once it holds NaN. Monday finds both.

df.to_csv("data/raw_trades.csv", index=False)
print(df.shape)
