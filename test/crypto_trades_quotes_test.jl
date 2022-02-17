@testset "Crypto Trades Quotes" begin

  for f in (crypto_trades, crypto_quotes)

    @testset "$(f)" begin
      res = f("BTCUSD")
      @test length(res) == 2
      @test isa(res[1], DataFrame)
    end

    @testset "$(f) start date" begin
      res = f("BTCUSD"; startTime = today()-Day(1), endTime = today())
      @test length(res) == 2
      @test isa(res[1], DataFrame)
 
    end


  end


end
