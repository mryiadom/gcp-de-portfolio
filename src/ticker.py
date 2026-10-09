# src/ticker.py -- Week 11 Tuesday: the Ticker class
class Ticker:

    ticker_count = 0

    def __init__(self, symbol: str, name: str, sector: str):
        
        self.symbol = symbol
        self.name = name
        self.sector = sector
        Ticker.ticker_count += 1

    def __repr__(self) -> str:
        return f"Ticker('{self.symbol}', '{self.name}', '{self.sector}')"

    @classmethod
    def how_many(cls):
        return f'There are {cls.ticker_count} tickers'

    @property
    def is_tech(self) -> bool:
        return self.sector == 'Technology'

tickers = {
    'AAPL': Ticker('AAPL', 'Apple Inc.', 'Technology'),
    'MSFT': Ticker('MSFT', 'Microsoft Corp.', 'Technology'),
    'JPM': Ticker('JPM', 'JPMorgan Chase & Co.', 'Financials'),
    'XOM': Ticker('XOM', 'Exxon Mobil Corp.', 'Energy'),
    'JNJ': Ticker('JNJ', 'Johnson & Johnson', 'Healthcare'),
}


for instance in tickers.values():
    # count is the same on every object, the other fields differ
    print(instance.symbol, instance.name, instance.sector, instance.ticker_count, instance.is_tech)

print(Ticker.how_many())

