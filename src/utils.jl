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

  df = vcat(DataFrame.(res[type])...)
  df[!, "symbol"] .= res["symbol"]
  #df[!, "timestamp"] = DateTime.(first.(df[!, "t"], 23))
  (df, res["next_page_token"])
end