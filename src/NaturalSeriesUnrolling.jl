
"""
    function unroll(
        moving_average::Vector{Float64},
        window::Int64;
        initial_conditions::U=nothing,
        assert_natural::Bool=false,
    ) where {U<:Union{Tuple{Vararg{Union{Int64,Float64}}},Nothing}}

Retrieve original time series (i.e. unroll) from its moving average `moving_average`. 
# Arguments
- `moving_average::Vector{Float64}`: the time series representing the moving average to unroll;
- `window:::Int64`: the width of the moving average;
- `initial_conditions::U = nothing`: the initial values of the original time series to be recovered. It may be a `Tuple` of `window-1` float or integer values, or `nothing` if initial conditions are unknown;
- `assert_natural::Bool = false` default boolean argument. If true, then the pipeline will try to recover a time series of natural numbers only. More then one acceptable time series (where "acceptable" means that it reproduces `moving_average`) may be found and returned.

NB: If ```isnothing(initial_conditions) && !assert_natural``` , then only an approximate method may be used, see this [StackExchange post](https://stats.stackexchange.com/a/68002).
"""
function unroll(
    moving_average::Vector{Float64},
    window::Int64;
    initial_conditions::U=nothing,
    assert_natural::Bool=false,
) where {U<:Union{Tuple{Vararg{Union{Int64,Float64}}},Nothing}}
    reconstructed_time_series = assert_natural ? Vector{Int64}[] : Vector{Float64}[]

    if isnothing(initial_conditions)
        if assert_natural
            reconstructed_time_series = unroll_iterative(moving_average, window)
        else
            push!(
                reconstructed_time_series,
                unroll_linear_approximation(moving_average, window),
            )
        end
    elseif length(initial_conditions) == window - 1
        push!(
            reconstructed_time_series,
            unroll_recursive(moving_average, window, initial_conditions),
        )
    else
        error(
            "`initial_conditions` type must be either Nothing or a NTuple{window-1,Union{Float64,Int64}}",
        )
    end
end

"""
    unroll_iterative(moving_average::Vector{Float64}, window::Int64)

Unroll `moving_average` (interpreting it as a moving average whose window width is `window`), returning the original time series assuming it is composed of only natural numbers.

The methodology is as follows:
1. Consider the minimum of `moving_average`, that we will name `minimum_average`;
2. Produce all possible sets of `n₋ + n₊ + 1` naturals that could have `minimum_average` as mean. This is performed by obtaining all permutations of all the partitions of `minimum_average*(n₋ + n₊ + 1)` via Combinatorics.jl, and we will refer to each of the resulting array as a "possibility". These are organized in an array of iterators `possibilities`;
3. For each for each `possibility` and for each `element` in `moving_average[(minimum_index +1):end]` compute the natural `x` (zero included) to be pushed to `possibility`'s end so that `sum(possibility[(i+1):(i+1 + n₋ + n₊ - 1)]) == minimum_average*(n₋ + n₊ + 1)`. if there is such `x`, push it to the `possibility`'s end and go to the next possibility, else remove the `possibility`. When this loop finishes, perform the same loops backward for each `element in reverse(moving_average[1:(minimum_index - 1)])`, this time pushing the `x`s to the `possibility`'s top. This allows for obtaining the set of all possible time series;
4. Return the remaining possibilities.
"""
function unroll_iterative(moving_average::Vector{Float64}, window::Int64) #  n₋::Int64, n₊::Int64, window = n₋ + n₊ + 1

    # compute linear approximation
    # mean_vec::Vector{Float64} = repeat([1/ window ], window ) #n₋ + n₊ + 1
    # mean_mat::Matrix{Float64} = hcat([pad_left_right(mean_vec, i, length(moving_average) - i - 1) for i in 0:(length(moving_average) - 1)]...)' 
    # linear_approximation::Vector{Float64} = pinv(mean_mat) * moving_average #mean_mat \ moving_average

    # find minimum element of the moving average, and compute the numerator of the such average
    minimum_index::Int64 = argmin(moving_average)
    minimum_window_total_cases::Int64 = round(Int64, moving_average[minimum_index] * window) #n₋ + n₊ + 1
    #println("minimum_window_total_cases = ", minimum_window_total_cases) 

    # if minimum_window_total_cases == 0, set collected_partitions manually since Combinatorics would return an "undefined reference"
    collected_partitions = Vector{Int64}[]
    if minimum_window_total_cases == 0
        collected_partitions = [[0]]
        # Else, compute it using Combinatorics.jl
    else
        collected_partitions = collect(partitions(minimum_window_total_cases))
    end

    # Get all permutations of partitions of such numerator. organize them as the column of a matrix.
    possibilities::Vector{Combinatorics.Permutations{Vector{Int64}}} =
        permutations.([
            pad!(partition, window) for
            partition in collected_partitions if length(partition) <= window
        ])

    # Initialize arrays that will contain the index of the columns (possibilities) to keep (`to_be_kept`) and the new row to be added after each iteration (see for loop below)
    to_be_kept = Set{Vector{Int64}}()

    # Pre-compute the numerators of all the averages
    numerators::Vector{Int64} = round.(Ref(Int64), moving_average .* window)

    #l::Int64 = length(possibilities)
    # loop over possibilities, and store the ones that reproduce the moving average
    for perm_it in possibilities
        # if k%1000 == 0
        #     println("doing $k \\ $l")
        # end
        for possibility in perm_it
            valid::Bool = true
            # go forward
            for (i, numerator) in enumerate(@view(numerators[(minimum_index + 1):end]))
                diff::Int64 =
                    numerator - sum(@view(possibility[(i + 1):(i + 1 + window - 1 - 1)]))
                if diff < 0
                    valid = false
                    break
                else
                    push!(possibility, diff)
                end
            end

            # go backward
            if valid
                for numerator in reverse(@view(numerators[1:(minimum_index - 1)]))
                    diff::Int64 = numerator - sum(@view(possibility[1:(window - 1)]))
                    if diff < 0
                        valid = false
                        break
                    else
                        pushfirst!(possibility, diff)
                    end
                end

                if valid
                    push!(to_be_kept, possibility)
                end
            end
        end
    end
    # println("unroll_rolling_mean_of_natural_series_iterators. Returning...")
    # println("length(to_be_kept) = ", length(to_be_kept))
    # return accepted possibilities
    return collect(to_be_kept)
