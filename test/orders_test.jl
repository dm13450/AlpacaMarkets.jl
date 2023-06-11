@testset "Orders Test" begin 

  @testset "Req fields" begin

    params = AlpacaMarkets.create_order_params(symbol="AAPL", side = "buy", qty = 100, time_in_force = "ioc", type = "market")

    @test params["qty"] == 100
    #@test !(["notional", "client_order_id"] in keys(params))

    params = AlpacaMarkets.create_order_params(symbol="AAPL", side = "buy", notional = 100, time_in_force = "ioc", type = "market")

    @test params["notional"] == 100
    #@test !(["qty", "client_order_id"] in keys(params))
    

  end 

end