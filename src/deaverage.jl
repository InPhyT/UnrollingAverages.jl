# https://stackoverflow.com/questions/52456267/how-to-do-a-reverse-moving-average-in-pandas-rolling-mean-operation-on-pr
# https://stats.stackexchange.com/questions/67907/extract-data-points-from-moving-average
# using Pkg
# cd("./src")
# Pkg.activate(".")
# cd("..")
# using Statistics
# using Combinatorics
# using BenchmarkTools
# using Plots

# using DataFrames, CSV




# production series



"""
    deaverage(averaged::Vector{Float64}, n₋::Int64, n₊::Int64, initial::NTuple{n₋+n₊,Int64} )

Return the raw time series of which `averaged` is the moving average, where averaged[i] is the moving average of the [(i-n₋):(i+n₊)] slice of the raw time series to be returned. Assume the raw time series is composed of only natural numbers. 

The methodology is as follow:
1. Initialize `deaveraged = collect(initial)` ;
2. for each `i in 1:(length(averaged)) `, set `deaveraged[i+n₋+n₊] = round(Int64,(n₋+n₊+1)*averaged[i] - sum(@view(deaveraged[i:(i+n₊+n₋-1)]) ))` ;
3. Return `deaveraged` .

"""
function deaverage(moving_average::Vector{Float64}, n₋::Int64, n₊::Int64, initial_conditions::Tuple{Vararg{Int64}} ) #NTuple{n₋+n₊,Int64}b
    #println("hello")
    # check that initial conditions are of the correct size
    if length(initial_conditions) != n₋+n₊
        error("initial_conditions must have length equal to n₋+n₊ = ", n₋+n₊)
    end
     # initialize raw time series using provided `initial_conditions`
    deaveraged::Vector{Int64} = collect(initial_conditions)
    # pre-resize `deaveraged` to accomodate all the reconstructed time series elements
    resize!(deaveraged, length(initial_conditions) + length(moving_average)  )

    # loop over moving_average
    for i in 1:(length(moving_average))
        deaveraged[i+n₋+n₊] = round(Int64,(n₋+n₊+1)*moving_average[i] - sum(@view(deaveraged[i:(i+n₊+n₋-1)]) ))
        #push!(deaveraged, round(Int64,(n₋+n₊+1)*averaged[i] - sum(@view(deaveraged[i:(i+n₊+n₋-1)]) )) )
    end

    # return deaveraged
    return deaveraged

end















# function get_initial_conditions(averaged::Vector{Float64}, n₋::Int64, n₊::Int64; up_to::Int64 = (n₋ + n₊ + 1))
    

#     first_window_total_cases::Int64 = round(Int64,averaged[1] * (n₋ + n₊ + 1 ))
#     println("first_window_total_cases = $first_window_total_cases")
#     possibilities::Vector{Vector{Int64}} = vcat(unique.(collect.(permutations.([pad!(partition, n₋ + n₊ + 1) for partition in collect(partitions(first_window_total_cases)) if length(partition) <= (n₋ + n₊ + 1) ])))...)
#     println("\n\nlength(possibilities) = ",length(possibilities), " ", unique(length.(possibilities)))
#     println("length(averaged) = ", length(averaged))

#     new_possibilities::Vector{Vector{Int64}} = deepcopy(possibilities)

#     for (i,average) in enumerate(averaged[2:up_to]) #(n₋ + n₊ + 1) #end
#         println("i = $i")
#         expected::Int64 = round(Int64,average*(n₋ + n₊ + 1 ))

#         #println("before deleting")

#         to_be_removed = Set{Int64}()
#         #new_possibilities = Vector{Int64}[]
#         println("length(possibilities) = ", length(possibilities))
#         println("unique(length.(possibilities)) = ", unique(length.(possibilities)))

#         @inbounds for (j,possibility) in enumerate(possibilities)


#             diff::Int64 =  expected - sum( @view(possibility[(i+1):(i+1 + n₋ + n₊ - 1)]) )
#             diff > 0 ? push!(possibility,diff) : push!(to_be_removed,j)   #possibility[ n₋ + n₊ + 1 + i ] = diff



#         end


#         println("before deleting")
#         possibilities = [possibility for (k,possibility) in enumerate(possibilities) if k ∉ to_be_removed]
#         to_be_removed = Set{Int64}()

#     end

#     println("length(possibilities) = ", length(possibilities))
#     println("unique(length.(possibilities)) = ", unique(length.(possibilities)))
 

#     return [possibility for possibility in possibilities],[possibility[1:(n₋ + n₊ )] for possibility in possibilities]  #length(possibility) == (n₋ + n₊ + 1 + n₋ + n₊ ) #[1:(n₋ + n₊ )]


# end














# a = [[1,2],[3,4],[5,6]]
# deleteat!(a, 2)

# push!(a[1],9)


# deaveraged = [ (n₋+n₊+1)*moving_ts[i] - ( sum(moving_ts[(i-n₋):(i-1)]) + sum(moving_ts[(i+1):(i+n₊)]) ) for i in 1:(length(ts)-(n₊ + n₋ +1))]

# p = [unique(collect(permutations(padded_partition))) for padded_partition in pad!.(collect(partitions(8)),Ref(7)) ]



# vcat(unique.(collect.(permutations.( pad!.(collect(partitions(3)),Ref(7)) )))...)

# [ts[(i-n₋):(i+n₊)] for i in (1+n₋):(length(ts)-n₊)]


# p[1]
# function next_combination(combination::Vector{Int64})
    
#     # if combination is like [x,y,y,y,y], return [x-1,y+1,y,y,y]
#     if length(unique(combination[2:end])) == 1
#         return combination .+ vcat(-1, 1, repeat([0], length(combination[3:end])))
#         # else if combination is like [x,y,y,z,z], where z < y,  return [x-1,y+1,y,y,y]
#     else
#         minimum_index::Int64 = 
#     end
# end

# function get_n_naturals_that_sum_to_x(x::Int64,n::Int64)

#     combinations = Vector{Int64}[]
#     combinations[1] = vcat(x,repeat([0],n-1))

#     while combinations[end][1] > 0
#         push!(combinations, next_combination(combinations[end]))
#     end
    
# end

# h!(arr, N) = (for i in 1:N; push!(arr, i); end; arr )

# f!(arr, N) = ( sizehint!(arr, N); for i in 1:N; push!(arr, i); end; arr )

# g!(arr, N) = ( resize!(arr, N); for i in 1:N; arr[i] = i; end; arr )

# f!(Int[], 1_000_000) == g!(Int[], 1_000_000)


# @btime h!(Int[], 1_000_000)

# @btime f!(Int[], 1_000_000) #setup=(arr=Int[])

# @btime g!(Int[], 1_000_000) 