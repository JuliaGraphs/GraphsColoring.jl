using Test, JLD2
using GraphColoring
using SparseArrays
using Graphs

conflictexamples = load(
    joinpath(pkgdir(GraphColoring), "test", "assets", "conflictexamples.jld2")
)["conflictsdict"]

@testset "Gather" begin
    ms = ["rectangle", "cuboid"]
    Xs = ["rt", "lagrangecxd0", "lagrangec0d1", "bc"]

    for m in ms
        for X in Xs
            elements, conflictindices, conflictids = conflictexamples[(m, X)]
            conflicts = GraphColoring.ConflictFunctor(conflictindices)
            c = GraphColoring.PassThroughConflictFunctor(elements, conflicts, conflictids)

            for s in [GraphColoring.conflictmatrix(c), GraphColoring.conflictgraph(c)]
                oddzones, evenzones = GraphColoring.partition(s)

                for algorithm in [GraphColoring.DSATUR(), GraphColoring.Greedy()]
                    println("coloring with $(typeof(algorithm))")

                    oddzonecolors = GraphColoring.colorzones(s, oddzones, algorithm)
                    evenzonecolors = GraphColoring.colorzones(s, evenzones, algorithm)

                    colors = GraphColoring.gather(oddzonecolors, evenzonecolors)

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
                                    GraphColoring._neighbors(s, trialelement)
                            end
                        end
                    end
                end
            end
        end
    end
end
