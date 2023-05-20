"""
Alpaca’s paper trading service uses a different domain and different credentials from the live API. 
You’ll need to connect to the right domain so that you don’t run your paper trading algo on your live account.

To use the paper trading api, set APCA-API-KEY-ID and APCA-API-SECRET-KEY to your paper credentials, and set the domain to paper-api.alpaca.markets.
TRADING_API_URL = "https://paper-api.alpaca.markets/v2"
TRADING_API_URL = "https://api.alpaca.markets/v2"

Paper or live account urls defined in auth() function
"""

"""

Get the account
GET /v2/account
Returns the account associated with the API key

function account()::DataFrame

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
side 	    string 	    Optional        Filters down to orders that have a matching side field set. See the Order model’s side field for the values you can specify here :: Valid values: buy, sell
symbols 	string 	    Optional        A comma-separated list of symbols to filter by (ex. “AAPL,TSLA,MSFT”). A currency pair is required for crypto orders (ex. “BTCUSD,BCHUSD,LTCUSD,ETCUSD”).

#  examples
orders_df = get_orders(nothing; status=nothing, limit=nothing, after=nothing, until=nothing, direction=nothing, nested=nothing, side="buy")
orders_df = get_orders("TSLA,AAPL"; status=nothing, limit=nothing, after=nothing, until=nothing, direction=nothing, nested=nothing, side=nothing)

"""
function get_orders(symbols::Any; status::Any=nothing, limit::Any=nothing, after::Any=nothing, until::Any=nothing, direction::Any=nothing, nested::Any=nothing, side::Any=nothing)::DataFrame

    # end point url for orders at the live or paper account
    url = join([TRADING_API_URL, "orders"], "/")

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

    # order_id is optional
    # pull all orders or filter per the attribute
    if all(isnothing.([status, limit, after, until, direction, nested, side, symbols]))
        # end point url for orders at the live or paper account
        url = join([TRADING_API_URL, "orders"], "/")
    else
        paramsurl = params_question_mark_sep(params)
        url = join([url, paramsurl], "?")
        print(url)
    end

    res = HTTP.get(url, headers = HEADERS[])
    resdict = JSON.parse(String(res.body))
    resdf = DataFrame(resdict)
    #print(DataFrame([[names(resdf)]; collect.(eachrow(resdf))], [:column; Symbol.(axes(resdf, 1))]))
    return resdf
end


"""

function replace_an_order(symbols::Any; status::Any=nothing, limit::Any=nothing, after::Any=nothing, until::Any=nothing, direction::Any=nothing, nested::Any=nothing, side::Any=nothing)::DataFrame

Replace an order
PATCH /v2/orders/{order_id}
Replaces a single order with updated parameters. Each parameter overrides the corresponding attribute of the existing order. The other attributes remain the same as the existing order.

Path Parameters
Attribute	Type	    Requirement	        Description
order_id	string<uuid>	Optional        Order ID

Body Parameters
Attribute	        Type	                    Requirement	            Description
qty	                string<int>	                Optional                number of shares to trade
time_in_force	    string                      Optional                Please see Understand Orders for more info on what values are possible for what kind of orders.
limit_price	        string<number>	            Optional                required if type is limit or stop_limit
stop_price	        string<number>	            Optional                required if type is stop or stop_limit
trail	            string<number>	            Optional                the new value of the trail_price or trail_percent value (works only for type=“trailing_stop”)
client_order_id	    string (<= 48 characters)	Optional                A unique identifier for the order. Automatically generated if not sent.

#  examples
order_id_string = "1483d27e-f49b-4216-9d20-e78a0541a049"
replace_an_order(order_id_string; qty="1",time_in_force="gtc")

"""
function replace_an_order(order_id::String; qty::Any=nothing, time_in_force::Any=nothing, limit_price::Any=nothing, stop_price::Any=nothing, trail::Any=nothing, client_order_id::Any=nothing)::DataFrame

    # end point url for orders at the live or paper account
    url = join([TRADING_API_URL, "orders"], "/")

    params = Dict(
    "qty" => qty,
    "time_in_force" => time_in_force,
    "limit_price" => limit_price, 
    "stop_price" => stop_price,
    "trail" => trail, 
    "client_order_id" => client_order_id
    )

    # join order_id 
    url = join([url, order_id], "/")
    # build parameters into the url seperated by ?
    paramsurl = params_question_mark_sep(params)
    url = join([url, paramsurl], "?")
    # send url and body
    res = HTTP.patch(url, body=json(params), headers = HEADERS[])
    resdict = JSON.parse(String(res.body))
    # save response to dataframe
    resdf = DataFrame(resdict)
    #print(DataFrame([[names(resdf)]; collect.(eachrow(resdf))], [:column; Symbol.(axes(resdf, 1))]))
    return resdf
