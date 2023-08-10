@testset "Crypto Trades Quotes" begin

  @testset "crypto_trades()" begin
    res = AlpacaMarkets.crypto_trades("BTC/USD")
    @test length(res) == 2
    @test isa(res[1], DataFrame)
  end
  #@testset "crypto_quotes()" begin
  #  res = AlpacaMarkets.crypto_quotes("BTC/USD")
  #  @test length(res) == 2
  #  @test isa(res[1], DataFrame)
  #end

  @testset "crypto_trades() start date" begin
    res = AlpacaMarkets.crypto_trades("BTC/USD"; startTime = today()-Day(1), endTime = today())
    @test length(res) == 2
    @test isa(res[1], DataFrame)
  end
  #@testset "crypto_quotes() start date" begin
  #  res = AlpacaMarkets.crypto_quotes("BTC/USD"; startTime = today()-Day(1), endTime = today())
  #  @test length(res) == 2
  #  @test isa(res[1], DataFrame)
  #end

end
