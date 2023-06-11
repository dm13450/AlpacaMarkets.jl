function close_all_positions(cancel_orders::Bool)::DataFrame

  url = join([TRADING_API_URL, "positions?cancel_orders="], "/") * string(cancel_orders)
  
  res = HTTP.delete(url, headers = HEADERS[])
  resdict = JSON.parse(String(res.body))
  resdf = DataFrame(resdict)
  return resdf
end

function close_position(symbol::String; qty=NaN, percentage=NaN)::DataFrame

  validate_size(qty, percentage)

  url = join([TRADING_API_URL, "positions", symbol], "/")
  
  if !isnan(qty)
    url = url * "?qty=" * string(qty)
  end
  if !isnan(percentage)
    url = url * "?percentage=" * string(percentage)
  end

  res = HTTP.delete(url, headers = HEADERS[])
  resdict = JSON.parse(String(res.body))
  resdf = DataFrame(resdict)
  return resdf
end

function get_position(symbol::String)::DataFrame
  url = join([TRADING_API_URL, "positions", symbol], "/")

  res = HTTP.get(url, headers = HEADERS[])
  resdict = JSON.parse(String(res.body))
  resdf = DataFrame(resdict)
  return resdf
end

function get_all_positions()::DataFrame
  url = join([TRADING_API_URL, "positions"], "/")

  res = HTTP.get(url, headers = HEADERS[])
  resdict = JSON.parse(String(res.body))
  resdf = DataFrame(resdict)
  return resdf
end