end


"""

function get_orders_by_order_id(order_id::Any)::DataFrame

GET /v2/orders/{order_id}
Retrieves a single order for the given order_id

Query Parameters
Attribute 	Type 	          Requirement 	  Description
order_id 	string<uuid>      Optional        Order ID

#  examples
orders_by_id_df = get_orders_by_order_id(order_id)
orders_by_id_df = get_orders_by_order_id(nothing)


"""
function get_orders_by_order_id(order_id::String)::DataFrame

    # end point url for orders at the live or paper account
    url = join([TRADING_API_URL, "orders"], "/")

    # order_id is optional
    # pull all orders or per the order id
    if isnothing(order_id)
        # end point url for orders at the live or paper account
        url = join([TRADING_API_URL, "orders"], "/")
    elseif 1 != isnothing(order_id)
        url = join([url, order_id], "/")
    end

    res = HTTP.get(url, headers = HEADERS[])
    resdict = JSON.parse(String(res.body))
    resdf = DataFrame(resdict)
    #print(DataFrame([[names(resdf)]; collect.(eachrow(resdf))], [:column; Symbol.(axes(resdf, 1))]))
    return resdf
end


"""

function get_orders_by_client_order_id(client_order_id::String)::DataFrame


GET /v2/orders:by_client_order_id
Retrieves a single order for the given client_order_id.

Query Parameters
Attribute 	        Type        Requirement     Description
client_order_id 	string      Optional        Client Order ID

#  examples
client_order_id = "breakout_1"
orders_by_id_df = get_orders_by_client_order_id(client_order_id)

"""
function get_orders_by_client_order_id(client_order_id::String)::DataFrame

    # end point url for orders at the live or paper account
    url = join([TRADING_API_URL, "orders:by_client_order_id"], "/")
    url = join([url, "?client_order_id=", client_order_id])

    res = HTTP.get(url, headers = HEADERS[])
    resdict = JSON.parse(String(res.body))
    resdf = DataFrame(resdict)
    #print(DataFrame([[names(resdf)]; collect.(eachrow(resdf))], [:column; Symbol.(axes(resdf, 1))]))
    return resdf
end


"""

Cancel all orders

function cancel_all_orders()::DataFrame

DELETE /v2/orders
Attempts to cancel all open orders. A response will be provided for each order that is attempted to be cancelled. If an order is no longer cancelable, the server will respond with status 500 and reject the request.

#  examples
cancel_all_orders()

"""
function cancel_all_orders()::DataFrame
    # end point url for orders at the live or paper account
    url = join([TRADING_API_URL, "orders"], "/")
   
    res = HTTP.delete(url, headers = HEADERS[])
    resdict = JSON.parse(String(res.body))
    resdf = DataFrame(resdict)
    return resdf
end


"""

Cancel an order

function cancel_order(order_id::String)::DataFrame

DELETE /v2/orders/{order_id}
Attempts to cancel an open order. If the order is no longer cancelable (example: status="filled"), the server will respond with status 422, and reject the request. Upon acceptance of the cancel request, it returns status 204.

Path Parameters
Attribute	Type	        Requirement	    Description
order_id	string<uuid>	Optional        Order ID

#  examples
order_id_value = "b46662d6-46b9-446b-a9a2-45aff3dd0418"
cancel_order(order_id_value)

"""
function cancel_order(order_id::String)
    # end point url for orders at the live or paper account
    url = join([TRADING_API_URL, "orders"], "/")
    url = join([url, order_id], "/")
    HTTP.delete(url, headers = HEADERS[])
end

#=
"""

Place an order
POST /v2/orders

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

#=
# consider retaining response in a df
res = HTTP.post(url, body=json(params), headers = HEADERS[])
resdict = JSON.parse(String(res.body))
print(resdict)
post_response_df = DataFrame(resdict)
print(DataFrame([[names(post_response_df)]; collect.(eachrow(post_response_df))], [:column; Symbol.(axes(post_response_df, 1))]))

return post_response_df
=#
end
=#

"""

Place an order
POST /v2/orders

-+ Market Order +-

function place_market_order(symbol::String; qty::Any=nothing, notional::Any=nothing, side::Any=nothing, type::String="market", time_in_force::Any=nothing, 
    extended_hours::Any=nothing, client_order_id::Any=nothing)

