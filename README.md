# Alpaca Markets

A work in progress Julia wrapper for the Alpaca Markets API.

## Overview

Access Alpaca Markets market data API to retrieve stock and crypto market data.

## Installation and Setup

AlpacaMarkets.jl is in the General Registry so you can simply install locally using Pkg.

You need to sign up to AlpacaMarkets to obtain your API keys.
Once you've obtained the key and secret you can authenticate manually with

```julia
using AlpacaMarkets
AlpacaMarkets.auth(KEY, SECRET)
```

Rather than setting it manually each time I recommend you add it to your `.julia/startup.jl` or '.julia/config/startup.jl'

```
ENV["ALPACA_KEY"] = KEY
ENV["ALPACA_SECRET"] = SECRET
```

This is automatically be picked up by AlpacaMarkets.jl each time you start Julia.

## Available Functions

All the historical market data API functions are available:

* `stock_bars`, `stock_quotes` and `stock_trades`
* `stock_quotes_latest` and `stock_trades_latest`
* `crypto_bars`, `crypto_quotes` and `crypto_trades`

Plus the interface to their news API

* `news`

Plus I've added helper functions to obtain data between two periods:

* `get_stock_quotes` and `get_stock_trades`
* `get_crypto_trades`

So you can pull some historical data as and when needed.

## To Do

* Integrate Trading API

## Examples

* Equity Market Data - https://dm13450.github.io/2022/03/22/AlpacaMarkets.jl-More-Free-Data.html
* Crypto Market Data
* News Data
