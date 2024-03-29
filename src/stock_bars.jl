"""
  stock_bars

Get historical aggregated price data for a stock.

`timeframe::AbstractString`: 1Min-59min, 1Hour-23Hour, 1Day-31Day

# Examples
```julia-repl
julia> stock_bars("AAPL", "5min")
```

"""
function stock_bars(symbol::AbstractString, timeframe::AbstractString;
                    startTime=nothing, endTime=nothing,
                    limit=nothing, page_token=nothing,
                    asof = nothing, adjustment = nothing,
                    feed = nothing, currency = nothing)

  url = join([BASE_STOCK_URL, "bars"], "/")

  params = Dict(
    "symbols" => symbol,
    "timeframe" => timeframe,
    "start" => startTime,
    "end" => endTime,
    "limit" => limit,
    "page_token" => page_token,
    "asof" => asof,
    "adjustment" => adjustment,
    "feed" => feed,
    "currency" => currency
  )

  paramsurl = params_uri(params)

  url = url * "?" * paramsurl
  res = HTTP.get(url, headers = HEADERS[])
  resdict = JSON.parse(String(res.body))
  parse_response(resdict, "bars")
end
#export stock_bars


"""
  stock_bars_latest

Get the latest minute-aggregated price data for a stock.

# Examples
```julia-repl
julia> stock_bars_latest("AAPL")
```

"""
function stock_bars_latest(symbol::AbstractString;
                    feed = nothing, currency = nothing)

  url = join([BASE_STOCK_URL, "bars", "latest"], "/")

  params = Dict(
    "symbols" => symbol,
    "feed" => feed,
    "currency" => currency
  )

  paramsurl = params_uri(params)

  url = url * "?" * paramsurl
  res = HTTP.get(url, headers = HEADERS[])
  resdict = JSON.parse(String(res.body))
  parse_latest_response(resdict, "bars")
end
#export stock_bars_latest
