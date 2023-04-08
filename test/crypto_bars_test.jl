@testset "Crypto Bars" begin 

  @testset "Single Ccy" begin
    # unit test passes here
    res = crypto_bars(["BTC/USD"], "1Hour")

    @test length(res) == 2
    @test isa(res[1], DataFrame)
  end

  #=
  review multi-functionality
  note in crypto_bars() ther eis no iterator to process the items in the array 
  maybe individual user can define their own loops for multiple symbols
  @testset "Multi Ccy" begin
    res = crypto_bars(["BTC/USD", "ETH/USD"], "1Hour")
    @test length(res) == 2
    @test isa(res[1], DataFrame)
  end
  =#

end