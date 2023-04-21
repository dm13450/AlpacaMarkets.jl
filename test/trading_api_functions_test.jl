@testset "Trading API Function Tests" begin

    @testset "Account" begin

        @testset "account() return size and data structure type" begin
            res = AlpacaMarkets.account()

            @test size(res,2) == 35
            @test isa(res, DataFrame)
        end
    end

    @testset "Orders" begin

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

        @testset "place_order() - specify user input client_order_id, query orders the specified client_order_id with get_orders_by_client_order_id()" begin
            # place order - limit
            place_order_symbol = "GE"
            client_order_id_string = "strategy_two"
            AlpacaMarkets.place_order(place_order_symbol; qty="1", notional=nothing, side="buy", type="limit", time_in_force="day", limit_price="15.32", stop_price=nothing,
            trail_price=nothing, trail_percent=nothing, extended_hours=nothing, client_order_id=client_order_id_string, order_class=nothing, take_profit=nothing, stop_loss=nothing)

            # enforce minor lag let order send (not sure if even need to do this)
            sleep(1)

            # query orders with a specific client_order_id
            client_id_orders_out_df = AlpacaMarkets.get_orders_by_client_order_id(client_order_id_string)
            sleep(1)

            # only unique client_order_id_string values are allowed per API
            # test 1 return
            @test size(client_id_orders_out_df,1) != 0
            @test client_id_orders_out_df.symbol[1] == "GE"
            @test client_id_orders_out_df.client_order_id[1] == "strategy_one"

        end

        @testset "cancel_all_orders() - place multiple orders then cancel them all" begin
            # make an array of ticker symbols
            orders_arr = ["QQQ","SPY","TLT","XLE"]
            for i = 1:size(orders_arr,1)
                place_order_symbol = orders_arr[i]
                # query last trades 
                todays_date = Dates.today()
                last_trades_df = AlpacaMarkets.stock_trades(place_order_symbol; startTime = Date(todays_date), limit = 2)[1]
                sleep(.1)
                limit_price_to_use = last_trades_df.p[1]
                # send the limit orders
                AlpacaMarkets.place_order(place_order_symbol; qty="1", notional=nothing, side="buy", type="limit", time_in_force="day", limit_price=limit_price_to_use, stop_price=nothing,
                trail_price=nothing, trail_percent=nothing, extended_hours=nothing, client_order_id=nothing, order_class=nothing, take_profit=nothing, stop_loss=nothing)
                print("\n")
                print("Sending order ", i, " of ", size(orders_arr,1), "\nTicker = ",place_order_symbol, " :: Limit Price = ", limit_price_to_use)
            end

            # cancel all orders
            sleep(2)
            cancel_all_orders_response_df = AlpacaMarkets.cancel_all_orders()
            sleep(1)

            @test size(cancel_all_orders_response_df,1) != 0
            @test size(cancel_all_orders_response_df,1) == size(orders_arr,1)

        end

        @testset "cancel_order() - place and cancel multiple orders" begin
            AlpacaMarkets.cancel_all_orders()
            # make an array of ticker symbols
            orders_arr = ["QQQ","SPY","TLT","XLE"]
            for i in eachindex(orders_arr)
                place_order_symbol = orders_arr[i]
                # query last trades 
                todays_date = Dates.today()
                last_trades_df = AlpacaMarkets.stock_trades(place_order_symbol; startTime = Date(todays_date), limit = 2)[1]
                sleep(.1)
                limit_price_to_use = last_trades_df.p[1]
                # send the limit orders
                AlpacaMarkets.place_order(place_order_symbol; qty="1", notional=nothing, side="buy", type="limit", time_in_force="day", limit_price=limit_price_to_use, stop_price=nothing,
                trail_price=nothing, trail_percent=nothing, extended_hours=nothing, client_order_id=nothing, order_class=nothing, take_profit=nothing, stop_loss=nothing)
                print("\n")
                print("Sending order ", i, " of ", size(orders_arr,1), "\nTicker = ",place_order_symbol, " :: Limit Price = ", limit_price_to_use)
            end

            # get all the open orders 
            sleep(2)
            orders_df = AlpacaMarkets.get_orders(nothing, status="Open", limit=nothing, after=nothing, until=nothing, direction=nothing, nested=nothing, side="buy")
            sleep(1)

            # cancel all orders, one at a time 
            for i = 1:size(orders_df,1)
                print("\nCancelling order ", i, " of ", size(orders_df,1), "\nTicker symbol ", orders_df.symbol[i], " :: order_id = ", orders_df.id[i])
                # cancel each order by its order_id
                AlpacaMarkets.cancel_order(orders_df.id[i])
                print("\nRemaining orders to cancel ", size(orders_df,1) - i)
                sleep(.3)
            end

            # get all the open orders 
            sleep(2)
            orders_df = AlpacaMarkets.get_orders(nothing, status="Open", limit=nothing, after=nothing, until=nothing, direction=nothing, nested=nothing, side="buy")
            sleep(1)

            # after cancelling orders - df should be 0x0
            @test size(orders_df,2) == 0
            @test size(orders_df,1) == 0

        end

    end

    @testset "Positions" begin

        @testset "get_open_positions() - send multiple market orders - retrieve open positions" begin
            # make an array of ticker symbols
            orders_arr = ["QQQ","SPY","TLT","XLE"]
            for i = 1:size(orders_arr,1)
                place_order_symbol = orders_arr[i]
                # send the market orders
                AlpacaMarkets.place_order(place_order_symbol; qty="1", notional=nothing, side="buy", type="market", time_in_force="day", limit_price=nothing, stop_price=nothing,
                trail_price=nothing, trail_percent=nothing, extended_hours=nothing, client_order_id=nothing, order_class=nothing, take_profit=nothing, stop_loss=nothing)
                print("\n")
                print("Sending order ", i, " of ", size(orders_arr,1), "\nTicker = ",place_order_symbol, " :: Limit Price = ", limit_price_to_use)
                sleep(1)
            end

            sleep(2)
            positions_df = AlpacaMarkets.get_open_positions()
            sleep(1)

            @test size(positions_df,1) != 0

        end

        @testset "get_position() - retrieve open position for a specific symbol" begin
            # send market order
            place_order_symbol = "AAPL"
            AlpacaMarkets.place_order(place_order_symbol; qty="1", notional=nothing, side="buy", type="market", time_in_force="gtc", limit_price=nothing, stop_price=nothing,
            trail_price=nothing, trail_percent=nothing, extended_hours=nothing, client_order_id=nothing, order_class=nothing, take_profit=nothing, stop_loss=nothing)

            # get open position 
            sleep(1)
            one_position_df = AlpacaMarkets.get_position(place_order_symbol)
            sleep(1)

            # after cancelling orders - df should be 0x0
            @test size(one_position_df,1) != 0

        end

        @testset "close_all_positions() - close all open long / short positions" begin
            AlpacaMarkets.cancel_all_orders()
            # send market order
            place_order_symbol = "AAPL"
            AlpacaMarkets.place_order(place_order_symbol; qty="1", notional=nothing, side="buy", type="limit", time_in_force="gtc", limit_price="10.0", stop_price=nothing,
            trail_price=nothing, trail_percent=nothing, extended_hours=nothing, client_order_id=nothing, order_class=nothing, take_profit=nothing, stop_loss=nothing)

            # get open position 
            sleep(1)
            cancel_orders_bool = true
            close_all_open_positions_df = AlpacaMarkets.close_all_positions(cancel_orders_bool)
            #@test size(close_all_open_positions_df,1) != 0

        end

        @testset "close_position() - close open long / short position for a specified symbol" begin
            AlpacaMarkets.cancel_all_orders()
            # send market order
            place_order_symbol = "AAPL"
            AlpacaMarkets.place_order(place_order_symbol; qty="10", notional=nothing, side="buy", type="market", time_in_force="gtc", limit_price=nothing, stop_price=nothing,
            trail_price=nothing, trail_percent=nothing, extended_hours=nothing, client_order_id=nothing, order_class=nothing, take_profit=nothing, stop_loss=nothing)

            # close open position 
            # percentage method
            sleep(1)
            close_open_position_df = AlpacaMarkets.close_position(place_order_symbol; qty=nothing, percentage="50.0")

            @test size(close_open_position_df,1) != 0
            @test close_open_position_df.qty[1] == 5

            # send market order
            place_order_symbol = "AAPL"
            qty_to_buy = "15"
            AlpacaMarkets.place_order(place_order_symbol; qty=qty_to_buy, notional=nothing, side="buy", type="market", time_in_force="gtc", limit_price=nothing, stop_price=nothing,
            trail_price=nothing, trail_percent=nothing, extended_hours=nothing, client_order_id=nothing, order_class=nothing, take_profit=nothing, stop_loss=nothing)
            sleep(1)

            # close open position 
            # qty method
            close_open_position_df = AlpacaMarkets.close_position(place_order_symbol; qty=qty_to_buy, percentage=nothing)
            sleep(1)

            @test size(close_open_position_df,1) != 0
            @test close_open_position_df.qty[1] == parse(Int64, qty_to_buy)
            
        end

    end

end