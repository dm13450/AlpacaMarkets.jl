module AlpacaMarkets
  using HTTP, JSON
  using DataFrames
  using Dates

  const BASE_CRYPTO_URL = "https://data.alpaca.markets/v1beta2/crypto"
  const NEWS_URL = "https://data.alpaca.markets//v1beta1/news"
  const BASE_STOCK_URL = "https://data.alpaca.markets/v2/stocks"

  const HEADERS = Ref{Vector{Pair{String, String}}}()
  const SLEEP_TIME = Ref{Float64}()

  function __init__()
    auth()
    SLEEP_TIME[] = tryparse(Float64, get(ENV, "ALPACA_SLEEP", "0.301"))
    SLEEP_TIME[] = isnothing(SLEEP_TIME[]) ? 0.301 : SLEEP_TIME[]
  end

  function auth(api_key, api_secret)
    HEADERS[] = ["APCA-API-KEY-ID" => api_key,
                 "APCA-API-SECRET-KEY" => api_secret]
  end

  function auth()
    api_key = get(ENV, "ALPACA_KEY", "")
    api_secret = get(ENV, "ALPACA_SECRET", "")
 
    if api_key == "" 
      @warn "API key details not found, authenticate manuallly with auth()"
      return
    end

    if api_secret == ""
      @warn "API secret details not found, authenticate manuallly with auth()"
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
  include("trading_api_functions.jl")

end # module
