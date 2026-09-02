
def pct_return(old_price, new_price):

    '''This function returns the percentage change. It raises an error when old price is 0'''
    try:
        if old_price == 0:
            raise ValueError('old price must be non-zero')
    except ValueError as ex:
            print(ex)
            return None

    pct_change = round(((new_price - old_price) / old_price) * 100, 2)
    return pct_change

def classify_trade(volume, threshold=1000):

    '''Classifies a trade as BLOCK or REGULAR based on volume against a threshold.'''
    if volume > threshold:
        return 'BLOCK'
    else:
        return 'REGULAR'

def format_gbp(amount):

    '''Returns amount in GBP currency format'''
    return '£{:,.2f}'.format(amount)


if __name__ == '__main__':
    print(pct_return(200, 230))
    print(classify_trade(200, 1000))
    print(format_gbp(200))