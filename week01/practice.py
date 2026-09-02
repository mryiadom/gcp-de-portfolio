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


# 1. Print every trade priced above 220. (Check: should be 4 of the 10.)
for trade in trades:
    if trade['price'] > 220:
        print(trade['ticker'], trade['price'])

# 2. Store the same ten trades three different ways — a list of dicts, a dict keyed by ticker, and a list of tuples. Write one sentence on which you'd pick for looking up a single ticker by name, and why.
by_ticker = {t["ticker"]: t for t in trades}
as_tuples = [(t["ticker"], t["price"], t["volume"], t["side"]) for t in trades]

# 3. Use a set to find how many distinct tickers are in the list. (Check: should be 5.)
tickers = {t["ticker"] for t in trades}
print(len(tickers))
