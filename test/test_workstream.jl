using Test, JLD2
using GraphColoring
using SparseArrays
using Graphs

conflictexamples = load(
    joinpath(pkgdir(GraphColoring), "test", "assets", "conflictexamples.jld2")
)["conflictsdict"]
@testset "Workstream" begin
    ms = ["rectangle", "cuboid"]
    Xs = ["rt", "lagrangecxd0", "lagrangec0d1", "bc"]

    for m in ms
        for X in Xs
            elements, conflictindices, conflictids = conflictexamples[(m, X)]
            conflicts = GraphColoring.ConflictFunctor(conflictindices)
            c = GraphColoring.PassThroughConflictFunctor(elements, conflicts, conflictids)

            for s in [GraphColoring.conflictmatrix(c), GraphColoring.conflictgraph(c)]
                @test GraphColoring.color(s) == GraphColoring.color(s, WorkstreamDSATUR)

                for algorithm in [WorkstreamDSATUR, WorkstreamGreedy]
                    println("coloring with $(typeof(algorithm))")

                    colors = GraphColoring.color(s, algorithm)

                    @test sort(vcat(colors...)) == 1:GraphColoring._numelements(s)
                    for color in eachindex(colors)
                        elements = colors[color]
                        for testelement in elements
                            for trialelement in elements
                                testelement == trialelement && continue
                                @test testelement ∉
                                    GraphColoring._neighbors(s, trialelement)
                            end
                        end
                    end
                end
            end
        end
    end
end
