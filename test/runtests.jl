using AlpacaMarkets
using Test
using HTTP
using JSON
using DataFrames
using Dates

@testset "AlpacaMarkets" begin
  include("utils_test.jl")
  include("stock_trades_quotes_test.jl")
  include("crypto_trades_quotes_test.jl")
  include("crypto_bars_test.jl")
  include("stock_bars_test.jl")
  include("orders_test.jl")
  include("account_test.jl")
  include("assets_test.jl")
  include("screener_test.jl")
end