using Test, JLD2
using GraphColoring
using SparseArrays
using Graphs

conflictexamples = load(
    joinpath(pkgdir(GraphColoring), "test", "assets", "conflictexamples.jld2")
)["conflictsdict"]
@testset "Color zones" begin
    ms = ["rectangle", "cuboid", "sphere", "multiplerects", "twospheres"]
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
                                            GraphColoring._neighbors(s, trialelement)
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
