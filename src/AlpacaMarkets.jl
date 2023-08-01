module AlpacaMarkets
  using HTTP
  using JSON
  using DataFrames
  using Dates

  const BASE_STOCK_URL = "https://data.alpaca.markets/v2/stocks"
  const BASE_CRYPTO_URL = "https://data.alpaca.markets/v1beta2/crypto"
  const NEWS_URL = "https://data.alpaca.markets//v1beta1/news"

  const HEADERS = Ref{Vector{Pair{String, String}}}()
  const SLEEP_TIME = Ref{Float64}()
  TRADING_API_URL = ""

  function __init__()
    auth()
    SLEEP_TIME[] = tryparse(Float64, get(ENV, "ALPACA_SLEEP", "2.0")) # 0.301
    SLEEP_TIME[] = isnothing(SLEEP_TIME[]) ? 2.0 : SLEEP_TIME[]
    set_trading_env("PAPER")
  end


  function set_trading_env(trading_env::String)
    @assert trading_env == "PAPER" || trading_env == "LIVE" "select_account available arguments :: 'PAPER' or 'LIVE'"

    # set the URL for PAPER or LIVE trading
    if trading_env == "PAPER"
      global TRADING_API_URL = "https://paper-api.alpaca.markets/v2"
    elseif trading_env == "LIVE"
      global TRADING_API_URL = "https://api.alpaca.markets/v2"
    end

  end

  function auth(api_key::String, api_secret::String)
    HEADERS[] = ["APCA-API-KEY-ID" => api_key, "APCA-API-SECRET-KEY" => api_secret]
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
  include("orders.jl")
  include("account.jl")
  include("positions.jl")
  include("announcements.jl")

end # module