
@testset "Crypto Bars" begin 

  @testset "Single Ccy" begin
    res = crypto_bars("BTC/USD", "1Hour")

    @test length(res) == 2
    @test isa(res[1], DataFrame)
  end

  @testset "Multi Ccy" begin
    res = crypto_bars(["BTC/USD", "ETH/USD"], "1Hour")
    @test length(res) == 2
    @test isa(res[1], DataFrame)
  end

end