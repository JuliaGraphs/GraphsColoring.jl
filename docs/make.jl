using GraphColoring
using Graphs, PlotlyJS
using Documenter

import GraphColoring:
    node,
    partition,
    gather,
    color,
    colorzones,
    _neighbors,
    _numelements,
    noconflicts,
    conflicts,
    ConflictFunctor

# this will be moved to BEAST as soon as the pull request is ready
using BEAST
function GraphColoring.conflicts(
    space::BEAST.Space;
    addata=BEAST.assemblydata(space),
    refspace=BEAST.refspace(space),
    kwargs...,
)
    elements, ad, _ = addata

    conflictindices = Vector{Int}[Int[] for _ in eachindex(elements)]

    reference = BEAST.domain(BEAST.chart(geometry(space), first(geometry(space))))

    for elementid in eachindex(elements)
        for i in 1:numfunctions(refspace, reference)
            for (functionid, _) in ad[elementid, i]
                push!(conflictindices[elementid], functionid)
            end
        end
    end
    return eachindex(elements),
    GraphColoring.ConflictFunctor(conflictindices),
    Base.OneTo(numfunctions(space))
end

DocMeta.setdocmeta!(GraphColoring, :DocTestSetup, :(using GraphColoring); recursive=true)

makedocs(;
    modules=[
        GraphColoring,
        if isdefined(Base, :get_extension)
            Base.get_extension(GraphColoring, :GraphColoringGraphs)
        else
            GraphColoring.GraphColoringGraphs
        end,
    ],
    authors="Danijel Jukić <danijel.jukic14@gmail.com> and contributors",
    sitename="GraphColoring.jl",
    format=Documenter.HTML(;
        prettyurls=true,
        canonical="https://djukic14.github.io/GraphColoring.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Conflicts" => "conflicts.md",
        "Coloring" => [
            "Greedy" => "greedy.md",
            "DSatur" => "dsatur.md",
            "Workstream" => "workstream.md",
        ],
        "Contributing" => "contributing.md",
        "API Reference" => "apiref.md",
    ],
)

deploydocs(;
    repo="github.com/djukic14/GraphColoring.jl",
    target="build",
    devbranch="main",
    push_preview=true,
    forcepush=true,
    versions=["stable" => "v^", "dev" => "dev"],
)
