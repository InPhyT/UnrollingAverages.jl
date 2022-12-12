using UnrollingAverages
using Statistics
using Test

@testset "UnrollingAverages.jl" begin
    # Parameters
    n₋ = 2
    n₊ = 4
    # Test time series 
    for i in 1:10
        original_time_series = [rand(0:9) for i in 1:500]
        original_time_series_with_0 = vcat(repeat([0], n₋ + n₊), [rand(0:9) for i in 1:500])
        averaged_time_series = [
            mean(original_time_series[(i - n₋):(i + n₊)]) for
            i in (1 + n₋):(length(original_time_series) - n₊)
        ]
        averaged_time_series_with_0 = [
            mean(original_time_series_with_0[(i - n₋):(i + n₊)]) for
            i in (1 + n₋):(length(original_time_series_with_0) - n₊)
        ]
        # test unroll_recursive
        @test unroll(
            averaged_time_series,
            n₋ + n₊ + 1;
            initial_conditions=Tuple(original_time_series[1:(n₋ + n₊)]),
        )[1] == original_time_series
        # test unroll_recursive error when initial values are not of the correct length
        @test unroll(
            averaged_time_series,
            n₋ + n₊ + 1;
            initial_conditions=Tuple(original_time_series[1:(n₋ + n₊)]),
        )[1] == original_time_series
        # test that unroll_recursive errors when initial conditions are of wrong length
        @test_throws ErrorException unroll(
            averaged_time_series,
            n₋ + n₊ + 1;
            initial_conditions=Tuple(original_time_series[2:(n₋ + n₊)]),
        )[1]
        # test that assert_natural has no effects when `initial_conditions` are specified (calls unroll_recursive again)
        @test unroll(
            averaged_time_series,
            n₋ + n₊ + 1;
            initial_conditions=Tuple(original_time_series[1:(n₋ + n₊)]),
            assert_natural=true,
        )[1] == original_time_series
        # test unroll_linear_approximation
        @test UnrollingAverages.moving_average(
            unroll(averaged_time_series, n₋ + n₊ + 1)[1], n₋, n₊
        ) ≈ averaged_time_series
        # test unroll_iterative
        @test original_time_series ∈
            unroll(averaged_time_series, n₋ + n₊ + 1; assert_natural=true)
        # test unroll_iterative when the movign average has a 0
        @test original_time_series_with_0 ∈
            unroll(averaged_time_series_with_0, n₋ + n₊ + 1; assert_natural=true)
        # test internal `moving_average(time_series::Union{Vector{Float64},Vector{Int64}},window::Int64)`
        @test UnrollingAverages.moving_average(
            unroll(averaged_time_series, n₋ + n₊ + 1)[1], n₋ + n₊ + 1
        ) ≈ averaged_time_series
        #@time unroll(averaged_time_series, n₋ + n₊ + 1;  assert_natural = true)
    end
end
