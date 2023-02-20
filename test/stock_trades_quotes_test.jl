
@testset "Stock Trades Quotes" begin

  for f in (stock_trades, stock_quotes)
    @testset "$(f)" begin
      res = f("AAPL"; startTime = Date("2022-11-03"), limit = 2)
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

  for f in (stock_trades_latest, stock_quotes_latest)
    @testset "$(f)" begin
      res = f("AAPL")
      @test isa(res, DataFrame)
    end
  end

  @testset "Pagination" begin

  end

  @testset "Data Parsing" begin


  end

end
