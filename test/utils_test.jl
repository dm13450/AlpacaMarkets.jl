@testset "Utils Test" begin

  @testset "Parse Response" begin
    @testset "Empty Response" begin
      resdict =  Dict("next_page_token" => nothing, "symbol" => "AAPL", "trades" => nothing)
      res = AlpacaMarkets.parse_response(resdict, "trades")
      @test res[1] == DataFrame(symbol = "AAPL")
      @test res[2] == ""
    end
  end
  
  @testset "Format Values" begin
    @testset "Format Datetime" begin
      res = AlpacaMarkets.format_value(now())
      @test length(res) == 20
    end
    @testset "Format Array of Strings" begin
      res = AlpacaMarkets.format_value(["a", "b"])
      @test res == "a,b"
      res = AlpacaMarkets.format_value(["a"])
      @test res == "a"
    end
  end

  @testset "Validate Ccy" begin

    @test AlpacaMarkets.validate_ccy("BTCUSD") == "BTC/USD"
  end

  @testset "Validate Orders" begin
    
    @test AlpacaMarkets.validate_tif("ioc")
    #@test !AlpacaMarkets.validate_tif("IOC")

    @test AlpacaMarkets.validate_side("buy")
    #@test !AlpacaMarkets.validate_side("bUy")

    @test AlpacaMarkets.validate_size(10, NaN)
    @test AlpacaMarkets.validate_size(NaN, 10)
    #@test !AlpacaMarkets.validate_size(10, 10)
    #@test !AlpacaMarkets.validate_size(NaN, NaN)
     
  end



end