@testset "Orders Test" begin 

  @testset "Req fields" begin

    params = create_req_fields(symbol="AAPL", side = "buy", qty = 100, time_in_force = 100, type = "market")

    @test params["qty"] == 100
    #@test !(["notional", "client_order_id"] in keys(params))

    params = create_red_filed(symbol="AAPL", side = "buy", notional = 100, time_in_force = 100, type = "market")

    @test params["notional"] == 100
    #@test !(["qty", "client_order_id"] in keys(params))
    

  end 

end