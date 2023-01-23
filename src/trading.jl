const TRADING_PAPER_URL = "https://paper-api.alpaca.markets"
const TRADING_LIVE_URL = "https://api.alpaca.markets"

"""Creates an order to buy or sell an asset.
Args:
    order_data (alpaca.trading.requests.OrderRequest): The request data for creating a new order.
Returns:
    alpaca.trading.models.Order: The resulting submitted order.
"""
function submit_order(symbol, side, type, time_in_force, qty=nothing, notional=nothing, live=false, kwargs...)
    url = live ? TRADING_LIVE_URL : TRADING_PAPER_URL
    !(isnothing(qty) ⊻ isnothing(notional)) && throw("Only one of qty or notional permitted")
    url = join([url, "v2", "orders"], "/")
    
    params = Dict(
        "symbol" => symbol,
        "qty" => qty,
        "notional" => notional,
        "side" => side,
        "type" => type,
        "time_in_force" => time_in_force
    )
    filter!(p -> !isnothing(p.second), params)
    HTTP.post(url; body=JSON3.write(params), headers = HEADERS[]).body |> String |> JSON3.read
end

export submit_order


"""
Returns all orders. Orders can be filtered by parameters.
Args:
    filter (Optional[GetOrdersRequest]): The parameters to filter the orders with.
Returns:
    List[alpaca.trading.models.Order]: The queried orders.
"""
function get_orders(filter)
end

"""
Returns a specific order by its order id.
Args:
    order_id (Union[UUID, str]): The unique uuid identifier for the order.
    filter (Optional[GetOrderByIdRequest]): The parameters for the query.
Returns:
    alpaca.trading.models.Order: The order that was queried.
"""
function get_order_by_id(order_id, filter)
end


"""
Returns a specific order by its client order id.
Args:
    client_id (str): The client order identifier for the order.
Returns:
    alpaca.trading.models.Order: The queried order.
"""
function get_order_by_client_id(client_id)
end

"""
Updates an order with new parameters.
Args:
    order_id (Union[UUID, str]): The unique uuid identifier for the order being replaced.
    order_data (Optional[ReplaceOrderRequest]): The parameters we wish to update.
Returns:
    alpaca.trading.models.Order: The updated order.
"""
function replace_order_by_id(order_id, order_data)
end


"""
Cancels all orders.
Returns:
    List[CancelOrderResponse]: The list of HTTP statuses for each order attempted to be cancelled.
"""
function cancel_orders()
end

"""
Cancels a specific order by its order id.
Args:
    order_id (Union[UUID, str]): The unique uuid identifier of the order being cancelled.
Returns:
    CancelOrderResponse: The HTTP response from the cancel request.
"""
function cancel_order_by_id(order_id)
end

# ############################## POSITIONS ################################# #

"""
Gets all the current open positions.
Returns:
    List[Position]: List of open positions.
"""
function get_all_positions()
end


"""
Gets the open position for an account for a single asset. Throws an APIError if the position does not exist.
Args:
    symbol_or_asset_id (Union[UUID, str]): The symbol name of asset id of the position to get.
Returns:
    Position: Open position of the asset.
"""
function get_open_position(symbol_or_asset_id)
end


"""
Liquidates all positions for an account.
Places an order for each open position to liquidate.
Args:
    cancel_orders (bool): If true is specified, cancel all open orders before liquidating all positions.
Returns:
    List[ClosePositionResponse]: A list of responses from each closed position containing the status code and
      order id.
"""
function close_all_positions(cancel_orders)
end

"""
Liquidates the position for a single asset.
Places a single order to close the position for the asset.
**This method will throw an error if the position does not exist!**
Args:
    symbol_or_asset_id (Union[UUID, str]): The symbol name of asset id of the position to close.
    close_options: The various close position request parameters.
Returns:
    alpaca.trading.models.Order: The order that was placed to close the position.
"""
function close_position(symbol_or_asset_id, close_options)
end

# ############################## Assets ################################# #

"""
The assets API serves as the master list of assets available for trade and data consumption from Alpaca.
Some assets are not tradable with Alpaca. These assets will be marked with the flag tradable=false.
Args:
    filter (Optional[GetAssetsRequest]): The parameters that can be assets can be queried by.
Returns:
    List[Asset]: The list of assets.
"""
function get_all_assets(filter)
end


"""
Returns a specific asset by its symbol or asset id. If the specified asset does not exist
a 404 error will be thrown.
Args:
    symbol_or_asset_id (Union[UUID, str]): The symbol or asset id for the specified asset
Returns:
    Asset: The asset if it exists.
"""
function get_asset(symbol_or_asset_id)
end

# ############################## CLOCK & CALENDAR ################################# #

"""
Gets the current market timestamp, whether or not the market is currently open, as well as the times
of the next market open and close.
Returns:
    Clock: The market Clock data
"""
function get_clock()
end

"""
The calendar API serves the full list of market days from 1970 to 2029. It can also be queried by specifying a
start and/or end time to narrow down the results.
In addition to the dates, the response also contains the specific open and close times for the market days,
taking into account early closures.
Args:
    filters: Any optional filters to limit the returned market days
Returns:
    List[Calendar]: A list of Calendar objects representing the market days.
"""
function get_calendar(filters)
end


# ############################## ACCOUNT ################################# #

"""
Returns account details. Contains information like buying power,
number of day trades, and account status.
Returns:
    alpaca.trading.models.TradeAccount: The account details
"""
function get_account()
end

"""
Returns account configuration details. Contains information like shorting, margin multiplier
trader confirmation emails, and Pattern Day Trading (PDT) checks.
Returns:
    alpaca.broker.models.AccountConfiguration: The account configuration details
"""
function get_account_configurations()
end

"""
Returns account configuration details. Contains information like shorting, margin multiplier
trader confirmation emails, and Pattern Day Trading (PDT) checks.
Returns:
    alpaca.broker.models.TradeAccountConfiguration: The account configuration details
"""
function set_account_configurations(account_configurations) 
end

