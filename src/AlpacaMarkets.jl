module AlpacaMarkets
  using HTTP, JSON
  using DataFrames
  using Dates

  const HEADERS = Ref{Vector{Pair{String, String}}}()

  function __init__()
    auth()
  end

  function auth(api_key, api_secret)
    HEADERS[] = ["APCA-API-KEY-ID" => api_key,
                 "APCA-API-SECRET-KEY" => api_secret
                ]
  end

  function auth()
    api_key = get(ENV, "ALPACA_KEY", "")
    api_secret = get(ENV, "ALPACA_SECRET", "")
    if api_key == "" || api_secret == ""
      @warn "API details not found, authenticate manuallly with auth()"
      return
    end
    auth(api_key, api_secret)
    return
  end

  include("utils.jl")
  include("stocks_trades_quotes.jl")
  include("crypto_trades_quotes.jl")
  include("crypto_bars.jl")
  include("get_crypto_data.jl")
  include("get_stock_data.jl")
  include("stock_exchanges.jl")
  include("news.jl")
  include("stock_bars.jl")

end # module
