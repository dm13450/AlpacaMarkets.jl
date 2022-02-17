
@testset "Crypto Bars" begin 

  res = crypto_bars("BTCUSD", "1Hour")

  @test length(res) == 2
  @test isa(res[1], DataFrame)

end