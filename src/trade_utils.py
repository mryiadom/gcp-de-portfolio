
# TODO: money is handled as floats here. Roadmap Week 4 (Tue) covers why that's wrong for
# currency -- rounding errors compound across rows into reconciliation failures. Switch to
# Decimal in Python / NUMERIC in BigQuery when that week is worked through.

def pct_return(old_price, new_price):

    '''Returns the percentage change from old_price to new_price, to 2dp.

    Raises ValueError if old_price is zero. Handling that is the caller's job.
    '''
    if old_price == 0:
        raise ValueError('old price must be non-zero')

    pct_change = round(((new_price - old_price) / old_price) * 100, 2)
    return pct_change

def classify_trade(volume, threshold=1000):

    '''Classifies a trade as BLOCK or REGULAR based on volume against a threshold.

    A volume exactly equal to the threshold counts as BLOCK, matching the
    at-or-above banding used for trade size bands in sql/analytics/trade_size_bands.sql.
    '''
    if volume >= threshold:
        return 'BLOCK'
    else:
        return 'REGULAR'

def format_gbp(amount):

    '''Returns amount formatted as GBP currency, e.g. 1234.5 -> "£1,234.50".'''
    return '£{:,.2f}'.format(amount)


if __name__ == '__main__':
    print(pct_return(200, 230))
    print(classify_trade(5000))     # default threshold, above it
    print(classify_trade(200))      # default threshold, below it
    print(classify_trade(1000))     # exactly on the default threshold
    print(format_gbp(1234.5))
