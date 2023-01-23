"""
  stock_bars

Get historical aggregated price data for a cryptocurrency. 

`timeframe::String`: 1Min-59min, 1Hour-23Hour, 1Day-31Day

# Examples 
```julia-repl
julia> stock_bars("AAPL", "5min")
```

"""
function stock_bars(symbol::String, timeframe::String; 
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
  res = HTTP.get(url, headers = HEADERS[]).body |> String |> JSON3.read
  parse_response(res, "bars")
end
export stock_bars