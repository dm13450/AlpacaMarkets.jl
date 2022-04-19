
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