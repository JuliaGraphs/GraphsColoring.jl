using Test, JLD2
using GraphsColoring
using SparseArrays
using Graphs

conflictexamples = load(
    joinpath(pkgdir(GraphsColoring), "test", "assets", "conflictexamples.jld2")
)["conflictsdict"]
@testset "Workstream" begin
    ms = ["rectangle", "cuboid"]
    Xs = ["rt", "lagrangecxd0", "lagrangec0d1", "bc"]

    for m in ms
        for X in Xs
            elements, conflictindices, conflictids = conflictexamples[(m, X)]
            conflicts = GraphsColoring.ConflictFunctor(conflictindices)
            c = GraphsColoring.PassThroughConflictFunctor(elements, conflicts, conflictids)

            for s in [GraphsColoring.conflictmatrix(c), GraphsColoring.conflictgraph(c)]
                @test GraphsColoring.color(s) == GraphsColoring.color(s, WorkstreamDSATUR)

                for algorithm in [WorkstreamDSATUR, WorkstreamGreedy]
                    println("coloring with $(typeof(algorithm))")

                    colors = GraphsColoring.color(s, algorithm)

                    @test sort(vcat(colors...)) == 1:GraphsColoring._numelements(s)
                    for color in eachindex(colors)
                        elements = colors[color]
                        for testelement in elements
                            for trialelement in elements
                                testelement == trialelement && continue
                                @test testelement ∉
                                    GraphsColoring._neighbors(s, trialelement)
                            end
                        end
                    end
                end
            end
        end
    end
end
