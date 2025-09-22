using GraphsColoring
using Graphs, PlotlyJS
using Documenter

import GraphsColoring:
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
function GraphsColoring.conflicts(
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
    GraphsColoring.ConflictFunctor(conflictindices),
    Base.OneTo(numfunctions(space))
end

DocMeta.setdocmeta!(GraphsColoring, :DocTestSetup, :(using GraphsColoring); recursive=true)

makedocs(;
    modules=[
        GraphsColoring,
        if isdefined(Base, :get_extension)
            Base.get_extension(GraphsColoring, :GraphsColoringGraphs)
        else
            GraphsColoring.GraphsColoringGraphs
        end,
    ],
    authors="Danijel Jukić <danijel.jukic14@gmail.com> and contributors",
    sitename="GraphsColoring.jl",
    format=Documenter.HTML(;
        prettyurls=true,
        canonical="https://djukic14.github.io/GraphsColoring.jl",
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
    repo="github.com/djukic14/GraphsColoring.jl",
    target="build",
    devbranch="main",
    push_preview=true,
    forcepush=true,
    versions=["stable" => "v^", "dev" => "dev"],
)
