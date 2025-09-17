using CompScienceMeshes
using Test, JLD2
using GraphColoring
using SparseArrays
using Graphs

conflictexamples = load(
    joinpath(pkgdir(GraphColoring), "test", "assets", "conflictexamples.jld2")
)["conflictsdict"]
@testset "Greedy Coloring" begin
    algorithm = GraphColoring.Greedy()

    ms = ["rectangle", "cuboid", "twospheres"]
    Xs = ["rt", "lagrangecxd0", "lagrangec0d1", "bc"]

    for m in ms
        for X in Xs
            elements, conflictindices, conflictids = conflictexamples[(m, X)]
            conflicts = GraphColoring.ConflictFunctor(conflictindices)
            c = GraphColoring.PassThroughConflictFunctor(elements, conflicts, conflictids)

            for s in [GraphColoring.conflictmatrix(c), GraphColoring.conflictgraph(c)]
                @test GraphColoring.color(s; algorithm=GraphColoring.Greedy()) ==
                    GraphColoring.color(s, GraphColoring.Greedy())

                println("coloring with $(typeof(algorithm))")

                colors = GraphColoring.color(s, algorithm)

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
                            @test testelement ∉ GraphColoring._neighbors(s, trialelement)
                        end
                    end
                end
            end
        end
    end
end