Body Parameters
Attribute 	        Type 	                    Requirement 	    Description
symbol 	            string 	                    Required            symbol, asset ID, or currency pair to identify the asset to trade
qty 	            string<number> 	            Required            number of shares to trade. Can be fractionable for only market and day order types.
notional 	        string<number> 	            Required            dollar amount to trade. Cannot work with qty. Can only work for market order types and day for time in force.
side 	            string 	                    Required            buy or sell
type 	            string 	                    Required            market, limit, stop, stop_limit, or trailing_stop
time_in_force 	    string 	                    Required            Please see Understand Orders for more info on what values are possible for what kind of orders. :: day, gtc, opg, cls, ioc, fok
extended_hours 	    boolean 	                Optional            (default) false. If true, order will be eligible to execute in premarket/afterhours. Only works with type limit and time_in_force day.
client_order_id 	string (<= 48 characters) 	Optional            A unique identifier for the order. Automatically generated if not sent.

"""
function place_market_order(symbol::String; qty::Any=nothing, notional::Any=nothing, side::Any=nothing, type::String="market", time_in_force::Any=nothing, 
    extended_hours::Any=nothing, client_order_id::Any=nothing)

    # control the required input parameters
    if !isnothing(qty) && !isnothing(notional)
        @assert isnothing(qty) && isnothing(notional) || !isnothing(qty) && isnothing(notional) "Either qty or notational permitted - can not state both"
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
        @assert type == "market" "type should be 'market'"
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
    "extended_hours" => extended_hours,
    "client_order_id" => client_order_id
  )

  # send order
  HTTP.post(url, body=json(params), headers = HEADERS[])

#=
# consider retaining response in a df
res = HTTP.post(url, body=json(params), headers = HEADERS[])
resdict = JSON.parse(String(res.body))
print(resdict)
post_response_df = DataFrame(resdict)
print(DataFrame([[names(post_response_df)]; collect.(eachrow(post_response_df))], [:column; Symbol.(axes(post_response_df, 1))]))

return post_response_df
=#
end


"""

Place an order
POST /v2/orders

-+ Limit Order +-

function place_limit_order(symbol::String; qty::Any=nothing, notional::Any=nothing, side::Any=nothing, type::String="limit", time_in_force::Any=nothing, limit_price::Any=nothing, 
    extended_hours::Any=nothing, client_order_id::Any=nothing)

Body Parameters
Attribute 	        Type 	                    Requirement 	    Description
symbol 	            string 	                    Required            symbol, asset ID, or currency pair to identify the asset to trade
qty 	            string<number> 	            Required            number of shares to trade. Can be fractionable for only market and day order types.
notional 	        string<number> 	            Required            dollar amount to trade. Cannot work with qty. Can only work for market order types and day for time in force.
side 	            string 	                    Required            buy or sell
type 	            string 	                    Required            market, limit, stop, stop_limit, or trailing_stop
time_in_force 	    string 	                    Required            Please see Understand Orders for more info on what values are possible for what kind of orders. :: day, gtc, opg, cls, ioc, fok
limit_price 	    string<number> 	            Required            required if type is limit or stop_limit
extended_hours 	    boolean 	                Optional            (default) false. If true, order will be eligible to execute in premarket/afterhours. Only works with type limit and time_in_force day.
client_order_id 	string (<= 48 characters) 	Optional            A unique identifier for the order. Automatically generated if not sent.


"""
function place_limit_order(symbol::String; qty::Any=nothing, notional::Any=nothing, side::Any=nothing, type::String="limit", time_in_force::Any=nothing, limit_price::Any=nothing, 
    extended_hours::Any=nothing, client_order_id::Any=nothing)

    # control the required input parameters
    if !isnothing(qty) && !isnothing(notional)
        @assert isnothing(qty) && isnothing(notional) || !isnothing(qty) && isnothing(notional) "Either qty or notational permitted - can not state both"
    end

    if type == "limit" && isnothing(limit_price) 
        @assert !isnothing(limit_price)  "limit_price required if type is limit"
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
        @assert type == "limit" "type should be 'limit'"
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
    "extended_hours" => extended_hours,
    "client_order_id" => client_order_id
  )

  # send order
  HTTP.post(url, body=json(params), headers = HEADERS[])

#=
# consider retaining response in a df
res = HTTP.post(url, body=json(params), headers = HEADERS[])
resdict = JSON.parse(String(res.body))
print(resdict)
post_response_df = DataFrame(resdict)
print(DataFrame([[names(post_response_df)]; collect.(eachrow(post_response_df))], [:column; Symbol.(axes(post_response_df, 1))]))

return post_response_df
=#
end


"""

