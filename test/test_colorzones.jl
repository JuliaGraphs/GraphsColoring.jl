using Test, JLD2
using GraphsColoring
using SparseArrays
using Graphs

conflictexamples = load(
    joinpath(pkgdir(GraphsColoring), "test", "assets", "conflictexamples.jld2")
)["conflictsdict"]
@testset "Color zones" begin
    ms = ["rectangle", "cuboid", "sphere", "multiplerects", "twospheres"]
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

                    for i in eachindex(oddzones)
                        @test sort(vcat(oddzonecolors[i]...)) == sort(collect(oddzones[i]))
                    end

                    for i in eachindex(evenzones)
                        @test sort(vcat(evenzonecolors[i]...)) ==
                            sort(collect(evenzones[i]))
                    end

                    for zonecolors in [oddzonecolors, evenzonecolors]
                        for (i, colors) in enumerate(zonecolors)
                            for elements in colors
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
    end
end
