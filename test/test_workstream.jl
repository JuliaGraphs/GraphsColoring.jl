using CompScienceMeshes
using BEAST
using Test
using GraphColoring
using SparseArrays
using Graphs

@testset "Workstream" begin
    ms = [
        meshrectangle(1.0, 1.0, 0.1),
        meshcuboid(1.0, 1.0, 1.0, 0.1),
        # CompScienceMeshes.readmesh(
        #     joinpath(pkgdir(GraphColoring), "test", "assets", "in", "sphere.in")
        # ),
        # CompScienceMeshes.readmesh(
        #     joinpath(pkgdir(GraphColoring), "test", "assets", "in", "multiplerects.in")
        # ),
        # CompScienceMeshes.readmesh(
        #     joinpath(pkgdir(GraphColoring), "test", "assets", "in", "twospheres.in")
        # ),
    ]

    for m in ms
        for X in [raviartthomas(m), lagrangecxd0(m), lagrangec0d1(m), buffachristiansen(m)]
            for s in [GraphColoring.conflictmatrix(X), GraphColoring.conflictgraph(X)]
                @test GraphColoring.color(s) == GraphColoring.color(s, WorkstreamDSATUR)

                for algorithm in [WorkstreamDSATUR, WorkstreamGreedy]
                    println("coloring with $(typeof(algorithm))")

                    colors = GraphColoring.color(s, algorithm)

                    @test sort(vcat(colors...)) == 1:GraphColoring._numelements(s)
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
