function pad!(v::Vector{Int}, n::Int64)
    return push!(v, repeat([0], n - length(v))...)
end

function pad_left_right(v::Vector{Float64}, l::Int64, r::Int64; p::T=0) where {T}
    return vcat(repeat([p], l), v, repeat([p], r))
end

function moving_average(
    time_series::Union{Vector{Float64},Vector{Int64}}, n₋::Int64, n₊::Int64
)
    return [
        mean(time_series[(i - n₋):(i + n₊)]) for i in (1 + n₋):(length(time_series) - n₊)
    ]
end
function moving_average(time_series::Union{Vector{Float64},Vector{Int64}}, window::Int64)
    return moving_average(time_series, 0, window - 1)
end
