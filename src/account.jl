function account()::DataFrame
  url = join([TRADING_API_URL, "account"], "/")
  res = HTTP.get(url, headers = HEADERS[])
  resdf::DataFrame = DataFrame(JSON.parse(String(res.body)))
  return resdf
end