end

"""
    unroll_linear_approximation(moving_average::Vector{Float64}, window::Int64)

Compute the linear approximation of the time series whose moving average of window `window` is `moving_average`. For details, please refer to https://stats.stackexchange.com/a/68002 .
"""
function unroll_linear_approximation(moving_average::Vector{Float64}, window::Int64)
    # compute linear approximation
    mean_vec::Vector{Float64} = repeat([1 / window], window)
    mean_mat::Matrix{Float64} =
        hcat(
            [
                pad_left_right(mean_vec, i, length(moving_average) - i - 1) for
                i in 0:(length(moving_average) - 1)
            ]...,
        )'
    linear_approximation::Vector{Float64} = pinv(mean_mat) * moving_average # equivalently, mean_mat \ moving_average
    return linear_approximation
end

"""
    unroll_recursive(moving_average::Vector{Float64}, window::Int64 , initial_conditions::Tuple{Vararg{Union{Int64,Float64}}} )

Return the raw time series of which `moving_average` is the moving average, where `moving_average[i]` is the moving average of the `[(i-n₋):(i+n₊)]` slice of the raw time series to be returned. Assume the raw time series is composed of only natural numbers. 

The methodology is as follow:
1. Initialize `deaveraged = collect(initial)` ;
2. for each `i ∈ eachindex(moving_average) `, set `deaveraged[i+window-1] = round(Int64,window*moving_average[i] - sum(@view(deaveraged[i:(i+window-1-1)])))` ;
3. Return `deaveraged` .
"""
function unroll_recursive(
    moving_average::Vector{Float64},
    window::Int64,
    initial_conditions::Tuple{Vararg{Union{Int64,Float64}}},
) #NTuple{n₋+n₊,Int64} n₋::Int64, n₊::Int64
    # check that initial conditions are of the correct size
    if length(initial_conditions) != window - 1
        error("initial_conditions must have length equal to (window-1) = ", window - 1)
    end
    # initialize raw time series using provided `initial_conditions`
    deaveraged::Vector{Union{Int64,Float64}} = collect(initial_conditions)
    # pre-resize `deaveraged` to accomodate all the reconstructed time series elements
    resize!(deaveraged, length(initial_conditions) + length(moving_average))
    # loop over moving_average
    for i in eachindex(moving_average) #in 1:(length(moving_average))
        deaveraged[i + window - 1] = round(
            Int64,
            window * moving_average[i] - sum(@view(deaveraged[i:(i + window - 1 - 1)])),
        )
    end
    # return deaveraged time series
    return deaveraged
end

#######################################

