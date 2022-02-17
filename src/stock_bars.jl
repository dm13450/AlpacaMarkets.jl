"""
  stock_bars

Get historical aggregated price data for a cryptocurrency. 

`timeframe::String`: 1Min-59min, 1Hour-23Hour, 1Day-31Day

# Examples 
```julia-repl
julia> stock_bars("AAPL", "5min")
```

"""
function stock_bars(symbol::String, timeframe::String; exchanges=nothing, startTime=nothing, limit=nothing, page_token=nothing)
  url = join([BASE_STOCK_URL, symbol, "bars"], "/")

  params = Dict(
    "timeframe" => timeframe,
    "exchanges" => exchanges,
    "start" => startTime, 
    "limit" => limit, 
    "page_token" => page_token    
  )

  paramsurl = params_uri(params)

  url = url * "?" * paramsurl
  res = HTTP.get(url, headers = HEADERS[])
  resdict = JSON.parse(String(res.body))
  
  parse_response(resdict, "bars")
end
export stock_bars