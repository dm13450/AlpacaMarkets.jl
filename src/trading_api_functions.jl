"""
Alpaca’s paper trading service uses a different domain and different credentials from the live API. 
You’ll need to connect to the right domain so that you don’t run your paper trading algo on your live account.

To use the paper trading api, set APCA-API-KEY-ID and APCA-API-SECRET-KEY to your paper credentials, and set the domain to paper-api.alpaca.markets.
"""

# Trading account to use for trading - paper or live
# there are two domains 
#1. api.alpaca.markets :: this is for Alpaca’s live API domain 
#2. paper-api.alpaca.markets :: this is for paper trading 

const SELECT_ACCOUNT = "PAPER" # or "LIVE"

# set the URL for PAPER or LIVE trading
if SELECT_ACCOUNT == "PAPER"
    const TRADING_API_URL = "https://paper-api.alpaca.markets/v2"
elseif SELECT_ACCOUNT == "LIVE"
    const TRADING_API_URL = "https://api.alpaca.markets/v2"
end


"""

function account()::DataFrame

Returns a DataFrame with trading account details

Trading Account
The account API serves important information related to an account, including account status, funds available for trade, funds available for withdrawal, and various flags relevant to an account’s ability to trade. 
An account maybe be blocked for just for trades (trading_blocked flag) or for both trades and transfers (account_blocked flag) if Alpaca identifies the account to be engaging in any suspicious activity. 
Also, in accordance with FINRA’s pattern day trading rule, an account may be flagged for pattern day trading (pattern_day_trader flag), which would inhibit an account from placing any further day-trades. 
Please note that cryptocurrencies are not eligible assets to be used as collateral for margin accounts and will require the asset be traded using cash only.

# examples
account_data = account()

# extract specific variables from the account_data dataframe
pattern_day_trader_state = account_data.pattern_day_trader[1]
daytrade_count = account_data.daytrade_count[1]
buying_power = parse(Float64,account_data.buying_power[1])

"""
function account()::DataFrame
    url = join([TRADING_API_URL, "account"], "/")
    res = HTTP.get(url, headers = HEADERS[])
    resdf = DataFrame(JSON.parse(String(res.body)))
    return resdf
end


"""

function get_orders(symbols::Any; status::Any=nothing, limit::Any=nothing, after::Any=nothing, until::Any=nothing, direction::Any=nothing, nested::Any=nothing, side::Any=nothing)::DataFrame

Get a list of orders
GET /v2/orders
Retrieves a list of orders for the account, filtered by the supplied query parameters

Query Parameters
Attribute 	Type 	    Requirement 	Description
status 	    string      Optional        Order status to be queried. open, closed or all. Defaults to open.
limit 	    int 	    Optional        The maximum number of orders in response. Defaults to 50 and max is 500.
after 	    timestamp 	Optional        The response will include only ones submitted after this timestamp (exclusive.)
until 	    timestamp 	Optional        The response will include only ones submitted until this timestamp (exclusive.)
direction 	string 	    Optional        The chronological order of response based on the submission time. asc or desc. Defaults to desc.
nested 	    boolean 	Optional        If true, the result will roll up multi-leg orders under the legs field of primary order.
side 	    string 	    Optional        Filters down to orders that have a matching side field set. See the Order model’s side field for the values you can specify here
symbols 	string 	    Optional        A comma-separated list of symbols to filter by (ex. “AAPL,TSLA,MSFT”). A currency pair is required for crypto orders (ex. “BTCUSD,BCHUSD,LTCUSD,ETCUSD”).

#  examples
orders_df = get_orders(nothing; status=nothing, limit=nothing, after=nothing, until=nothing, direction=nothing, nested=nothing, side="buy")::DataFrame
orders_df = get_orders("TSLA,AAPL"; status=nothing, limit=nothing, after=nothing, until=nothing, direction=nothing, nested=nothing, side=nothing)::DataFrame

"""
function get_orders(symbols::Any; status::Any=nothing, limit::Any=nothing, after::Any=nothing, until::Any=nothing, direction::Any=nothing, nested::Any=nothing, side::Any=nothing)::DataFrame

    # end point url for orders at the live or paper account
    url = join([TRADING_API_URL, "orders?"], "/")

    params = Dict(
    "status" => status,
    "limit" => limit,
    "after" => after, 
    "until" => until,
    "direction" => direction, 
    "nested" => nested,
    "side" => side,
    "symbols" => symbols
    )

    paramsurl = params_uri(params)
    url = join([url, paramsurl], "/")
    res = HTTP.get(url, headers = HEADERS[])
    resdict = JSON.parse(String(res.body))
    resdf = DataFrame(resdict)
    print(DataFrame([[names(resdf)]; collect.(eachrow(resdf))], [:column; Symbol.(axes(resdf, 1))]))
    return resdf
end