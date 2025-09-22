using Test, JLD2
using GraphsColoring
using SparseArrays
using Graphs

conflictexamples = load(
    joinpath(pkgdir(GraphsColoring), "test", "assets", "conflictexamples.jld2")
)["conflictsdict"]

@testset "Gather" begin
    ms = ["rectangle", "cuboid"]
    Xs = ["rt", "lagrangecxd0", "lagrangec0d1", "bc"]

    for m in ms
        for X in Xs
            elements, conflictindices, conflictids = conflictexamples[(m, X)]
            conflicts = GraphsColoring.ConflictFunctor(conflictindices)
            c = GraphsColoring.PassThroughConflictFunctor(elements, conflicts, conflictids)

            for s in [GraphsColoring.conflictmatrix(c), GraphsColoring.conflictgraph(c)]
                oddzones, evenzones = GraphsColoring.partition(s)

                for algorithm in [GraphsColoring.DSATUR(), GraphsColoring.Greedy()]
                    println("coloring with $(typeof(algorithm))")

                    oddzonecolors = GraphsColoring.colorzones(s, oddzones, algorithm)
                    evenzonecolors = GraphsColoring.colorzones(s, evenzones, algorithm)

                    colors = GraphsColoring.gather(oddzonecolors, evenzonecolors)

                    for color in eachindex(colors)
                        @test unique(colors[color]) == colors[color]

                        println("in color $color we have $(length(colors[color])) elements")
                        color == length(colors) && continue
                        @test length(colors[color]) >= length(colors[color + 1])
                    end

                    # s = s - I
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