# function unroll_iterative(moving_average::Vector{Float64}, n₋::Int64, n₊::Int64) #  n₋::Int64, n₊::Int64, window = n₋ + n₊ + 1

#     # compute linear approximation
#     mean_vec::Vector{Float64} = repeat([1/(n₋ + n₊ + 1 )], n₋ + n₊ + 1 ) #n₋ + n₊ + 1
#     mean_mat::Matrix{Float64} = hcat([pad_left_right(mean_vec, i, length(moving_average) - i - 1) for i in 0:(length(moving_average) - 1)]...)' 
#     linear_approximation::Vector{Float64} = pinv(mean_mat) * moving_average #mean_mat \ moving_average

#     # find minimum element of the moving average, and compute the numerator of the such average
#     minimum_index::Int64 = argmin(moving_average)
#     minimum_window_total_cases::Int64 = round(Int64,moving_average[minimum_index] * (n₋ + n₊ + 1 ))
#     println("minimum_window_total_cases = ", minimum_window_total_cases) 

#     # compute the numeratir of the frst average
#     # first_window_total_cases::Int64 = round(Int64,moving_average[1] * (n₋ + n₊ + 1 ))
#     # if first_window_total_cases == 0, set collected_partitions manually since Combinatorics would return a "undefined reference"
#     #println("first_window_total_cases  = $first_window_total_cases ")
#     collected_partitions = Int64[]
#     if minimum_window_total_cases == 0
#         collected_partitions = [[0]]
#     # else, compute it using Combinatorics.jl
#     else
#         collected_partitions = collect(partitions(minimum_window_total_cases))
#     end

#     # get all permutations of partitions of such numerator. organize them as the column of a matrix.
#     possibilities::Vector{Combinatorics.Permutations{Vector{Int64}}} = permutations.([pad!(partition, n₋ + n₊ + 1) for partition in collected_partitions if length(partition) <= (n₋ + n₊ + 1) ]) 
#     #for partition in second_collected_partitions if length(partition) <= (n₋ + n₊ + 1) ]) 
#     # initialize arrays that will contain the index of the columns (possibilities) to keep (`to_be_kept`) and the new row to be added after each iteration (see for loop below)
#     to_be_kept = Set{Vector{Int64}}()

#     numerators::Vector{Int64} = round.(Ref(Int64),moving_average .* (n₋ + n₊ + 1))

#     #l::Int64 = length(possibilities)
#     for (k,perm_it) in enumerate(possibilities)
#         # if k%1000 == 0
#         #     println("doing $k \\ $l")
#         # end
#         for possibility in perm_it
#             valid::Bool = true
#             # go forward
#             for (i,numerator) in enumerate(@view(numerators[(minimum_index +1):end])) # enumerate(moving_average[(minimum_index +1):end]) #(n₋ + n₊ + 1)
#                 diff::Int64 =  numerator  - sum( @view(possibility[(i+1):(i+1 + n₋ + n₊ - 1)]) ) # round(Int64,average*(n₋ + n₊ + 1 )) 
#                 if diff < 0
#                     valid = false
#                     break
#                 else
#                     push!(possibility,diff)
#                 end
#             end

#             # go backward
#             if valid
#                 for numerator in reverse(@view(numerators[1:(minimum_index - 1)])) #reverse(moving_average[1:(minimum_index - 1)])
#                 diff::Int64 = numerator - sum( @view(possibility[1:(n₋ + n₊)]) ) # round(Int64,average*(n₋ + n₊ + 1 )) 
#                 if diff < 0
#                     valid = false
#                     break
#                 else
#                     pushfirst!(possibility,diff)
#                 end
#             end

#             if valid
#                 push!(to_be_kept,possibility) #[1:(n₋ + n₊ )] #@view(
#             end

#         end

#         end
#     end

#     println("unroll_rolling_mean_of_natural_series_iterators. Returning...")

#     # end

#     println("length(to_be_kept) = ", length(to_be_kept))
#     # For every initial conditions, which are all slices `possibility[1:(n₋ + n₊)]` for the remaining possibilities, apply `deaverage(moving_average, n₋, n₊, Tuple(possibility[1:(n₋ + n₊ )])  )` and keep the resulting reconstructed raw series iff it contains no negative numbers. Return all possible reconstructed time series, togheter with a linear approximation.
#     #return [pred_poss for pred_poss in deaverage.(Ref(moving_average), Ref(n₋), Ref(n₊), Tuple.(collect(to_be_kept))  ) if all(pred_poss .>= 0)] , linear_approximation
#     return collect(to_be_kept), linear_approximation
# end
###############################################################################
