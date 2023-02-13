
function get_stock_data(f, symbol, startTime, endTime; feed=nothing)

  data, token = f(symbol; startTime = startTime, endTime = endTime, feed = feed)

  res = [data]
  while !(isnothing(token) || isempty(token))
    newdata, token = f(symbol; startTime = startTime, endTime = endTime, feed = feed, page_token = token)
    append!(res, [newdata])
    sleep(SLEEP_TIME[])
  end
  vcat(res...)
end

get_stock_quotes(symbol, startTime, endTime, feed=nothing) = get_stock_data(stock_quotes, symbol, startTime, endTime, feed=feed)
get_stock_trades(symbol, startTime, endTime, feed=nothing) = get_stock_data(stock_trades, symbol, startTime, endTime, feed=feed)

export get_stock_quotes, get_stock_trades

function get_stock_data_latest(f, symbol; feed=nothing)
  f(symbol; feed = feed)
end

get_stock_quotes_latest(symbol, feed=nothing) = get_stock_data_latest(stock_quotes_latest, symbol, feed=feed)
get_stock_trades_latest(symbol, feed=nothing) = get_stock_data_latest(stock_trades_latest, symbol, feed=feed)

export get_stock_quotes_latest, get_stock_trades_latest