"""
  crypto_bars

Get historical aggregated price data for a cryptocurrency. 

`timeframe::String`: 1Min-59min, 1Hour-23Hour

# Examples 
```julia-repl
julia> crypto_bars("BTCUSD", "5min")
```

"""
function crypto_bars(symbol::String, timeframe::String; exchanges=nothing, startTime=nothing, limit=nothing, page_token=nothing)
  url = join([BASE_CRYPTO_URL, symbol, "bars"], "/")

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
export crypto_bars