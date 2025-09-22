using Test, JLD2
using GraphsColoring
using SparseArrays
using Graphs

conflictexamples = load(
    joinpath(pkgdir(GraphsColoring), "test", "assets", "conflictexamples.jld2")
)["conflictsdict"]
@testset "Partitioning" begin
    ms = ["rectangle", "twospheres"]
    Xs = ["rt", "lagrangecxd0", "lagrangec0d1", "bc"]

    for m in ms
        for X in Xs
            elements, conflictindices, conflictids = conflictexamples[(m, X)]
            conflicts = GraphsColoring.ConflictFunctor(conflictindices)
            c = GraphsColoring.PassThroughConflictFunctor(elements, conflicts, conflictids)

            for s in [GraphsColoring.conflictmatrix(c), GraphsColoring.conflictgraph(c)]
                for algorithm in [GraphsColoring.DSATUR(), GraphsColoring.Greedy()]
                    println("coloring with $(typeof(algorithm))")

                    oddzones, evenzones = GraphsColoring.partition(s)

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
                                            GraphsColoring._neighbors(s, ielement)
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
