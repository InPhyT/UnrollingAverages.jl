```@meta
CurrentModule = UnrollingAverages
```

```@raw html
<div style="width:100%; height:150px;border-width:4px;border-style:solid;padding-top:25px;
        border-color:#000;border-radius:10px;text-align:center;background-color:#B3D8FF;
        color:#000">
    <h3 style="color: black;">Star us on GitHub!</h3>
    <a class="github-button" href="https://github.com/InPhyT/UnrollingAverages.jl" data-icon="octicon-star" data-size="large" data-show-count="true" aria-label="Star InPhyT/UnrollingAverages.jl on GitHub" style="margin:auto">Star</a>
    <script async defer src="https://buttons.github.io/buttons.js"></script>
</div>
```

# UnrollingAverages

```@contents
```

UnrollingAverages is a Julia package aimed at *reversing* (or *unrolling*) moving averages of time series to get the original ones back.

UnrollingAverages currently assumes that the moving average is a [simple moving average](https://en.wikipedia.org/wiki/Moving_average#Simple_moving_average). Further relaxations and extensions may come in the future, see [Future Developments](#Future-Developments) section.

## Installation

Press `]` in the Julia REPL and then

```julia
pkg> add UnrollingAverages
```

## Usage

The package exports a single function called `unroll`: it returns a `Vector` whose elements are the possible original time series.

```@docs
unroll(moving_average::Vector{Float64}, window::Int64; initial_conditions::U = nothing, assert_natural::Bool = false) where { U <: Union{ Tuple{Vararg{Union{Int64,Float64}}},Nothing} }
```

A few remarks:

1. If `isnothing(initial_conditions)`:
   - `if assert_natural`, then an internal [`unroll_iterative`](@ref) method is called, which tries to exactly recover the whole time series, initial conditions included. Enter `?UnrollingAverages.unroll_iterative` in a julia  to read details ;
   - `if !assert_natural`, then an internal [`unroll_linear_approximation`](@ref) method is called. See this [StackExchange post](https://stats.stackexchange.com/a/68002). NB: this is an approximated method, it will generally not return the exact original time series ;
2. If `typeof(initial_conditions) <: Ntuple{window-1, <:Union{Int64,Float64}}`, then an internal [`unroll_recursive`](@ref) method is called, which exactly recovers the time series. Mathematical details about this function are reported in section [How `unroll_recursive` works](@ref), and you may read more by entering `?UnrollingAverages.unroll_recursive`.

## How `unroll_recursive` works

This method is capable of exactly recovering the original time series ``x_{t}`` (with ``t \in \mathbb{N}``), given its moving average ``a_t`` (with window width ``W = n_{-} + n_{+} + 1`` and ``t = 1,...,N−(W−1)``) and initial conditions `initial_conditions` (the latter must be a `NTuple{W-1,Union{Int64,Float64}}`):

```math
a_t = \frac{1}{W}\sum_{j=t-n_-}^{t+n_+}x_j
```

By exploiting the derived recursive relation:

```math
x_{t+n_+ + n_-} = W a_t - \sum\limits_{j=1}^{t+n_-+n_+-1}x_j
```