using AlpacaMarkets
using Test

using DataFrames, Dates

@testset "AlpacaMarkets" begin
  include("utils_test.jl")
  include("stock_trades_quotes_test.jl")
  include("crypto_trades_quotes_test.jl")
  include("crypto_bars_test.jl")
  include("stock_bars_test.jl")
  include("trading_test.jl")
end