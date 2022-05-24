# <img src="https://github.com/InPhyT/UnrollingAverages.jl/blob/main/docs/src/assets/logo.png?raw=true" width="50" height="50"> &nbsp; UnrollingAverages.jl 

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://github.com/InPhyT/UnrollingAverages.jl/blob/main/LICENSE)
[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://InPhyT.github.io/UnrollingAverages.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://InPhyT.github.io/UnrollingAverages.jl/dev)
[![Build Status](https://github.com/InPhyT/UnrollingAverages.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/InPhyT/UnrollingAverages.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![codecov](https://codecov.io/gh/InPhyT/UnrollingAverages.jl/branch/main/graph/badge.svg?token=7KMQ2RN9GD)](https://codecov.io/gh/InPhyT/UnrollingAverages.jl)
[![Coverage Status](https://coveralls.io/repos/github/InPhyT/UnrollingAverages.jl/badge.svg)](https://coveralls.io/github/InPhyT/UnrollingAverages.jl)
[![DOI](https://zenodo.org/badge/430885253.svg)](https://zenodo.org/badge/latestdoi/430885253)

UnrollingAverages is a Julia package aimed at *reversing* (or *unrolling*) moving averages of time series to get the original ones back.

UnrollingAverages currently assumes that the moving average is a [simple moving average](https://en.wikipedia.org/wiki/Moving_average#Simple_moving_average). Further relaxations and extensions may come in the future, see [Future Developments](#Future-Developments) section.

## Installation

Press `]` in the Julia REPL and then

```julia
pkg> add UnrollingAverages
```

## Usage

The package exports a single function called `unroll`: it returns a `Vector` whose elements are the possible original time series.

```julia
unroll(moving_average::Vector{Float64}, window::Int64; initial_conditions::U = nothing, assert_natural::Bool = false) where { U <: Union{ Tuple{Vararg{Union{Int64,Float64}}},Nothing} }
```

### Arguments

- `moving_average`: the time series representing the moving average to unroll ;
- `window`: the width of the moving average ;
- `initial_conditions`: the initial values of the original time series to be recovered. It may be a `Tuple` of `window-1` positive integer values, or `nothing` if initial conditions are unknown. Currently it is not possible to specify values in the middle of the time series, this may be a feature to be added in the future ;
- `assert_natural` default boolean argument. If true, the pipeline will try to recover a time series of natural numbers only. More then one acceptable time series (where "acceptable" means that it reproduces `moving_average`) may be found and all will be returned.

A few remarks:

1. If `isnothing(initial_conditions)`:
   - `if assert_natural`, then an internal `unroll_iterative` method is called, which tries to exactly recover the whole time series, initial conditions included. Enter `?UnrollingAverages.unroll_iterative` in a Julia  to read further details;
   - `if !assert_natural`, then an internal `unroll_linear_approximation` method is called. See this [StackExchange post](https://stats.stackexchange.com/a/68002). NB: this is an approximated method, it will generally not return the exact original time series;
2. If `typeof(initial_conditions) <: Ntuple{window-1, <:Union{Int64,Float64}}`, then an internal `unroll_recursive` method is called, which exactly recovers the time series. Mathematical details about this function are reported in the [documentation](https://InPhyT.github.io/UnrollingAverages.jl/stable), and you may read more by entering `?UnrollingAverages.unroll_recursive`.

## Future Developments

- Modify `initial_conditions` argument of `unroll` so that it accepts known values throughout the series ;
- Implement reversing methods for other types of moving averages .

## How to Contribute

If you wish to change or add some functionality, please file an [issue](https://github.com/InPhyT/UnrollingAverages.jl/issues). Some suggestions may be found in the [Future Developments](#Future-Developments) section.

## How to Cite 

If you use this package in your work, please cite this repository using the following metadata: 

```bib
@software{Monticone_Moroni_UnrollingAverages_2021,
         abstract     = {A Julia package to reverse ("unroll") moving averages of time series to get the original ones back.},
         author       = {Monticone, Pietro and Moroni, Claudio},
         doi          = {10.5281/zenodo.5725301},
         institution  = {University of Turin (UniTO)},
         keywords     = {Julia Language, Time Series, Statistics, Data Science, Data Analysis, Reverse Engineering},
         license      = {MIT},
         organization = {Interdisciplinary Physics Team (InPhyT)},
         title        = {UnrollingAverages.jl},
         url          = {https://doi.org/10.5281/zenodo.5725301},
         year         = {2021}
         }
```