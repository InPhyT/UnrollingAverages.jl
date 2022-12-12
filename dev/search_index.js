var documenterSearchIndex = {"docs":
[{"location":"","page":"Home","title":"Home","text":"CurrentModule = UnrollingAverages","category":"page"},{"location":"","page":"Home","title":"Home","text":"<div style=\"width:100%; height:150px;border-width:4px;border-style:solid;padding-top:25px;\n        border-color:#000;border-radius:10px;text-align:center;background-color:#B3D8FF;\n        color:#000\">\n    <h3 style=\"color: black;\">Star us on GitHub!</h3>\n    <a class=\"github-button\" href=\"https://github.com/InPhyT/UnrollingAverages.jl\" data-icon=\"octicon-star\" data-size=\"large\" data-show-count=\"true\" aria-label=\"Star InPhyT/UnrollingAverages.jl on GitHub\" style=\"margin:auto\">Star</a>\n    <script async defer src=\"https://buttons.github.io/buttons.js\"></script>\n</div>","category":"page"},{"location":"#UnrollingAverages","page":"Home","title":"UnrollingAverages","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"UnrollingAverages is a Julia package aimed at reversing (or unrolling) moving averages of time series to get the original ones back.","category":"page"},{"location":"","page":"Home","title":"Home","text":"UnrollingAverages currently assumes that the moving average is a simple moving average. Further relaxations and extensions may come in the future, see Future Developments section.","category":"page"},{"location":"#Installation","page":"Home","title":"Installation","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Press ] in the Julia REPL and then","category":"page"},{"location":"","page":"Home","title":"Home","text":"pkg> add UnrollingAverages","category":"page"},{"location":"#Usage","page":"Home","title":"Usage","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"The package exports a single function called unroll: it returns a Vector whose elements are the possible original time series.","category":"page"},{"location":"","page":"Home","title":"Home","text":"unroll(moving_average::Vector{Float64}, window::Int64; initial_conditions::U = nothing, assert_natural::Bool = false) where { U <: Union{ Tuple{Vararg{Union{Int64,Float64}}},Nothing} }","category":"page"},{"location":"","page":"Home","title":"Home","text":"A few remarks:","category":"page"},{"location":"","page":"Home","title":"Home","text":"If isnothing(initial_conditions):\nif assert_natural, then an internal unroll_iterative method is called, which tries to exactly recover the whole time series, initial conditions included. Enter ?UnrollingAverages.unroll_iterative in a julia  to read details ;\nif !assert_natural, then an internal unroll_linear_approximation method is called. See this StackExchange post. NB: this is an approximated method, it will generally not return the exact original time series ;\nIf typeof(initial_conditions) <: Ntuple{window-1, <:Union{Int64,Float64}}, then an internal unroll_recursive method is called, which exactly recovers the time series. Mathematical details about this function are reported in section How unroll_recursive works, and you may read more by entering ?UnrollingAverages.unroll_recursive.","category":"page"},{"location":"#How-unroll_recursive-works","page":"Home","title":"How unroll_recursive works","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"This method is capable of exactly recovering the original time series x_t (with t in mathbbN), given its moving average a_t (with window width W = n_- + n_+ + 1 and t = 1N(W1)) and initial conditions initial_conditions (the latter must be a NTuple{W-1,Union{Int64,Float64}}):","category":"page"},{"location":"","page":"Home","title":"Home","text":"a_t = frac1Wsum_j=t-n_-^t+n_+x_j","category":"page"},{"location":"","page":"Home","title":"Home","text":"By exploiting the derived recursive relation:","category":"page"},{"location":"","page":"Home","title":"Home","text":"x_t+n_+ + n_- = W a_t - sumlimits_j=1^t+n_-+n_+-1x_j","category":"page"},{"location":"API/#API","page":"API","title":"API","text":"","category":"section"},{"location":"API/","page":"API","title":"API","text":"","category":"page"},{"location":"API/","page":"API","title":"API","text":"Modules = [UnrollingAverages]","category":"page"},{"location":"API/#UnrollingAverages.unroll-Union{Tuple{U}, Tuple{Vector{Float64}, Int64}} where U<:Union{Nothing, Tuple{Vararg{Union{Float64, Int64}}}}","page":"API","title":"UnrollingAverages.unroll","text":"function unroll(\n    moving_average::Vector{Float64},\n    window::Int64;\n    initial_conditions::U=nothing,\n    assert_natural::Bool=false,\n) where {U<:Union{Tuple{Vararg{Union{Int64,Float64}}},Nothing}}\n\nRetrieve original time series (i.e. unroll) from its moving average moving_average. \n\nArguments\n\nmoving_average::Vector{Float64}: the time series representing the moving average to unroll;\nwindow:::Int64: the width of the moving average;\ninitial_conditions::U = nothing: the initial values of the original time series to be recovered. It may be a Tuple of window-1 float or integer values, or nothing if initial conditions are unknown;\nassert_natural::Bool = false default boolean argument. If true, then the pipeline will try to recover a time series of natural numbers only. More then one acceptable time series (where \"acceptable\" means that it reproduces moving_average) may be found and returned.\n\nNB: If isnothing(initial_conditions) && !assert_natural , then only an approximate method may be used, see this StackExchange post.\n\n\n\n\n\n","category":"method"},{"location":"API/#UnrollingAverages.unroll_iterative-Tuple{Vector{Float64}, Int64}","page":"API","title":"UnrollingAverages.unroll_iterative","text":"unroll_iterative(moving_average::Vector{Float64}, window::Int64)\n\nUnroll moving_average (interpreting it as a moving average whose window width is window), returning the original time series assuming it is composed of only natural numbers.\n\nThe methodology is as follows:\n\nConsider the minimum of moving_average, that we will name minimum_average;\nProduce all possible sets of n₋ + n₊ + 1 naturals that could have minimum_average as mean. This is performed by obtaining all permutations of all the partitions of minimum_average*(n₋ + n₊ + 1) via Combinatorics.jl, and we will refer to each of the resulting array as a \"possibility\". These are organized in an array of iterators possibilities;\nFor each for each possibility and for each element in moving_average[(minimum_index +1):end] compute the natural x (zero included) to be pushed to possibility's end so that sum(possibility[(i+1):(i+1 + n₋ + n₊ - 1)]) == minimum_average*(n₋ + n₊ + 1). if there is such x, push it to the possibility's end and go to the next possibility, else remove the possibility. When this loop finishes, perform the same loops backward for each element in reverse(moving_average[1:(minimum_index - 1)]), this time pushing the xs to the possibility's top. This allows for obtaining the set of all possible time series;\nReturn the remaining possibilities.\n\n\n\n\n\n","category":"method"},{"location":"API/#UnrollingAverages.unroll_linear_approximation-Tuple{Vector{Float64}, Int64}","page":"API","title":"UnrollingAverages.unroll_linear_approximation","text":"unroll_linear_approximation(moving_average::Vector{Float64}, window::Int64)\n\nCompute the linear approximation of the time series whose moving average of window window is moving_average. For details, please refer to https://stats.stackexchange.com/a/68002 .\n\n\n\n\n\n","category":"method"},{"location":"API/#UnrollingAverages.unroll_recursive-Tuple{Vector{Float64}, Int64, Tuple{Vararg{Union{Float64, Int64}}}}","page":"API","title":"UnrollingAverages.unroll_recursive","text":"unroll_recursive(moving_average::Vector{Float64}, window::Int64 , initial_conditions::Tuple{Vararg{Union{Int64,Float64}}} )\n\nReturn the raw time series of which moving_average is the moving average, where moving_average[i] is the moving average of the [(i-n₋):(i+n₊)] slice of the raw time series to be returned. Assume the raw time series is composed of only natural numbers. \n\nThe methodology is as follow:\n\nInitialize deaveraged = collect(initial) ;\nfor each i ∈ eachindex(moving_average), set deaveraged[i+window-1] = round(Int64,window*moving_average[i] - sum(@view(deaveraged[i:(i+window-1-1)]))) ;\nReturn deaveraged .\n\n\n\n\n\n","category":"method"}]
}
