function format_value(x::DateTime)
  Dates.format(x, dateformat"yyyy-mm-ddTHH:MM:SSZ")
end
function format_value(x::Array{String})
  join(x, ",")
end
format_value(x) = x

function params_uri(params::Dict)
  uri = ""
  for (key, value) in params
    if !isnothing(value)
      value = format_value(value)
      uri *= "$(key)=$(value)&"
    end
  end
  if endswith(uri, "&")
    uri = chop(uri)
  end
  uri
end

function parse_response(res, type)

  if isnothing(res[type])
    return (DataFrame(symbol = res["symbol"]), "")
  end
  dfAll = Array{DataFrame}(undef, length(res[type]))
  for (i, (symbol, data)) in enumerate(res[type])
    df = vcat(DataFrame.(data)...)
    df[!, "symbol"] .= symbol
    #df[!, "timestamp"] = DateTime.(first.(df[!, "t"], 23))
    dfAll[i] = df
  end
  df = vcat(dfAll...)
  (df, res["next_page_token"])
end

function parse_latest_response(res, type)
  if isnothing(res[type])
    return (DataFrame(symbol = res["symbol"]), "")
  end
  dfAll = Array{DataFrame}(undef, length(res[type]))
  for (i, (symbol, data)) in enumerate(res[type])
    df = DataFrame(data)
    df[!, "symbol"] .= symbol
    dfAll[i] = df
  end
  df = vcat(dfAll...)
  df
end

function validate_ccy(symbol::String)
  if !occursin("/", symbol)
    @info "API changed - BTCUSD needs to be BTC/USD now"
    return symbol[1:3] * "/" * symbol[4:end]
  end
end

function validate_ccy(symbol::Array{String})
  validate_ccy.(symbol)
end