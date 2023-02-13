
const BASE_STOCK_URL = "https://data.alpaca.markets/v2/stocks"

function stock_trades(symbol; startTime=nothing, endTime=nothing,
                              limit=nothing, asof=nothing, feed=nothing,
                              page_token=nothing, currency=nothing)

  _stock_data("trades", symbol; startTime=startTime, endTime=endTime,
                        limit=limit, asof = asof, feed = feed,
                        page_token=page_token, currency = currency)
end
export stock_trades

function stock_trades_latest(symbol; feed = nothing, currency=nothing)
  _stock_data_latest("trades", symbol; feed = feed, currency=currency)
end
export stock_trades_latest

function stock_quotes(symbol; startTime=nothing, endTime=nothing,
                              limit=nothing, asof = nothing, feed = nothing,
                              page_token=nothing, currency=nothing)

  _stock_data("quotes", symbol; startTime=startTime, endTime=endTime,
                        limit=limit, asof = asof, feed = feed,
                        page_token=page_token, currency=currency)
end
export stock_quotes

function stock_quotes_latest(symbol; feed = nothing, currency=nothing)
  _stock_data_latest("quotes", symbol; feed = feed, currency=currency)
end
export stock_quotes_latest

function _stock_data(type, symbol; startTime=nothing, endTime=nothing,
                                   limit=nothing, asof = nothing, feed = nothing,
                                   page_token=nothing, currency=nothing)
  url = join([BASE_STOCK_URL, type], "/")
  params = Dict(
    "symbols" => symbol,
    "start" => startTime,
    "end" => endTime,
    "limit" => limit,
    "asof" => asof,
    "feed" => feed,
    "page_token" => page_token,
    "currency" => currency
  )

  paramsuri = params_uri(params)

  if paramsuri != ""
    url = url * "?" * paramsuri
  end

  res = HTTP.get(url, headers = HEADERS[])
  resdict = JSON.parse(String(res.body))

  parse_response(resdict, type)
end

function _stock_data_latest(type, symbol; feed = nothing, currency=nothing)
  url = join([BASE_STOCK_URL, type, "latest"], "/")
  params = Dict(
    "symbols" => symbol,
    "feed" => feed,
    "currency" => currency
  )

  paramsuri = params_uri(params)

  if paramsuri != ""
    url = url * "?" * paramsuri
  end

  res = HTTP.get(url, headers = HEADERS[])
  resdict = JSON.parse(String(res.body))

  parse_latest_response(resdict, type)
end
