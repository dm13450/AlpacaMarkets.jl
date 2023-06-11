function news(symbols::Array{String}, startTime=nothing, endTime=nothing, limit=nothing, sort=nothing, include_content=nothing,exclude_contentless=nothing, page_token=nothing)

  params = Dict(
    "symbols" => symbols,
    "start" => startTime,
    "end" => endTime,
    "sort" => sort,
    "limit" => limit,
    "include_content" => include_content,
    "exclude_contentless" => exclude_contentless,
    "page_token" => page_token
  )

  paramsuri = params_uri(params)

  if paramsuri != ""
    url = NEWS_URL * "?" * paramsuri
  end

  req = HTTP.get(url, headers = HEADERS[])
  JSON.parse(String(req.body))
end