Place an order
POST /v2/orders

-+ Stop Order +-

function place_stop_order(symbol::String; qty::Any=nothing, notional::Any=nothing, side::Any=nothing, type::String="stop", time_in_force::Any=nothing, stop_price::Any=nothing, 
    extended_hours::Any=nothing, client_order_id::Any=nothing)


Body Parameters
Attribute 	        Type 	                    Requirement 	    Description
symbol 	            string 	                    Required            symbol, asset ID, or currency pair to identify the asset to trade
qty 	            string<number> 	            Required            number of shares to trade. Can be fractionable for only market and day order types.
notional 	        string<number> 	            Required            dollar amount to trade. Cannot work with qty. Can only work for market order types and day for time in force.
side 	            string 	                    Required            buy or sell
type 	            string 	                    Required            market, limit, stop, stop_limit, or trailing_stop
time_in_force 	    string 	                    Required            Please see Understand Orders for more info on what values are possible for what kind of orders. :: day, gtc, opg, cls, ioc, fok
stop_price 	        string<number> 	            Required            required if type is stop or stop_limit
extended_hours 	    boolean 	                Optional            (default) false. If true, order will be eligible to execute in premarket/afterhours. Only works with type limit and time_in_force day.
client_order_id 	string (<= 48 characters) 	Optional            A unique identifier for the order. Automatically generated if not sent.

"""
function place_stop_order(symbol::String; qty::Any=nothing, notional::Any=nothing, side::Any=nothing, type::String="stop", time_in_force::Any=nothing, stop_price::Any=nothing, 
    extended_hours::Any=nothing, client_order_id::Any=nothing)

    # control the required input parameters
    if !isnothing(qty) && !isnothing(notional)
        @assert isnothing(qty) && isnothing(notional) || !isnothing(qty) && isnothing(notional) "Either qty or notational permitted - can not state both"
    end

    if type == "stop" && isnothing(stop_price) 
        @assert !isnothing(stop_price)  "stop_price required if type is stop"
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
        @assert type == "stop" "type should be 'stop'"
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
    "stop_price" => stop_price,
    "extended_hours" => extended_hours,
    "client_order_id" => client_order_id
  )

  # send order
  HTTP.post(url, body=json(params), headers = HEADERS[])

#=
# consider retaining response in a df
res = HTTP.post(url, body=json(params), headers = HEADERS[])
resdict = JSON.parse(String(res.body))
print(resdict)
post_response_df = DataFrame(resdict)
print(DataFrame([[names(post_response_df)]; collect.(eachrow(post_response_df))], [:column; Symbol.(axes(post_response_df, 1))]))

return post_response_df
=#
end


"""

Place an order
POST /v2/orders

-+ Stop Limit Order +-

function place_stop_limit_order(symbol::String; qty::Any=nothing, notional::Any=nothing, side::Any=nothing, type::Any=nothing, time_in_force::Any=nothing, stop_price::Any=nothing, 
    extended_hours::Any=nothing, client_order_id::Any=nothing)


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
extended_hours 	    boolean 	                Optional            (default) false. If true, order will be eligible to execute in premarket/afterhours. Only works with type limit and time_in_force day.
client_order_id 	string (<= 48 characters) 	Optional            A unique identifier for the order. Automatically generated if not sent.


"""
function place_stop_limit_order(symbol::String; qty::Any=nothing, notional::Any=nothing, side::Any=nothing, type::String="stop_limit", time_in_force::Any=nothing, limit_price::Any=nothing, stop_price::Any=nothing, 
    extended_hours::Any=nothing, client_order_id::Any=nothing)

    # control the required input parameters
    if !isnothing(qty) && !isnothing(notional)
        @assert isnothing(qty) && isnothing(notional) || !isnothing(qty) && isnothing(notional) "Either qty or notational permitted - can not state both"
    end

    if (type == "stop_limit") && isnothing(stop_price) 
        @assert !isnothing(stop_price)  "stop_price required if type is stop_limit"
    end

    if (type == "stop_limit") && isnothing(limit_price) 
        @assert !isnothing(limit_price)  "limit_price required if type is stop_limit"
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
        @assert type == "stop_limit" "type should be 'stop_limit'"
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
    "limit_price" => limit_price,
    "stop_price" => stop_price,
    "time_in_force" => time_in_force,
    "extended_hours" => extended_hours,
    "client_order_id" => client_order_id
  )

  # send order
  HTTP.post(url, body=json(params), headers = HEADERS[])

#=
# consider retaining response in a df
res = HTTP.post(url, body=json(params), headers = HEADERS[])
resdict = JSON.parse(String(res.body))
print(resdict)
post_response_df = DataFrame(resdict)
print(DataFrame([[names(post_response_df)]; collect.(eachrow(post_response_df))], [:column; Symbol.(axes(post_response_df, 1))]))

return post_response_df
=#
end


"""

