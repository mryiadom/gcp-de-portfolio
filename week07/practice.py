import os
import sys

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from src.trade_utils import pct_return, classify_trade, format_gbp

trades = [
    {"ticker": "AAPL", "price": 230.02, "volume": 2500, "side": "SELL"},
    {"ticker": "MSFT", "price": 430.23, "volume": 2500, "side": "BUY"},
    {"ticker": "JPM",  "price": 218.81, "volume": 1500, "side": "SELL"},
    {"ticker": "XOM",  "price": 113.61, "volume": 1000, "side": "SELL"},
    {"ticker": "JNJ",  "price": 158.15, "volume": 2500, "side": "BUY"},
    {"ticker": "AAPL", "price": 219.86, "volume": 7500, "side": "BUY"},
    {"ticker": "MSFT", "price": 452.56, "volume": 1500, "side": "SELL"},
    {"ticker": "JPM",  "price": 226.68, "volume": 1000, "side": "BUY"},
    {"ticker": "XOM",  "price": 115.70, "volume": 1000, "side": "SELL"},
    {"ticker": "JNJ",  "price": 166.07, "volume": 750,  "side": "SELL"},
]


'''MONDAY'''
# 1. Print every trade priced above 220. (Check: should be 4 of the 10.)
for trade in trades:
    if trade['price'] > 220:
        print(trade['ticker'], trade['price'])

# 2. Store the same ten trades three different ways — a list of dicts, a dict keyed by ticker, and a list of tuples.
by_ticker = {t["ticker"]: t for t in trades}
as_tuples = [(t["ticker"], t["price"], t["volume"], t["side"]) for t in trades]

# 3. Use a set to find how many distinct tickers are in the list. (Check: should be 5.)
tickers = {t["ticker"] for t in trades}
print(len(tickers))


'''TUESDAY'''
# 1. Loop 1–100, print only numbers not divisible by 3. (Check: 67 numbers.)
count = 0
for x in range(1, 101):
    if x % 3 != 0:
        print(x)
        count += 1

print(f'Total amount of numbers not divisble by 3 is {count}.')

# 2. Use enumerate to print each trade with a 1-based row number.
for index, trade in enumerate(trades, start=1):
    print(index, trade['ticker'], " - ", trade['price'])

# 3. Use zip to pair a list of tickers with a list of prices, then find the highest-priced ticker without calling max() on a dict.
tickers_names = []
ticker_prices = []
for ticker_price in trades:
    tickers_names.append(ticker_price['ticker'])
    ticker_prices.append(ticker_price['price'])

best_ticker = None
best_price = 0

for ticker, price in zip(tickers_names, ticker_prices):
    if price > best_price:
        best_ticker = ticker
        best_price = price

print(best_ticker, best_price)


'''WEDNESDAY'''
# 1. pct_return  2. classify_trade  3. format_gbp — moved to src/trade_utils.py on Friday, imported at the top of this file
print(pct_return(200, 230))
print(classify_trade(100, threshold=1000))
print(format_gbp(1234.5))


'''THURSDAY'''
# 1. Rewrite Monday's threshold filter as a single list comprehension.
prices = [(x["ticker"], x["price"]) for x in trades if x['price'] > 220]
print(prices)

# 2. Build a dict comprehension mapping ticker → total volume. AAPL should come out as 10000.
volume_by_ticker = {ticker: sum(t["volume"] for t in trades if t["ticker"] == ticker) for ticker in tickers}
print(volume_by_ticker)

# 3. pct_return raises ValueError when old_price is 0 — the raise lives in src/trade_utils.py,
# and catching it is the caller's job, which is here.
try:
    print(pct_return(0, 230))
except ValueError as ex:
    print(ex)


'''FRIDAY'''
# 1 & 2. Functions moved into src/trade_utils.py and imported at the top of this file — see the import above.
