
const BASE_STOCK_URL = "https://data.alpaca.markets/v2/stocks"

function stock_trades(symbol; startTime=nothing, endTime=nothing, feed=nothing, limit=nothing, page_token=nothing)
  _stock_data("trades", symbol; startTime=startTime, endTime=endTime, feed=feed, limit=limit, page_token=page_token)
end
export stock_trades

function stock_quotes(symbol; startTime=nothing, endTime=nothing, feed=nothing, limit=nothing, page_token=nothing)
  _stock_data("quotes", symbol; startTime=startTime, endTime=endTime, feed=feed, limit=limit, page_token=page_token)
end
export stock_quotes

function _stock_data(type, symbol; startTime=nothing, endTime=nothing, feed=nothing, limit=nothing, page_token=nothing)
  url = join([BASE_STOCK_URL, symbol, type], "/")

  params = Dict(
    "start" => startTime,
    "end" => endTime,
    "feed" => feed,
    "limit" => limit,
    "page_token" => page_token
  )

  paramsuri = params_uri(params)

  if paramsuri != ""
    url = url * "?" * paramsuri
  end

  res = HTTP.get(url, headers = HEADERS[])
  resdict = JSON.parse(String(res.body))
  
  parse_response(resdict, type)
end
