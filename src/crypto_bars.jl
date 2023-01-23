"""
  crypto_bars

Get historical aggregated price data for a cryptocurrency. 

`timeframe::String`: 1Min-59min, 1Hour-23Hour

# Examples 
```julia-repl
julia> crypto_bars("BTC/USD", "5min")
```

"""
function crypto_bars(symbol, timeframe::String; exchanges=nothing, startTime=nothing, limit=nothing, page_token=nothing)
  validate_ccy(symbol)
  url = join([BASE_CRYPTO_URL, "bars"], "/")

  params = Dict(
    "symbols" => symbol,
    "timeframe" => timeframe,
    "exchanges" => exchanges,
    "start" => startTime, 
    "limit" => limit, 
    "page_token" => page_token    
  )

  paramsurl = params_uri(params)

  url = url * "?" * paramsurl
  res = HTTP.get(url, headers = HEADERS[]).body |> String |> JSON3.read
  parse_response(res, "bars")
end
export crypto_bars