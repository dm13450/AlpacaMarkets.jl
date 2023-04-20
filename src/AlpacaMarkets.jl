module AlpacaMarkets
  using HTTP, JSON
  using DataFrames
  using Dates

  const BASE_CRYPTO_URL = "https://data.alpaca.markets/v1beta2/crypto"
  const NEWS_URL = "https://data.alpaca.markets//v1beta1/news"
  const BASE_STOCK_URL = "https://data.alpaca.markets/v2/stocks"

  const HEADERS = Ref{Vector{Pair{String, String}}}()
  const SLEEP_TIME = Ref{Float64}()

  # added auth_startup() 
  # non clashing function name
  # this will first check for ENV keys else revert to user input
  function __init__()
    auth_startup()
    SLEEP_TIME[] = tryparse(Float64, get(ENV, "ALPACA_SLEEP", "0.301"))
    SLEEP_TIME[] = isnothing(SLEEP_TIME[]) ? 0.301 : SLEEP_TIME[]
  end


  # main function for setting keys 
  # inputs 
  # api_key :: is taken from ENV or user input 
  # api_secret :: is taken from ENV or user input
  function auth(api_key, api_secret)
    HEADERS[] = ["APCA-API-KEY-ID" => api_key,
                 "APCA-API-SECRET-KEY" => api_secret]
  end

  # set to run on start up 
  # will check ENV for keys else revert to user input
  function auth_startup()
    api_key_env = get(ENV, "ALPACA_KEY", "")
    api_secret_env = get(ENV, "ALPACA_SECRET", "")
 
    if api_key_env == "" 
      @warn "API key details not found, authenticate manuallly with auth() \n"
    end

    if api_secret_env == ""
      @warn "API secret details not found, authenticate manuallly with auth() \n"
    end
  
  # added a condition to either take the keys that are set in the ENV else revert 
  # to the user keys that the user places in variables/input into the function
    if api_key_env != "" || api_secret_env != ""
      print("ENV key is set begin auth() \n")
      auth(api_key_env, api_secret_env)
    elseif api_key_env == "" || api_secret_env == ""
      print("Authenticate manually - ENV key is not set \n")
      auth(api_key, api_secret)
    end

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
