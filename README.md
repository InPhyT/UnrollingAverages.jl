# UnrollingAverages

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://github.com/InPhyT/UnrollingAverages.jl/blob/main/LICENSE)
[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://InPhyT.github.io/UnrollingAverages.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://InPhyT.github.io/UnrollingAverages.jl/dev)
[![Build Status](https://github.com/InPhyT/UnrollingAverages.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/InPhyT/UnrollingAverages.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![codecov](https://codecov.io/gh/InPhyT/UnrollingAverages.jl/branch/main/graph/badge.svg?token=7KMQ2RN9GD)](https://codecov.io/gh/InPhyT/UnrollingAverages.jl)
[![Coverage](https://coveralls.io/repos/github/InPhyT/UnrollingAverages.jl/badge.svg?branch=main)](https://coveralls.io/github/InPhyT/UnrollingAverages.jl?branch=main)

UnrollingAverages.jl is a Julia package devoted to *reversing* (or *unrolling*) moving averages of time series, i.e. getting back the original time series.

UnrollingAverages.jl currently assumes that the moving average is a [simple moving average](https://en.wikipedia.org/wiki/Moving_average#Simple_moving_average). Further relaxations and extensions may come in the future, see [Future improvements](#Future-improvements) section.

Keep reading to zip through all you need to know!

## Installation

In a Julia REPL, enter `] add Unrolling`.

## Documentation and Usage

The package exports one function, `unroll`: it returns a `Vector` whose elements are the possible original time series.

```julia
unroll(moving_average::Vector{Float64}, window::Int64; initial_conditions::U = nothing, assert_positive_integer::Bool = false) where { U <: Union{ Tuple{Vararg{Union{Int64,Float64}}},Nothing} }
```

**Arguments**:

- `moving_average`: the time series representing the moving average to unroll ;
- `window`: the width of the moving average ;
- `initial_conditions`: the initial values of the initial time series to be recovered. It may be a `Tuple` of `window-1` positive integer values, or `nothing` if initial conditions are unknown. Currently it is not possible to specify values in the middle of the time series, this may be a feature to be added in the future ;
- `assert_positive_integer` default boolean argument. If true, the pipeline will try to recover a time series of natural numbers only. More then one acceptable time series (where "acceptable" means that it reproduces `moving_average`) may be found and all will be returned.

A few remarks:

1. If `isnothing(initial_conditions)`:
   - `if assert_positive_integer`, then an internal `unroll_iterative` method is called, which tries to exactly recover the whole time series, initial conditions included. Enter `?UnrollingAverages.unroll_iterative` in a julia  to read details. ;
   - `if !assert_positive_integer`, then an internal `unroll_linear_approximation` method is called. See this [StackExchange post](https://stats.stackexchange.com/a/68002). NB: this is an approximated method, it will generally not return the exact original time series ;
2. If `typeof(initial_conditions) <: Ntuple{window-1, <:Union{Int64,Float64}}`, then an internal `unroll_recursive` method is called, which exactly recovers the time series. Mathematical details about this function are reported in the [docs](), and you may read more by entering `?UnrollingAverages.unroll_recursive`.


## Future improvements

- Modify `initial_conditions` argument of `unroll` so that it accepts known values throughout the series ;
- Implement reversing methods for other types of moving averages .
