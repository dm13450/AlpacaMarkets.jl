"""
  get_crypto_trades

Get historical trades for a cryptocurrency. 

# Examples 
```julia-repl
julia> get_crypto_trades("BTC/USD", now() - Hour(1), now())
```

"""
function get_crypto_trades(ccy, startTime, endTime; exchanges=nothing)

  trades, token = crypto_trades(ccy; startTime = startTime, endTime = endTime, exchanges = exchanges)

  res = [trades]
  while !(isnothing(token) || isempty(token))
    newtrades, token = crypto_trades(ccy; startTime = startTime, endTime = endTime, exchanges = exchanges, page_token = token)
    append!(res, [newtrades])
    sleep(SLEEP_TIME[])
  end
  vcat(res...)
end
export get_crypto_trades