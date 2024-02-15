function most_active_stocks(;by="volume", top=10)
  url = join([DATA_URL, "screener", "stocks", "most-actives"], "/") 
  params = Dict("by"=>by, "top" => string(top))
  paramsurl = params_uri(params)
  url = url * "?" * paramsurl
  res = HTTP.get(url, headers = HEADERS[])
  resdict = JSON.parse(String(res.body))
  vcat(DataFrame.(resdict["most_actives"])...)
end

function market_movers(market_type, top=10)
  url = join([DATA_URL, "screener", market_type, "movers"], "/") * "?top=" * string(top)
  res = HTTP.get(url, headers = HEADERS[])
  resdict = JSON.parse(String(res.body))
  vcat(DataFrame.(vcat(resdict["gainers"], resdict["losers"]))...)
end