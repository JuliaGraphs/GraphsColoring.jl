using GraphColoring
using Test
using Aqua

@testset "GraphColoring.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(GraphColoring)
    end
    # Write your tests here.
end
