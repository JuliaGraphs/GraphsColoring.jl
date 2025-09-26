using Test, JLD2
using GraphsColoring
using SparseArrays
using Graphs

conflictexamples = load(
    joinpath(pkgdir(GraphsColoring), "test", "assets", "conflictexamples.jld2")
)["conflictsdict"]
@testset "Greedy Coloring" begin
    algorithm = GraphsColoring.Greedy()

    ms = ["rectangle", "cuboid", "twospheres"]
    Xs = ["rt", "lagrangecxd0", "lagrangec0d1", "bc"]

    for m in ms
        for X in Xs
            elements, conflictindices, conflictids = conflictexamples[(m, X)]
            conflicts = GraphsColoring.ConflictFunctor(conflictindices)
            c = GraphsColoring.PassThroughConflictFunctor(elements, conflicts, conflictids)

            for s in [GraphsColoring.conflictmatrix(c), GraphsColoring.conflictgraph(c)]
                for algorithm in [WorkstreamDSATUR, WorkstreamGreedy]
                    c1 = GraphsColoring.color(s, algorithm, GraphsColoring.GraphsColors())
                    c2 = GraphsColoring.color(s, algorithm, GraphsColoring.GroupedColors())

                    c_converted = convert(typeof(c1), c2)
                    @test GraphsColoring.numcolors(c1) ==
                        GraphsColoring.numcolors(c_converted)
                    @test GraphsColoring.colors(c1) == GraphsColoring.colors(c_converted)
                end
                for storage in
                    [GraphsColoring.GroupedColors(), GraphsColoring.GraphsColors()]
                    @test GraphsColoring.colors(
                        GraphsColoring.color(s; algorithm=algorithm, storage=storage)
                    ) == GraphsColoring.colors(GraphsColoring.color(s, algorithm, storage))

                    println("coloring with $(typeof(algorithm))")

                    colors = GraphsColoring.color(s, algorithm, storage)

                    println("We have $(numcolors(colors)) colors")

                    for color in eachindex(colors)
                        println("in color $color we have $(length(colors[color])) elements")
                        !(colors isa GraphsColoring.GroupedColoring) && continue
                        color == numcolors(colors) && continue
                        @test length(colors[color]) >= length(colors[color + 1])
                    end

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
