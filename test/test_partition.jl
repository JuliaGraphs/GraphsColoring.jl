using CompScienceMeshes
using BEAST
using Test
using GraphColoring
using SparseArrays
using Graphs

@testset "Partitioning" begin
    ms = [
        meshrectangle(1.0, 1.0, 0.1),
        # meshcuboid(1.0, 1.0, 1.0, 0.1),
        # CompScienceMeshes.readmesh(
        #     joinpath(pkgdir(GraphColoring), "test", "assets", "in", "sphere.in")
        # ),
        # CompScienceMeshes.readmesh(
        #     joinpath(pkgdir(GraphColoring), "test", "assets", "in", "multiplerects.in")
        # ),
        CompScienceMeshes.readmesh(
            joinpath(pkgdir(GraphColoring), "test", "assets", "in", "twospheres.in")
        ),
    ]

    for m in ms
        for X in [raviartthomas(m), lagrangecxd0(m), lagrangec0d1(m), buffachristiansen(m)]
            for s in [GraphColoring.conflictmatrix(X), GraphColoring.conflictgraph(X)]
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
