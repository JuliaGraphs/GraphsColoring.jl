using Test, JLD2
using GraphColoring
using SparseArrays
using Graphs

conflictexamples = load(
    joinpath(pkgdir(GraphColoring), "test", "assets", "conflictexamples.jld2")
)["conflictsdict"]
@testset "Partitioning" begin
    ms = ["rectangle", "twospheres"]
    Xs = ["rt", "lagrangecxd0", "lagrangec0d1", "bc"]

    for m in ms
        for X in Xs
            elements, conflictindices, conflictids = conflictexamples[(m, X)]
            conflicts = GraphColoring.ConflictFunctor(conflictindices)
            c = GraphColoring.PassThroughConflictFunctor(elements, conflicts, conflictids)

            for s in [GraphColoring.conflictmatrix(c), GraphColoring.conflictgraph(c)]
                for algorithm in [GraphColoring.DSATUR(), GraphColoring.Greedy()]
                    println("coloring with $(typeof(algorithm))")

                    oddzones, evenzones = GraphColoring.partition(s)

                    oddelements = Int[]
                    evenelements = Int[]

                    for (i, zone) in enumerate(oddzones)
                        append!(oddelements, collect(zone))
                    end

                    for (i, zone) in enumerate(evenzones)
                        append!(evenelements, collect(zone))
                    end

                    @test unique(oddelements) == oddelements
                    @test unique(evenelements) == evenelements

                    combinations = 0

                    for zones in [oddzones, evenzones]
                        for (i, izone) in enumerate(zones)
                            for (j, jzone) in enumerate(zones)
                                i == j && continue

                                for ielement in izone
                                    for jelement in jzone
                                        combinations += 1
                                        @test jelement ∉
                                            GraphColoring._neighbors(s, ielement)
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
