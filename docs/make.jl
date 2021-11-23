using UnrollingAverages
using Documenter

DocMeta.setdocmeta!(UnrollingAverages, :DocTestSetup, :(using UnrollingAverages); recursive=true)

makedocs(;
    modules=[UnrollingAverages],
    authors="Pietro Monticone, Claudio Moroni",
    repo="https://github.com/InPhyT/UnrollingAverages.jl/blob/{commit}{path}#{line}",
    sitename="UnrollingAverages.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://InPhyT.github.io/UnrollingAverages.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/InPhyT/UnrollingAverages.jl",
    devbranch="main",
    push_previews = true
)
