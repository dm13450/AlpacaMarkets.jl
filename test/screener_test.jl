@testset "Screener Tests" begin

  @testset "Most Active Stocks" begin

    for b in ["volume", "trades"]
      @testset "$b" begin
        res = AlpacaMarkets.most_active_stocks(by=b)
        #@test length(res) == 2
        @test isa(res, DataFrame)
      end
    end

  end

  @testset "Market Movers" begin

    for mt in ["stocks", "crypto"]
      @testset "$mt" begin
        res = AlpacaMarkets.market_movers(mt)
        #@test length(res) == 2
        @test isa(res, DataFrame)
      end
    end
  end

end