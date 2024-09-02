function create_order_params(;symbol, side, qty=NaN, notional=NaN, time_in_force, type, extended_hours=false, client_order_id="none")
  
  validate_order(side, time_in_force, qty, notional)

  params = Dict("symbol" => symbol,
  "side" => side,
  "time_in_force" => time_in_force,
  "type" => type,
  "extended_hours" => extended_hours)

  if client_order_id != "none"
    params["client_order_id"] = client_order_id
  end 

  if !isnan(qty)
    params["qty"] = qty
  end

  if !isnan(notional)
    params["notional"] = notional
  end 

  return params
end

function submit_order(params)
  url = join([TRADING_API_URL, "orders?"], "/")
  res = HTTP.post(url, body=json(params), headers = HEADERS[])
  JSON.parse(String(res.body))
end

function create_market_order(;symbol, side, qty=NaN, notional=NaN, time_in_force, extended_hours=false, client_order_id="none")
  params = create_order_params(symbol=symbol, side=side, qty=qty, notional=notional, time_in_force = time_in_force, type = "market", 
                             extended_hours=extended_hours, client_order_id=client_order_id)
  submit_order(params)
end 

function create_limit_order(;symbol, side, qty=NaN, notional=NaN, limit_price, time_in_force, extended_hours=false, client_order_id="none")
  params = create_order_params(symbol=symbol, side=side, qty=qty, notional=notional, time_in_force = time_in_force, type = "limit", 
                             extended_hours=extended_hours, client_order_id=client_order_id)
  params["limit_price"] = limit_price
  submit_order(params)
end

function create_stop_order(;symbol, side, qty=NaN, notional=NaN, stop_price, time_in_force, extended_hours=false, client_order_id="none")
  params = create_order_params(symbol=symbol, side=side, qty=qty, notional=notional, time_in_force = time_in_force, type = "stop", 
                             extended_hours=extended_hours, client_order_id=client_order_id)
  params["stop_price"] = stop_price 
  submit_order(params)
end

function create_stop_limit_order(;symbol, side, qty=NaN, notional=NaN, limit_price, stop_price, time_in_force, extended_hours=false, client_order_id="none")
  params = create_order_params(symbol=symbol, side=side, qty=qty, notional=notional, time_in_force = time_in_force, type = "stop_limit", 
                             extended_hours=extended_hours, client_order_id=client_order_id)
  params["stop_price"] = stop_price 
  params["limit_price"] = limit_price
  submit_order(params)
end

function create_trailing_stop_order(;symbol, side, qty=NaN, notional=NaN, trail_price=NaN, trail_percent=NaN, time_in_force, extended_hours=false, client_order_id="none")

  params = create_order_params(symbol=symbol, side=side, qty=qty, notional=notional, time_in_force = time_in_force, type = "stop_limit", 
                             extended_hours=extended_hours, client_order_id=client_order_id)
  validate_size(trail_price, trail_percent)
  if !isnan(trail_price)
    params["trail_price"] = trail_price
  end

  if !isnan(trail_percent)
    params["trail_percent"] = trail_percent
  end 

  submit_order(params)
end

function create_bracket_order()
  #nyi
end

function create_oco_order()
  #nyi
end

function create_oto_order()
  #nyi
end

function get_orders(;symbols=nothing, status=nothing, limit=nothing, after=nothing, until=nothing, direction=nothing, nested=nothing, side=nothing)::DataFrame

  url = join([TRADING_API_URL, "orders"], "/")

  if !all(isnothing.([status, limit, after, until, direction, nested, side, symbols]))
      
      params = Dict(
          "status" => status,
          "limit" => limit,
          "after" => after, 
          "until" => until,
          "direction" => direction, 
          "nested" => nested,
          "side" => side,
          "symbols" => symbols
      )

      paramsurl = params_question_mark_sep(params)
      url = join([url, paramsurl], "?")
  end

  res = HTTP.get(url, headers = HEADERS[])
  resdict = JSON.parse(String(res.body))
  resdf = DataFrame(resdict)
  return resdf
end

function get_orders_by_order_id(order_id::String)::DataFrame

  url = join([TRADING_API_URL, "orders", order_id], "/")

  res = HTTP.get(url, headers = HEADERS[])
  resdict = JSON.parse(String(res.body))
  resdf = DataFrame(resdict)
  return resdf
end

function get_orders_by_client_order_id(client_order_id::String)::DataFrame

  url = join([TRADING_API_URL, "orders:by_client_order_id?client_order_id="], "/") * client_order_id

  res = HTTP.get(url, headers = HEADERS[])
  resdict = JSON.parse(String(res.body))
  resdf = DataFrame(resdict)
  return resdf
end

function cancel_all_orders()::DataFrame
  url = join([TRADING_API_URL, "orders"], "/")
 
  res = HTTP.delete(url, headers = HEADERS[])
  resdict = JSON.parse(String(res.body))
  resdf = DataFrame(resdict)
  return resdf
end

function cancel_order(order_id::String)
  url = join([TRADING_API_URL, "orders", order_id], "/")
  res = HTTP.delete(url, headers = HEADERS[])
  return DataFrame(status = res.status, id=order_id)
end


function replace_an_order(;order_id::String, params::Dict) 

  url = join([TRADING_API_URL, "orders", order_id], "/")

  res = HTTP.patch(url, body=json(params), headers = HEADERS[])
  resdict = JSON.parse(String(res.body))
  resdf = DataFrame(resdict)
  return resdf
end

