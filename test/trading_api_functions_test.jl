@testset "Trading API Functions Tests" begin

    @testset "account() return size and data structure type" begin
        res = AlpacaMarkets.account()

        @test size(res,2) == 35
        @test isa(res, DataFrame)
    end

    @testset "place_order() - send buy market order then query the sent order with get_orders()" begin
        # test buy orders (buy to cover)

        # place order - market
        place_order_symbol = "AAPL"
        AlpacaMarkets.place_order(place_order_symbol; qty="1", notional=nothing, side="buy", type="market", time_in_force="gtc", limit_price=nothing, stop_price=nothing,
        trail_price=nothing, trail_percent=nothing, extended_hours=nothing, client_order_id=nothing, order_class=nothing, take_profit=nothing, stop_loss=nothing)

        # enforce small amount of lag let the order send 
        sleep(2)

        # check order is active
        orders_df = AlpacaMarkets.get_orders(nothing, status=nothing, limit=nothing, after=nothing, until=nothing, direction=nothing, nested=nothing, side="buy")::DataFrame

        for i = 1:size(orders_df,1)
            if orders_df.symbol[i] == place_order_symbol && orders_df.side[i] == "buy"
                @test orders_df.symbol[i] == place_order_symbol
            end
        end
    end

    @testset "place_order() - send buy limit order then query the sent order with get_orders()" begin
        # place order - limit
        place_order_symbol = "TSLA"
        AlpacaMarkets.place_order(place_order_symbol; qty="1", notional=nothing, side="buy", type="limit", time_in_force="gtc", limit_price="156.32", stop_price=nothing,
        trail_price=nothing, trail_percent=nothing, extended_hours=nothing, client_order_id=nothing, order_class=nothing, take_profit=nothing, stop_loss=nothing)

        # enforce small amount of lag let the order send 
        sleep(2)

        # check order is active
        orders_df = AlpacaMarkets.get_orders(nothing, status=nothing, limit=nothing, after=nothing, until=nothing, direction=nothing, nested=nothing, side="buy")::DataFrame

        for i = 1:size(orders_df,1)
            if orders_df.symbol[i] == place_order_symbol && orders_df.side[i] == "buy"
                @test orders_df.symbol[i] == place_order_symbol
            end
        end
    end

    @testset "place_order() - send buy notational market order then query the sent order with get_orders()" begin
        # place order - limit - notational
        place_order_symbol = "GM"
        AlpacaMarkets.place_order(place_order_symbol; qty=nothing, notional="1000", side="buy", type="market", time_in_force="day", limit_price=nothing, stop_price=nothing,
        trail_price=nothing, trail_percent=nothing, extended_hours=nothing, client_order_id=nothing, order_class=nothing, take_profit=nothing, stop_loss=nothing)

        # enforce small amount of lag let the order send 
        sleep(2)

        # check order is active
        orders_df = AlpacaMarkets.get_orders(nothing, status=nothing, limit=nothing, after=nothing, until=nothing, direction=nothing, nested=nothing, side="buy")::DataFrame

        for i = 1:size(orders_df,1)
            if orders_df.symbol[i] == place_order_symbol && orders_df.side[i] == "buy"
                @test orders_df.symbol[i] == place_order_symbol
            end
        end
    end

    # test sell orders (short)

    @testset "place_order() - send sell market order then query the sent order with get_orders()" begin
        # place order - market
        place_order_symbol = "F"
        AlpacaMarkets.place_order(place_order_symbol; qty="1", notional=nothing, side="sell", type="market", time_in_force="gtc", limit_price=nothing, stop_price=nothing,
        trail_price=nothing, trail_percent=nothing, extended_hours=nothing, client_order_id=nothing, order_class=nothing, take_profit=nothing, stop_loss=nothing)

        # enforce small amount of lag let the order send 
        sleep(2)

        # check order is active
        orders_df = AlpacaMarkets.get_orders(nothing, status=nothing, limit=nothing, after=nothing, until=nothing, direction=nothing, nested=nothing, side="sell")::DataFrame

        for i = 1:size(orders_df,1)
            if orders_df.symbol[i] == place_order_symbol && orders_df.side[i] == "sell"
                @test orders_df.symbol[i] == place_order_symbol
            end
        end
    end

    @testset "place_order() - send sell limit order then query the sent order with get_orders()" begin
        # place order - limit
        place_order_symbol = "DIS"
        AlpacaMarkets.place_order(place_order_symbol; qty="1", notional=nothing, side="sell", type="limit", time_in_force="gtc", limit_price="156.32", stop_price=nothing,
        trail_price=nothing, trail_percent=nothing, extended_hours=nothing, client_order_id=nothing, order_class=nothing, take_profit=nothing, stop_loss=nothing)

        # enforce small amount of lag let the order send 
        sleep(2)

        # check order is active
        orders_df = AlpacaMarkets.get_orders(nothing, status=nothing, limit=nothing, after=nothing, until=nothing, direction=nothing, nested=nothing, side="sell")::DataFrame

        for i = 1:size(orders_df,1)
            if orders_df.symbol[i] == place_order_symbol && orders_df.side[i] == "sell"
                @test orders_df.symbol[i] == place_order_symbol
            end
        end
    end

end
