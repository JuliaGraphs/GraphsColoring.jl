using CompScienceMeshes
using BEAST
using Test
using GraphColoring
using SparseArrays
using Graphs

@testset "Color zones" begin
    ms = [
        meshrectangle(1.0, 1.0, 0.1),
        meshcuboid(1.0, 1.0, 1.0, 0.1),
        CompScienceMeshes.readmesh(
            joinpath(pkgdir(GraphColoring), "test", "assets", "in", "sphere.in")
        ),
        CompScienceMeshes.readmesh(
            joinpath(pkgdir(GraphColoring), "test", "assets", "in", "multiplerects.in")
        ),
        CompScienceMeshes.readmesh(
            joinpath(pkgdir(GraphColoring), "test", "assets", "in", "twospheres.in")
        ),
    ]

    for m in ms
        for X in [raviartthomas(m), lagrangecxd0(m), lagrangec0d1(m), buffachristiansen(m)]
            for s in [GraphColoring.conflictmatrix(X), GraphColoring.conflictgraph(X)]
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
