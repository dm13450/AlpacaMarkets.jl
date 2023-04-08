@testset "Crypto Bars" begin 

  @testset "Single Ccy" begin
    # tests passing on local machine
    res = crypto_bars(["BTC/USD"], "1Hour")

    @test length(res) == 2
    @test isa(res[1], DataFrame)
  end

  #=
  review multi-functionality
  note in crypto_bars() there is no iterator to process the items in the array 
  maybe let it be as single call and users can define their own loops, multiple symbols in their own application
  @testset "Multi Ccy" begin
    res = crypto_bars(["BTC/USD", "ETH/USD"], "1Hour")
    @test length(res) == 2
    @test isa(res[1], DataFrame)
  end
  =#
end