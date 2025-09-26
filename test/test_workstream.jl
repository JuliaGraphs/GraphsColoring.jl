using Test, JLD2
using GraphsColoring
using SparseArrays
using Graphs

conflictexamples = load(
    joinpath(pkgdir(GraphsColoring), "test", "assets", "conflictexamples.jld2")
)["conflictsdict"]
@testset "Workstream" begin
    ms = ["rectangle", "cuboid"]
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
                    @test GraphsColoring.color(s; storage=storage).colors ==
                        GraphsColoring.color(s, WorkstreamDSATUR, storage).colors

                    for algorithm in [WorkstreamDSATUR, WorkstreamGreedy]
                        println("coloring with $(typeof(algorithm))")

                        colors = GraphsColoring.color(s, algorithm, storage)

                        if colors isa GraphsColoring.GroupedColoring
                            @test sort(vcat(colors.colors...)) ==
                                1:GraphsColoring._numelements(s)

                        elseif colors isa Graphs.Coloring
                            @test length(colors.colors) == GraphsColoring._numelements(s)
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
end
