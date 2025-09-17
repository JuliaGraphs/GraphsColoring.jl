module GraphColoringGraphs
using GraphColoring
using Graphs

import GraphColoring: conflictgraph, conflictmatrix, _neighbors, _numelements, noconflicts

# creates conflict graph as SimpleGraph from Graphs.jl (https://github.com/JuliaGraphs/Graphs.jl)
# from conflictmatrix
# kwargs are passed to conflictmatrix
"""
    function conflictgraph(X; kwargs...)

Creates a conflict graph as a SimpleGraph from [Graphs.jl](https://github.com/JuliaGraphs/Graphs.jl).

# Arguments

  - `X`: An object that supports the `conflictmatrix` function.
  - `kwargs...`: Additional keyword arguments that are passed to the `conflictmatrix` function.

# Returns

A SimpleGraph representing the conflict graph.

This function works by first computing the conflict matrix using the `conflictmatrix` function, and then creating a SimpleGraph from the matrix.
"""
function conflictgraph(X; kwargs...)
    elements, conflicts, conflictids = GraphColoring.conflicts(X; kwargs...)
    reverseconflicts = GraphColoring.reverseconflicts(elements, conflicts, conflictids)

    graph = SimpleGraph(length(elements))

    for elements in reverseconflicts
        for element in elements
            for element2 in elements
                element == element2 && continue
                add_edge!(graph, element, element2)
            end
        end
    end
    return graph
end

"""
    function _neighbors(g::AbstractGraph, element::Int)

Returns the neighbors of a given element, i.e. the elements that have a conflict with the
element, in the `AbstractGraph`, which is used as a conflict representation.

# Arguments

  - `g::AbstractGraph`: The graph.
  - `element::Int`: The element for which to retrieve the neighbors.

# Returns

The neighbors of the given element.
"""
function _neighbors(g::AbstractGraph, element::Int)
    return neighbors(g, element)
end

"""
    function _numelements(g::AbstractGraph)

Returns the number of elements in the graph.

# Arguments

  - `g::AbstractGraph`: The graph.

# Returns

The number of elements in the graph.
"""
function _numelements(g::AbstractGraph)
    return nv(g)
end

"""
    function noconflicts(g::AbstractGraph)

Checks if there are no conflicts in the given graph.

# Arguments

  - `g::AbstractGraph`: The graph to check.

# Returns

`true` if there are no conflicts (i.e., there are no edges in the graph), and `false` otherwise.
"""
function noconflicts(g::AbstractGraph)
    return iszero(ne(g))
end

end # module GraphColoringGraphs
