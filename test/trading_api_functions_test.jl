@testset "Trading API Function Tests" begin

    @testset "account() return size and data structure type" begin
        res = AlpacaMarkets.account()

        @test size(res,2) == 35
        @test isa(res, DataFrame)
    end

    @testset "place_order() - send buy market order - check response" begin
        # test buy orders (buy to cover)

        # place order - market
        place_order_symbol = "AAPL"
        res = AlpacaMarkets.place_order(place_order_symbol; qty="1", notional=nothing, side="buy", type="market", time_in_force="gtc", limit_price=nothing, stop_price=nothing,
        trail_price=nothing, trail_percent=nothing, extended_hours=nothing, client_order_id=nothing, order_class=nothing, take_profit=nothing, stop_loss=nothing)

        resdict = JSON.parse(String(res.body))
        print(resdict)
        post_response_df = DataFrame(resdict)
        print(DataFrame([[names(post_response_df)]; collect.(eachrow(post_response_df))], [:column; Symbol.(axes(post_response_df, 1))]))

        @test size(post_response_df,1) != 0
        @test post_response_df.order_type[1] == "market"

    end

    @testset "place_order() - send buy limit order then query the sent order with get_orders()" begin
        # place order - limit
        place_order_symbol = "TSLA"
        AlpacaMarkets.place_order(place_order_symbol; qty="1", notional=nothing, side="buy", type="limit", time_in_force="gtc", limit_price="156.32", stop_price=nothing,
        trail_price=nothing, trail_percent=nothing, extended_hours=nothing, client_order_id=nothing, order_class=nothing, take_profit=nothing, stop_loss=nothing)

        # enforce small amount of lag let the order send 
        sleep(2)

        # check order is active
        orders_df = AlpacaMarkets.get_orders(nothing, status=nothing, limit=nothing, after=nothing, until=nothing, direction=nothing, nested=nothing, side="buy")

        for i = 1:size(orders_df,1)
            if orders_df.symbol[i] == place_order_symbol && orders_df.side[i] == "buy"
                @test orders_df.symbol[i] == place_order_symbol
            end
        end
    end

    @testset "place_order() - send buy notational market order - check response" begin
        # place order - limit - notational
        place_order_symbol = "GM"
        notional_value = "1000"
        res = AlpacaMarkets.place_order(place_order_symbol; qty=nothing, notional=notional_value, side="buy", type="market", time_in_force="day", limit_price=nothing, stop_price=nothing,
        trail_price=nothing, trail_percent=nothing, extended_hours=nothing, client_order_id=nothing, order_class=nothing, take_profit=nothing, stop_loss=nothing)

        resdict = JSON.parse(String(res.body))
        print(resdict)
        post_response_df = DataFrame(resdict)
        print(DataFrame([[names(post_response_df)]; collect.(eachrow(post_response_df))], [:column; Symbol.(axes(post_response_df, 1))]))

        @test size(post_response_df,1) != 0
        @test post_response_df.order_type[1] == "market"
        @test post_response_df.notional[1] == notional_value
        @test post_response_df.side[1] == "buy"

    end

    # test sell orders (short)

    @testset "place_order() - send sell market order - check response" begin
        # place order - market
        place_order_symbol = "F"
        res = AlpacaMarkets.place_order(place_order_symbol; qty="1", notional=nothing, side="sell", type="market", time_in_force="gtc", limit_price=nothing, stop_price=nothing,
        trail_price=nothing, trail_percent=nothing, extended_hours=nothing, client_order_id=nothing, order_class=nothing, take_profit=nothing, stop_loss=nothing)
        
        resdict = JSON.parse(String(res.body))
        print(resdict)
        post_response_df = DataFrame(resdict)
        print(DataFrame([[names(post_response_df)]; collect.(eachrow(post_response_df))], [:column; Symbol.(axes(post_response_df, 1))]))
        
        @test size(post_response_df,1) != 0
        @test post_response_df.order_type[1] == "market"
        @test post_response_df.side[1] == "sell"

    end

    @testset "place_order() - send sell limit order then query the sent order with get_orders()" begin
        # place order - limit
        place_order_symbol = "DIS"
        AlpacaMarkets.place_order(place_order_symbol; qty="1", notional=nothing, side="sell", type="limit", time_in_force="gtc", limit_price="156.32", stop_price=nothing,
        trail_price=nothing, trail_percent=nothing, extended_hours=nothing, client_order_id=nothing, order_class=nothing, take_profit=nothing, stop_loss=nothing)

        # enforce small amount of lag let the order send 
        sleep(2)

        # check order is active
        orders_df = AlpacaMarkets.get_orders(nothing, status=nothing, limit=nothing, after=nothing, until=nothing, direction=nothing, nested=nothing, side="sell")
        print(orders_df.id)

        for i = 1:size(orders_df,1)
            if orders_df.symbol[i] == place_order_symbol && orders_df.side[i] == "sell"
                @test orders_df.symbol[i] == place_order_symbol
            end
        end
    end

    @testset "place_order() - send buy limit order, query sent order with get_orders(), obtain the specific order with get_orders_by_order_id()" begin
        # place order - limit
        place_order_symbol = "TSLA"
        AlpacaMarkets.place_order(place_order_symbol; qty="1", notional=nothing, side="buy", type="limit", time_in_force="gtc", limit_price="156.32", stop_price=nothing,
        trail_price=nothing, trail_percent=nothing, extended_hours=nothing, client_order_id=nothing, order_class=nothing, take_profit=nothing, stop_loss=nothing)

        # enforce small amount of lag let the order send 
        sleep(2)

        # check order is active
        orders_df = AlpacaMarkets.get_orders(nothing, status=nothing, limit=nothing, after=nothing, until=nothing, direction=nothing, nested=nothing, side="buy")

        order_id = ""
        for i = 1:size(orders_df,1)
            if orders_df.symbol[i] == place_order_symbol && orders_df.side[i] == "buy"
                @test orders_df.symbol[i] == place_order_symbol
                order_id = orders_df.id[i]
            end
        end

        # get the specific order id
        orders_by_id_df = AlpacaMarkets.get_orders_by_order_id(order_id)
        if orders_by_id_df.id[1] == order_id
            @test orders_by_id_df.id[1] == order_id
        end
    end

    @testset "place_order() - send buy limit order, query sent order with get_orders(), update original order attributes with replace_an_order()" begin
        # place order - limit
        place_order_symbol = "MSFT"
        AlpacaMarkets.place_order(place_order_symbol; qty="1", notional=nothing, side="buy", type="limit", time_in_force="gtc", limit_price="156.32", stop_price=nothing,
        trail_price=nothing, trail_percent=nothing, extended_hours=nothing, client_order_id=nothing, order_class=nothing, take_profit=nothing, stop_loss=nothing)

        # enforce small amount of lag let the order send 
        sleep(2)

        # check order is active
        orders_df = AlpacaMarkets.get_orders(nothing, status=nothing, limit=nothing, after=nothing, until=nothing, direction=nothing, nested=nothing, side="buy")

        order_id = ""
        match_symbol = ""
        for i = 1:size(orders_df,1)
            if orders_df.symbol[i] == place_order_symbol && orders_df.side[i] == "buy"
                match_symbol = place_order_symbol
                order_id = orders_df.id[i]
            end
        end

        @test match_symbol == place_order_symbol

        # note if order accepted it can not be changed ie stock when market not open
        replace_order_response_df = AlpacaMarkets.replace_an_order(order_id, qty="2",time_in_force="day")

        # get the specific order id
        @test 0 == (replace_order_response_df.replaces[1] != order_id)

    end

end