@testset "Asset Test" begin 

  assetsRes = AlpacaMarkets.assets()
  @test isa(assetsRes, DataFrame)

end