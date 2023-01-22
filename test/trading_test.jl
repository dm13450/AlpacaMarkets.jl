@testset "Trading" begin
    @test_throws "Only one of qty or notional permitted" submit_order("AAPL","buy", "market", "gtc", 1, 1000)
    @test_throws "Only one of qty or notional permitted" submit_order("AAPL","buy", "market", "gtc", nothing, nothing)

    resp = submit_order("AAPL", "buy", "market", "gtc", 1)
    @test resp["order_type"] == "market"

    

end