Place an order
POST /v2/orders

-+ Trailing Stop Order +-

function place_trailing_stop_order(symbol::String; qty::Any=nothing, notional::Any=nothing, side::Any=nothing, type::Any=nothing, time_in_force::Any=nothing,
    trail_price::Any=nothing, trail_percent::Any=nothing, extended_hours::Any=nothing, client_order_id::Any=nothing)


Body Parameters
Attribute 	        Type 	                    Requirement 	    Description
symbol 	            string 	                    Required            symbol, asset ID, or currency pair to identify the asset to trade
qty 	            string<number> 	            Required            number of shares to trade. Can be fractionable for only market and day order types.
notional 	        string<number> 	            Required            dollar amount to trade. Cannot work with qty. Can only work for market order types and day for time in force.
side 	            string 	                    Required            buy or sell
type 	            string 	                    Required            market, limit, stop, stop_limit, or trailing_stop
time_in_force 	    string 	                    Required            Please see Understand Orders for more info on what values are possible for what kind of orders. :: day, gtc, opg, cls, ioc, fok
trail_price 	    string<number> 	            Required            this or trail_percent is required if type is trailing_stop
trail_percent 	    string<number> 	            Required            this or trail_price is required if type is trailing_stop
extended_hours 	    boolean 	                Optional            (default) false. If true, order will be eligible to execute in premarket/afterhours. Only works with type limit and time_in_force day.
client_order_id 	string (<= 48 characters) 	Optional            A unique identifier for the order. Automatically generated if not sent.

"""
function place_trailing_stop_order(symbol::String; qty::Any=nothing, notional::Any=nothing, side::Any=nothing, type="trailing_stop", time_in_force::Any=nothing,
    trail_price::Any=nothing, trail_percent::Any=nothing, extended_hours::Any=nothing, client_order_id::Any=nothing)

    # control the required input parameters
    if !isnothing(qty) && !isnothing(notional)
        @assert isnothing(qty) && isnothing(notional) || !isnothing(qty) && isnothing(notional) "Either qty or notational permitted - can not state both"
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
        @assert type == "trailing_stop" "type should be 'trailing_stop'"
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
    "trail_price" => trail_price,
    "trail_percent" => trail_percent,
    "extended_hours" => extended_hours,
    "client_order_id" => client_order_id
  )

  # send order
  HTTP.post(url, body=json(params), headers = HEADERS[])

#=
# consider retaining response in a df
res = HTTP.post(url, body=json(params), headers = HEADERS[])
resdict = JSON.parse(String(res.body))
print(resdict)
post_response_df = DataFrame(resdict)
print(DataFrame([[names(post_response_df)]; collect.(eachrow(post_response_df))], [:column; Symbol.(axes(post_response_df, 1))]))

return post_response_df
=#
end


"""

Place an order
POST /v2/orders

-+ Bracket Order +-

place_bracket_order(symbol::String; qty::Any=nothing, notional::Any=nothing, side::Any=nothing, type::Any=nothing, time_in_force::Any=nothing, limit_price::Any=nothing, stop_price::Any=nothing, extended_hours::Any=nothing, client_order_id::Any=nothing, order_class::String="bracket", bracket_take_profit_limit::Any=nothing, 
    bracket_stop_trigger::Any=nothing, bracket_stop_limit::Any=nothing)


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
extended_hours 	    boolean 	                Optional            (default) false. If true, order will be eligible to execute in premarket/afterhours. Only works with type limit and time_in_force day.
client_order_id 	string (<= 48 characters) 	Optional            A unique identifier for the order. Automatically generated if not sent.
order_class 	    string 	                    Optional            simple, bracket, oco or oto. The empty string ("") is synonym for simple. For details of non-simple order classes, please see Bracket Order Overview   
take_profit 	    object 	                    Optional            Additional parameters for take-profit leg of advanced orders
stop_loss 	        object 	                    Optional            Additional parameters for stop-loss leg of advanced orders

