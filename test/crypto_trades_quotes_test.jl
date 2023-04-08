@testset "Crypto Trades Quotes" begin

  for f in (crypto_trades, crypto_quotes)
    # tests passing on local machine
    @testset "$(f)" begin
      res = f("BTC/USD")
      @test length(res) == 2
      @test isa(res[1], DataFrame)
    end

    @testset "$(f) start date" begin
      res = f("BTC/USD"; startTime = today()-Day(1), endTime = today())
      @test length(res) == 2
      @test isa(res[1], DataFrame)
    end
  end
end
