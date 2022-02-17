@testset "Stock Bars" begin

  res = AlpacaMarkets.stock_bars("AAPL", "1Hour")

  @test length(res) == 2
  @test isa(res[1], DataFrame)

end