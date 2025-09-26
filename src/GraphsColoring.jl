module GraphsColoring
using SparseArrays
using DataStructures

"""
    function conflicts
"""
function conflicts end

# requires Graphs.jl to load extension GraphsColoringGraphs.jl
"""
    conflictgraph
"""
function conflictgraph end

include("storage.jl")
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
function color(conflicts; algorithm=Workstream(DSATUR()), storage=GroupedColors())
    return color(conflicts, algorithm, storage)
end

export numcolors,
    colors, color, WorkstreamDSATUR, WorkstreamGreedy, Workstream, DSATUR, Greedy
export PassThroughConflictFunctor

if !isdefined(Base, :get_extension)
    include("../ext/GraphsColoringGraphs.jl")
end

end # module GraphsColoring
