@testset "Stock Bars" begin

  res = AlpacaMarkets.stock_bars("AAPL", "1Hour"; startTime = Date("2022-11-03"))

  @test length(res) == 2
  @test isa(res[1], DataFrame)



  res = AlpacaMarkets.stock_bars_latest("AAPL")

  @test length(res) == 1
  @test isa(res[1], DataFrame)
end