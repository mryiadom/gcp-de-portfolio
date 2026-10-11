# src/market_data_client.py -- Week 11 Wednesday: MarketDataClient
import requests
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

class MarketDataClient:
    def __init__(self):
        self.session = requests.Session()
        retry_rule = Retry(total=5, backoff_factor=0.5, status_forcelist=[429, 500, 502, 503, 504])
        adapter = HTTPAdapter(max_retries=retry_rule)
        self.session.mount("https://", adapter)