"""
function place_bracket_order(symbol::String; qty::Any=nothing, notional::Any=nothing, side::Any=nothing, type::Any=nothing, time_in_force::Any=nothing, limit_price::Any=nothing, stop_price::Any=nothing, extended_hours::Any=nothing, client_order_id::Any=nothing, order_class::String="bracket", bracket_take_profit_limit::Any=nothing, 
    bracket_stop_trigger::Any=nothing, bracket_stop_limit::Any=nothing)

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
        @assert type == "market" || type == "limit" "type should be 'market' or 'limit'"
    end

    if !isnothing(time_in_force)
        # day, gtc, opg, cls, ioc, fok
        @assert time_in_force == "day" || time_in_force == "gtc" || time_in_force == "opg" || time_in_force == "cls" || time_in_force == "ioc" || time_in_force == "fok" "time_in_force available arguments :: day, gtc, opg, cls, ioc, fok"
    end

    if !isnothing(type)
        # "bracket" bracket order - "oco" = OCO (One-Cancels-Other) or "oto" = OTO (One-Triggers-Other)  
        @assert !isnothing(order_class) "order_class is required"
    end

    if !isnothing(side)
        # buy or sell
        @assert order_class == "bracket"  "order_class available arguments :: bracket"
    end

    if !isnothing(order_class)
        @assert !isnothing(bracket_take_profit_limit) && (!isnothing(bracket_stop_trigger) || !isnothing(bracket_stop_limit) ) "bracket_take_profit_limit, bracket_stop_limit and bracket_stop_trigger required if order_class bracket"
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
    "extended_hours" => extended_hours,
    "client_order_id" => client_order_id,
    "order_class" => order_class,
    "take_profit" => Dict("limit_price"=> bracket_take_profit_limit),
    "stop_loss" => Dict("stop_price"=> bracket_stop_trigger, "limit_price" =>  bracket_stop_limit)
  )

  # send order
  # order parameters are sent in the body
  HTTP.post(url, body=json(params), headers = HEADERS[])

#=
# consider retaining response in a df
res = HTTP.post(url, body=json(params), headers = HEADERS[])
resdict = JSON.parse(String(res.body))
print(resdict)
post_response_df = DataFrame(resdict)
print(DataFrame([[names(post_response_df)]; collect.(eachrow(post_response_df))], [:column; Symbol.(axes(post_response_df, 1))]))

return post_response_df
=#
end

"""

Place an order
POST /v2/orders

"OCO (One-Cancels-Other) is another type of advanced order type. This is a set of two orders with the same side (buy/buy or sell/sell) and currently only exit order is supported."

-+ OCO Order +-

place_oco_order(symbol::String; qty::Any=nothing, notional::Any=nothing, side::Any=nothing, type::Any=nothing, time_in_force::Any=nothing, limit_price::Any=nothing, stop_price::Any=nothing, extended_hours::Any=nothing, client_order_id::Any=nothing, order_class::String="oco", oco_bracket_take_profit_limit::Any=nothing, 
    oco_bracket_stop_trigger::Any=nothing, oco_bracket_stop_limit::Any=nothing)


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
extended_hours 	    boolean 	                Optional            (default) false. If true, order will be eligible to execute in premarket/afterhours. Only works with type limit and time_in_force day.
client_order_id 	string (<= 48 characters) 	Optional            A unique identifier for the order. Automatically generated if not sent.
order_class 	    string 	                    Optional            simple, bracket, oco or oto. The empty string ("") is synonym for simple. For details of non-simple order classes, please see Bracket Order Overview   
take_profit 	    object 	                    Optional            Additional parameters for take-profit leg of advanced orders
stop_loss 	        object 	                    Optional            Additional parameters for stop-loss leg of advanced orders

