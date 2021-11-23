```@meta
CurrentModule = UnrollingAverages
```

# UnrollingAverages

Documentation for [UnrollingAverages](https://github.com/InPhyT/UnrollingAverages.jl).

```@contents
```

Unrolling.jl is a Julia package devoted to *reversing* (or *unrolling*) moving averages of time series, i.e. getting back the original time series.

Unrolling.jl currently assumes that the moving average is a [simple moving average](https://en.wikipedia.org/wiki/Moving_average#Simple_moving_average). Further relaxations and extensions may come in the future, see [Future improvements](#Future-improvements) section.

Keep reading to zip through all you need to know!

## Installation

In a Julia REPL, enter `] add Unrolling`.

## Documentation and Usage

The package exports one function, `unroll`: it returns a `Vector` whose elements are the possible original time series.

```@docs
unroll(moving_average::Vector{Float64}, window::Int64; initial_conditions::U = nothing, assert_positive_integer::Bool = false) where { U <: Union{ Tuple{Vararg{Union{Int64,Float64}}},Nothing} }
```

A few remarks:

1. If `isnothing(initial_conditions)`:
   - `if assert_positive_integer`, then an internal [`unroll_iterative`](@ref) method is called, which tries to exactly recover the whole time series, initial conditions included. Enter `?Unrolling.unroll_iterative` in a julia  to read details. ;
   - `if !assert_positive_integer`, then an internal [`unroll_linear_approximation`](@ref) method is called. See this [StackExchange post](https://stats.stackexchange.com/a/68002). NB: this is an approximated method, it will generally not return the exact original time series ;
2. If `typeof(initial_conditions) <: Ntuple{window-1, <:Union{Int64,Float64}}`, then an internal [`unroll_recursive`](@ref) method is called, which exactly recovers the time series. Mathematical details about this function are reported in section [Brief explanation of `unroll_recursive` internal](@ref), and you may read more by entering `?Unrolling.unroll_recursive`.

## Brief explanation of `unroll_recursive` internal

This method is capable of exactly recovering the original time series `xᵢ` (with `i = 1,...,N` ) given its moving average `aᵢ` (with with window width `m = n₋ + n₊ + 1` and `i = 1,...,N−(m−1)` )  and initial conditions `initial_conditions` (the latter must be a `NTuple{m-1,Union{Int64,Float64}}`) :

```math
a_i = \frac{1}{m}\sum_{j=i-n_-}^{i+n_+}x_j
```

By exploiting the derived recursive relation:

```math
x_{i+n_+ + n_-} = ma_i - \sum\limits_{j =1}^{i+n_-+n_+-1}x_j
```
