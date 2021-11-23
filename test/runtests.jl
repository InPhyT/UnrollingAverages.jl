using UnrollingAverages
using Statistics
using Test


@testset "UnrollingAverages.jl" begin

    # params
    n₋ = 2
    n₊ = 4

    # test series
    for i in 1:10
        original_time_series = [rand(0:9) for i in 1:500];

        averaged_time_series = [mean(original_time_series[(i-n₋):(i+n₊)]) for i in (1+n₋):(length(original_time_series)-n₊)];
        
        # test unroll_recursive
        @test unroll(averaged_time_series, n₋ + n₊ + 1; initial_conditions =  Tuple(original_time_series[1:(n₋+n₊)])  )[1] == original_time_series
        ## test that unroll_recursive errors when initial conditions are of wrong length
        @test_throws ErrorException unroll(averaged_time_series, n₋ + n₊ + 1; initial_conditions =  Tuple(original_time_series[1:(n₋+n₊+5)])  )[1]
        # test that assert_positive_integer has no effects when `initial_conditions` are specified (calls unroll_recursive again)
        @test unroll(averaged_time_series, n₋ + n₊ + 1; initial_conditions =  Tuple(original_time_series[1:(n₋+n₊)]), assert_positive_integer = true  )[1] == original_time_series
        # test unroll_linear_approximation
        @test UnrollingAverages.moving_average(unroll(averaged_time_series, n₋ + n₊ + 1 )[1] , n₋, n₊ ) ≈ averaged_time_series
        # test unroll_iterative
        @test original_time_series ∈ unroll(averaged_time_series, n₋ + n₊ + 1;  assert_positive_integer = true)

        #@time unroll(averaged_time_series, n₋ + n₊ + 1;  assert_positive_integer = true)

        
    
    end

    n₊+n₋

end