"""
function place_oco_order(symbol::String; qty::Any=nothing, notional::Any=nothing, side::Any=nothing, type::Any=nothing, time_in_force::Any=nothing, limit_price::Any=nothing, stop_price::Any=nothing, extended_hours::Any=nothing, client_order_id::Any=nothing, order_class::String="oco", oco_bracket_take_profit_limit::Any=nothing, 
    oco_bracket_stop_trigger::Any=nothing, oco_bracket_stop_limit::Any=nothing)

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
        @assert type == "market" || type == "limit" "type should be 'market' or 'limit'"
    end

    if !isnothing(time_in_force)
        # day, gtc, opg, cls, ioc, fok
        @assert time_in_force == "day" || time_in_force == "gtc" || time_in_force == "opg" || time_in_force == "cls" || time_in_force == "ioc" || time_in_force == "fok" "time_in_force available arguments :: day, gtc, opg, cls, ioc, fok"
    end

    if !isnothing(type)
        # "bracket" bracket order - "oco" = OCO (One-Cancels-Other) or "oto" = OTO (One-Triggers-Other)  
        @assert !isnothing(order_class) "order_class is required"
    end

    if !isnothing(side)
        # buy or sell
        @assert order_class == "oco"  "order_class available arguments :: oco"
    end

    if !isnothing(order_class)
        @assert !isnothing(oco_bracket_take_profit_limit) && (!isnothing(oco_bracket_stop_trigger) || !isnothing(oco_bracket_stop_limit) ) "oco_bracket_take_profit_limit, oco_bracket_stop_limit and oco_bracket_stop_trigger required if order_class bracket"
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
    "extended_hours" => extended_hours,
    "client_order_id" => client_order_id,
    "order_class" => order_class,
    "take_profit" => Dict("limit_price"=> oco_bracket_take_profit_limit),
    "stop_loss" => Dict("stop_price"=> oco_bracket_stop_trigger, "limit_price" => oco_bracket_stop_limit)
  )

  # send order
  # order parameters are sent in the body
  HTTP.post(url, body=json(params), headers = HEADERS[])

#=
# consider retaining response in a df
res = HTTP.post(url, body=json(params), headers = HEADERS[])
resdict = JSON.parse(String(res.body))
print(resdict)
post_response_df = DataFrame(resdict)
print(DataFrame([[names(post_response_df)]; collect.(eachrow(post_response_df))], [:column; Symbol.(axes(post_response_df, 1))]))

return post_response_df
=#
end


"""

Place an order
POST /v2/orders

"OTO (One-Triggers-Other) is a variant of bracket order. It takes one of the take-profit or stop-loss order in addition to the entry order. For example, if you want to set only a stop-loss order attached to the position, without a take-profit, you may want to consider OTO orders."

-+ OTO Order +-

place_oco_order(symbol::String; qty::Any=nothing, notional::Any=nothing, side::Any=nothing, type::Any=nothing, time_in_force::Any=nothing, limit_price::Any=nothing, stop_price::Any=nothing, extended_hours::Any=nothing, client_order_id::Any=nothing, order_class::String="oco", oco_bracket_take_profit_limit::Any=nothing, 
    oco_bracket_stop_trigger::Any=nothing, oco_bracket_stop_limit::Any=nothing)


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
extended_hours 	    boolean 	                Optional            (default) false. If true, order will be eligible to execute in premarket/afterhours. Only works with type limit and time_in_force day.
client_order_id 	string (<= 48 characters) 	Optional            A unique identifier for the order. Automatically generated if not sent.
order_class 	    string 	                    Optional            simple, bracket, oco or oto. The empty string ("") is synonym for simple. For details of non-simple order classes, please see Bracket Order Overview   
take_profit 	    object 	                    Optional            Additional parameters for take-profit leg of advanced orders
stop_loss 	        object 	                    Optional            Additional parameters for stop-loss leg of advanced orders

"""
function place_oto_order(symbol::String; qty::Any=nothing, notional::Any=nothing, side::Any=nothing, type::Any=nothing, time_in_force::Any=nothing, limit_price::Any=nothing, stop_price::Any=nothing, extended_hours::Any=nothing, client_order_id::Any=nothing, order_class::String="oto", 
    oto_stop_trigger::Any=nothing, oto_stop_limit::Any=nothing)

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
        @assert type == "market" || type == "limit" "type should be 'market' or 'limit'"
    end

    if !isnothing(time_in_force)
        # day, gtc, opg, cls, ioc, fok
        @assert time_in_force == "day" || time_in_force == "gtc" || time_in_force == "opg" || time_in_force == "cls" || time_in_force == "ioc" || time_in_force == "fok" "time_in_force available arguments :: day, gtc, opg, cls, ioc, fok"
    end

    if !isnothing(type)
        # "bracket" bracket order - "oco" = OCO (One-Cancels-Other) or "oto" = OTO (One-Triggers-Other)  
        @assert !isnothing(order_class) "order_class is required"
    end

    if !isnothing(side)
        # buy or sell
        @assert order_class == "oto"  "order_class available arguments :: oto"
    end

    if !isnothing(order_class)
        @assert (!isnothing(oto_stop_trigger) || !isnothing(oto_stop_limit) ) "oto_stop_trigger and oto_stop_limit required if order_class bracket"
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
    "extended_hours" => extended_hours,
    "client_order_id" => client_order_id,
    "order_class" => order_class,
    "stop_loss" => Dict("stop_price"=> oto_stop_trigger, "limit_price" => oto_stop_limit)
  )

  # send order
  # order parameters are sent in the body
  HTTP.post(url, body=json(params), headers = HEADERS[])

#=
# consider retaining response in a df
res = HTTP.post(url, body=json(params), headers = HEADERS[])
resdict = JSON.parse(String(res.body))
print(resdict)
post_response_df = DataFrame(resdict)
print(DataFrame([[names(post_response_df)]; collect.(eachrow(post_response_df))], [:column; Symbol.(axes(post_response_df, 1))]))

return post_response_df
=#
end


"""

