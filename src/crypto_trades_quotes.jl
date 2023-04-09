function get_crypto_data(type, symbol; exchanges=nothing, startTime=nothing, endTime=nothing, limit=nothing, page_token=nothing)
  url = join([BASE_CRYPTO_URL, type], "/")

  params = Dict(
    "symbols" => symbol,
    "start" => startTime,
    "end" => endTime,
    "feed" => exchanges,
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

function crypto_trades(symbol; exchanges=nothing, startTime=nothing, endTime=nothing, limit=nothing, page_token=nothing)

  get_crypto_data("trades", symbol; exchanges=exchanges, startTime=startTime, endTime=endTime, limit=limit, page_token=page_token)
end
#export crypto_trades

function crypto_quotes(symbol; exchanges=nothing, startTime=nothing, endTime=nothing, limit=nothing, page_token=nothing)

  get_crypto_data("quotes", symbol; exchanges=exchanges, startTime=startTime, endTime=endTime, limit=limit, page_token=page_token)
end
#export crypto_quotes