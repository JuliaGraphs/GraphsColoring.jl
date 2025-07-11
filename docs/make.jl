using GraphColoring
using Documenter

DocMeta.setdocmeta!(GraphColoring, :DocTestSetup, :(using GraphColoring); recursive=true)

makedocs(;
    modules=[GraphColoring],
    authors="djukic14 <danijel.jukic14@gmail.com> and contributors",
    sitename="GraphColoring.jl",
    format=Documenter.HTML(;
        canonical="https://djukic14.github.io/GraphColoring.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/djukic14/GraphColoring.jl",
    devbranch="main",
)
