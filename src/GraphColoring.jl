module GraphColoring
using SparseArrays
using DataStructures

"""
    function conflicts
"""
function conflicts end

# requires Graphs.jl to load extension GraphColoringGraphs.jl
"""
    conflictgraph
"""
function conflictgraph end

include("conflicts.jl")
include("greedy.jl")
include("dsatur.jl")
include("color.jl")
include("workstream.jl")

"""
    color(conflicts; algorithm=Workstream(DSATUR()))

Colors the elements in the conflict representation such that elements in the same color do
not have any conflicts.

# Arguments

  - `conflicts`: The conflict representation.
  - `algorithm`: The coloring algorithm to use. Defaults to `Workstream(DSATUR())`.

# Returns

  - A `Vector{Vector{Int}}` where each inner `Vector` represents the elements of one color.
"""
function color(conflicts; algorithm=Workstream(DSATUR()))
    return color(conflicts, algorithm)
end

export color, WorkstreamDSATUR, WorkstreamGreedy, Workstream, DSATUR, Greedy

if !isdefined(Base, :get_extension)
    include("../ext/GraphColoringGraphs.jl")
    include("../ext/GraphColoringBEAST.jl")
end

end # module GraphColoring
