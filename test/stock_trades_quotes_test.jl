
@testset "Stock Trades Quotes" begin

  @testset "trades and quotes" begin
    @testset "stock_trades()" begin
      res = AlpacaMarkets.stock_trades("AAPL"; startTime = Date("2022-11-03"), limit = 2)
      @test length(res) == 2
      @test isa(res[1], DataFrame)

      if hasproperty(res[1], :i)
        # trade results:

        # I assume we get 6 rows as our two rows get expaded for each
        # trade contition: "c":["@","T","I"]
        # If this fails for some reason in future, we can probably just delete this test
        @test nrow(res[1]) == 6

        # expecting 2 unique trade ids
        @test nrow(unique(res[1], :i)) == 2
      else
        # quote results:
        @test nrow(res[1]) == 2
      end
    end

    @testset "stock_quotes()" begin
      res = AlpacaMarkets.stock_quotes("AAPL"; startTime = Date("2022-11-03"), limit = 2)
      @test length(res) == 2
      @test isa(res[1], DataFrame)

      if hasproperty(res[1], :i)
        # trade results:

        # I assume we get 6 rows as our two rows get expaded for each
        # trade contition: "c":["@","T","I"]
        # If this fails for some reason in future, we can probably just delete this test
        @test nrow(res[1]) == 6

        # expecting 2 unique trade ids
        @test nrow(unique(res[1], :i)) == 2
      else
        # quote results:
        @test nrow(res[1]) == 2
      end
    end
  end

  @testset "trades and quotes - latest" begin
    @testset "stock_trades_latest()" begin
      res = AlpacaMarkets.stock_trades_latest("AAPL")
      @test isa(res, DataFrame)
    end

    @testset "stock_quotes_latest()" begin
      res = AlpacaMarkets.stock_quotes_latest("AAPL")
      @test isa(res, DataFrame)
    end
  end


  #@testset "Pagination" begin
  #end

  #@testset "Data Parsing" begin
  #end

end # end