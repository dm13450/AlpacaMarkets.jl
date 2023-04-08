const BASE_CRYPTO_URL = "https://data.alpaca.markets/v1beta2/crypto"

"""
  crypto_bars

Get historical aggregated price data for a cryptocurrency. 

`timeframe::String`: 1Min-59min, 1Hour-23Hour

# Examples 
```julia-repl
julia> crypto_bars("BTC/USD", "5min")
```

"""
function crypto_bars(symbol::String, timeframe::String; exchanges=nothing, startTime=nothing, limit=nothing, page_token=nothing)
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
  res = HTTP.get(url, headers = HEADERS[])
  resdict = JSON.parse(String(res.body))
  parse_response(resdict, "bars")
end
export crypto_bars