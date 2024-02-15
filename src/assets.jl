function assets(status=nothing, asset_class="us_equity", 
                 exchange=nothing, attributes=nothing)

  url = join([TRADING_API_URL, "assets"], "/")

  params = Dict(
    "status" => status,
    "asset_class" => asset_class,
    "exchange" => exchange,
    "attributes" => attributes
  )

  paramsurl = params_uri(params)

  url = url * "?" * paramsurl

  res = HTTP.get(url, headers = HEADERS[])
  resdict = JSON.parse(String(res.body))
  vcat(DataFrame.(resdict)...)
end