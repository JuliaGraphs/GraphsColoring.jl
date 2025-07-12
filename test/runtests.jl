using Test, TestItems, TestItemRunner

@testitem "Partition" begin
    include("test_partition.jl")
end

@testitem "Greedy color" begin
    include("test_greedy.jl")
end
@testitem "DSATUR color" begin
    include("test_dsatur.jl")
end

@testitem "Color zones" begin
    include("test_colorzones.jl")
end

@testitem "Gather" begin
    include("test_gather.jl")
end

@testitem "Workstream" begin
    include("test_workstream.jl")
end

@testitem "Code quality (Aqua.jl)" begin
    using Aqua
    using GraphColoring
    Aqua.test_all(GraphColoring)
end

@testitem "Code formatting (JuliaFormatter.jl)" begin
    using JuliaFormatter
    using GraphColoring
    @test JuliaFormatter.format(pkgdir(GraphColoring), overwrite=false)
end

@run_package_tests verbose = true
