using Test, JLD2
using GraphsColoring
using SparseArrays
using Graphs

conflictexamples = load(
    joinpath(pkgdir(GraphsColoring), "test", "assets", "conflictexamples.jld2")
)["conflictsdict"]

@testset "DSATUR Coloring" begin
    algorithm = GraphsColoring.DSATUR()

    ms = ["rectangle", "cuboid", "sphere"]
    Xs = ["rt", "lagrangecxd0", "lagrangec0d1", "bc"]

    for m in ms
        for X in Xs
            elements, conflictindices, conflictids = conflictexamples[(m, X)]
            conflicts = GraphsColoring.ConflictFunctor(conflictindices)
            c = GraphsColoring.PassThroughConflictFunctor(elements, conflicts, conflictids)

            for s in [GraphsColoring.conflictmatrix(c), GraphsColoring.conflictgraph(c)]
                @test GraphsColoring.color(s; algorithm=GraphsColoring.DSATUR()) ==
                    GraphsColoring.color(s, GraphsColoring.DSATUR())
                println("coloring with $(typeof(algorithm))")

                colors = GraphsColoring.color(s, algorithm)

                println("We have $(length(colors)) colors")

                for color in eachindex(colors)
                    println("in color $color we have $(length(colors[color])) elements")
                    color == length(colors) && continue
                    @test length(colors[color]) >= length(colors[color + 1])
                end

                for color in eachindex(colors)
                    elements = colors[color]

                    for testelement in elements
                        for trialelement in elements
                            testelement == trialelement && continue
                            @test testelement ∉ GraphsColoring._neighbors(s, trialelement)
                        end
                    end
                end
            end
        end
    end
end