Get open positions

function get_open_positions()::DataFrame

GET /v2/positions
Retrieves a list of the account’s open positions.

"""
function get_open_positions()::DataFrame

    # end point url for orders at the live or paper account
    url = join([TRADING_API_URL, "positions"], "/")

    res = HTTP.get(url, headers = HEADERS[])
    resdict = JSON.parse(String(res.body))
    resdf = DataFrame(resdict)
    print(DataFrame([[names(resdf)]; collect.(eachrow(resdf))], [:column; Symbol.(axes(resdf, 1))]))
    return resdf
end


"""

Get an open position

function get_position(symbol::String)::DataFrame

GET /v2/positions/{symbol}
Retrieves the account’s open position for the given symbol

"""
function get_position(symbol::String)::DataFrame
    # end point url for orders at the live or paper account
    url = join([TRADING_API_URL, "positions"], "/")
    url = join([url, symbol], "/")

    res = HTTP.get(url, headers = HEADERS[])
    resdict = JSON.parse(String(res.body))
    resdf = DataFrame(resdict)
    #print(DataFrame([[names(resdf)]; collect.(eachrow(resdf))], [:column; Symbol.(axes(resdf, 1))]))
    return resdf
end


"""

Close all positions

function close_all_positions(cancel_orders::Bool)::DataFrame

DELETE /v2/positions
Closes (liquidates) all of the account’s open long and short positions. A response will be provided for each order that is attempted to be cancelled. 
If an order is no longer cancelable, the server will respond with status 500 and reject the request.

"""
function close_all_positions(cancel_orders::Bool)::DataFrame

    # end point url for orders at the live or paper account
    url = join([TRADING_API_URL, "positions"], "/")
    url = join([url, "?cancel_orders=", cancel_orders])

    res = HTTP.delete(url, headers = HEADERS[])
    resdict = JSON.parse(String(res.body))
    resdf = DataFrame(resdict)
    #print(DataFrame([[names(resdf)]; collect.(eachrow(resdf))], [:column; Symbol.(axes(resdf, 1))]))
    return resdf
end


"""

Close a position

function close_position(symbol::String; qty::Any=nothing, percentage::Any=nothing)::DataFrame

DELETE /v2/positions/{symbol}
Closes (liquidates) the account’s open position for the given symbol. Works for both long and short positions.

Path Parameters
Attribute	Type	    Requirement	    Description
symbol	    string	        Optional    symbol or asset_id

Query Parameters
Attribute	    Type        Requirement	     Description
qty	            decimal	    Optional         the number of shares to liquidate. Can accept up to 9 decimal points. Cannot work with percentage
percentage	    decimal	    Optional         percentage of position to liquidate. Must be between 0 and 100. Would only sell fractional if position is originally fractional. Can accept up to 9 decimal points. Cannot work with qty


"""
function close_position(symbol::String; qty::Any=nothing, percentage::Any=nothing)::DataFrame

    if !isnothing(qty) || !isnothing(percentage)
        @assert isnothing(qty) && !isnothing(percentage) || !isnothing(qty) && isnothing(percentage) "Either qty or percentage permitted - can not state both"
    end

    # end point url for orders at the live or paper account
    url = join([TRADING_API_URL, "positions"], "/")
    
    params = Dict(
    "qty" => qty,
    "percentage" => percentage
    )

    # join symbol to url 
    url = join([url, symbol], "/")
    # build attributes into the url seperated by ?
    paramsurl = params_question_mark_sep(params)
    url = join([url, paramsurl], "?")
    # delete
    res = HTTP.delete(url, headers = HEADERS[])
    # parse to dataframr
    resdict = JSON.parse(String(res.body))
    resdf = DataFrame(resdict)
    #print(DataFrame([[names(resdf)]; collect.(eachrow(resdf))], [:column; Symbol.(axes(resdf, 1))]))
    return resdf
end
