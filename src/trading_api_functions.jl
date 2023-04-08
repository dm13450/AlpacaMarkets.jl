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



"""

Place an order

function place_order(symbol::String; qty::Any=nothing, notional::Any=nothing, side::Any=nothing, type::Any=nothing, time_in_force::Any=nothing, limit_price::Any=nothing, stop_price::Any=nothing,
    trail_price::Any=nothing, trail_percent::Any=nothing, extended_hours::Any=nothing, client_order_id::Any=nothing, order_class::Any=nothing, take_profit::Any=nothing, stop_loss::Any=nothing)


Body Parameters
Attribute 	        Type 	                    Requirement 	    Description
symbol 	            string 	                    Required            symbol, asset ID, or currency pair to identify the asset to trade
qty 	            string<number> 	            Required            number of shares to trade. Can be fractionable for only market and day order types.
notional 	        string<number> 	            Required            dollar amount to trade. Cannot work with qty. Can only work for market order types and day for time in force.
side 	            string 	                    Required            buy or sell
type 	            string 	                    Required            market, limit, stop, stop_limit, or trailing_stop
time_in_force 	    string 	                    Required            Please see Understand Orders for more info on what values are possible for what kind of orders. :: day, gtc, opg, cls, ioc, fok
limit_price 	    string<number> 	            Required            required if type is limit or stop_limit
stop_price 	        string<number> 	            Required            required if type is stop or stop_limit
trail_price 	    string<number> 	            Required            this or trail_percent is required if type is trailing_stop
trail_percent 	    string<number> 	            Required            this or trail_price is required if type is trailing_stop
extended_hours 	    boolean 	                Optional            (default) false. If true, order will be eligible to execute in premarket/afterhours. Only works with type limit and time_in_force day.
client_order_id 	string (<= 48 characters) 	Optional            A unique identifier for the order. Automatically generated if not sent.
order_class 	    string 	                    Optional            simple, bracket, oco or oto. The empty string ("") is synonym for simple. For details of non-simple order classes, please see Bracket Order Overview
take_profit 	    object 	                    Optional            Additional parameters for take-profit leg of advanced orders
stop_loss 	        object 	                    Optional            Additional parameters for stop-loss leg of advanced orders

# example 
place_order("AAPL"; qty="1", notional=nothing, side="buy", type="limit", time_in_force="gtc", limit_price="150.56", stop_price=nothing,
    trail_price=nothing, trail_percent=nothing, extended_hours=nothing, client_order_id=nothing, order_class=nothing, take_profit=nothing, stop_loss=nothing)


place_order("AAPL"; qty="1", notional=nothing, side="sell", type="limit", time_in_force="day", limit_price="155.56", stop_price=nothing,
    trail_price=nothing, trail_percent=nothing, extended_hours=nothing, client_order_id=nothing, order_class=nothing, take_profit=nothing, stop_loss=nothing)
"""
function place_order(symbol::String; qty::Any=nothing, notional::Any=nothing, side::Any=nothing, type::Any=nothing, time_in_force::Any=nothing, limit_price::Any=nothing, stop_price::Any=nothing,
    trail_price::Any=nothing, trail_percent::Any=nothing, extended_hours::Any=nothing, client_order_id::Any=nothing, order_class::Any=nothing, take_profit::Any=nothing, stop_loss::Any=nothing)

    # control the required input parameters
    if !isnothing(qty) && !isnothing(notional)
        @assert isnothing(qty) && isnothing(notional) || !isnothing(qty) && isnothing(notional) "Either qty or notational permitted - can not state both"
    end

    if type == "market" && (!isnothing(limit_price) || !isnothing(stop_price))
        @assert isnothing(limit_price) && isnothing(stop_price) "market orders require no stop or limit price"
    end

    if type == "limit" || type == "stop_limit" && isnothing(limit_price) 
        @assert !isnothing(limit_price)  "limit_price required if type is limit or stop_limit"
    end

    if (type == "stop" || type == "stop_limit") && isnothing(stop_price) 
        @assert !isnothing(stop_price)  "stop_price required if type is stop or stop_limit"
    end

    if type == "trailing_stop" && (isnothing(trail_price) || isnothing(trail_percent))
        @assert type == "trailing_stop" && !isnothing(trail_price) || !isnothing(trail_percent)  "trail_price or trail_percent required if type is trailing_stop"
    end

    if type == "trailing_stop"  && !isnothing(trail_price) && !isnothing(trail_percent)
        @assert isnothing(trail_price) && isnothing(trail_percent) || !isnothing(trail_price) && isnothing(trail_percent) "Either trail_price or trail_percent permitted - can not state both"
    end

    if isnothing(symbol)
        @assert !isnothing(symbol) "symbol is required"
    end

    if isnothing(side)
        @assert !isnothing(side) "side is required"
    end

    if isnothing(type)
        @assert !isnothing(type) "type is required"
    end

    if isnothing(time_in_force)
        @assert !isnothing(time_in_force) "time_in_force is required"
    end

    if !isnothing(side)
        # buy or sell
        @assert side == "buy" || side == "sell" "side available arguments :: buy or sell"
    end

    if !isnothing(type)
        # market, limit, stop, stop_limit, or trailing_stop
        @assert type == "market" || type == "limit" || type == "stop" || type == "stop_limit" || type == "trailing_stop" "type available arguments :: market, limit, stop, stop_limit, or trailing_stop"
    end

    if !isnothing(time_in_force)
        # day, gtc, opg, cls, ioc, fok
        @assert time_in_force == "day" || time_in_force == "gtc" || time_in_force == "opg" || time_in_force == "cls" || time_in_force == "ioc" || time_in_force == "fok" "time_in_force available arguments :: day, gtc, opg, cls, ioc, fok"
    end

    # url 
    url = join([TRADING_API_URL, "orders?"], "/")

    # place the function variables inside a Dict()
    params = Dict(
    "symbol" => symbol,
    "qty" => qty,
    "notional" => notional, 
    "side" => side,
    "type" => type, 
    "time_in_force" => time_in_force,
    "limit_price" => limit_price,
    "stop_price" => stop_price,
    "trail_price" => trail_price,
    "trail_percent" => trail_percent,
    "extended_hours" => extended_hours,
    "client_order_id" => client_order_id,
    "order_class" => order_class,
    "take_profit" => take_profit,
    "stop_loss" => stop_loss
  )

  # build urls
  paramsurl = params_uri(params)
  url = join([url, paramsurl], "/")
  # send order
  HTTP.post(url, body=json(params), headers = HEADERS[])

end

export place_order