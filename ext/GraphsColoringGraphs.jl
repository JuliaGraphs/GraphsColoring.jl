module GraphsColoringGraphs
using GraphsColoring
using Graphs

import GraphsColoring: conflictgraph, conflictmatrix, _neighbors, _numelements, noconflicts
import GraphsColoring: numcolors, colors

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
    elements, conflicts, conflictids = GraphsColoring.conflicts(X; kwargs...)
    reverseconflicts = GraphsColoring.reverseconflicts(elements, conflicts, conflictids)

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

function numcolors(c::Graphs.Coloring)
    return c.num_colors
end

function colors(c::Graphs.Coloring)
    return c.colors
end

function (::GraphsColoring.GraphsColors)(maxcolor, colors, elements)
    return Graphs.Coloring(maxcolor, colors)
end
function (::GraphsColoring.GraphsColors)(colors)
    numcolors, colors = _groupedcolorstographcoloring(colors)
    return Graphs.Coloring(numcolors, colors)
end

function _groupedcolorstographcoloring(colors)
    newcolors = zeros(eltype(eltype(colors)), sum(length, colors))
    for (i, color) in enumerate(colors)
        newcolors[color] .= i
    end
    return length(colors), newcolors
end

function Base.convert(::Type{<:Graphs.Coloring}, colors::GraphsColoring.GroupedColoring)
    numcolors, colors = _groupedcolorstographcoloring(GraphsColoring.colors(colors))
    return Graphs.Coloring(numcolors, colors)
end

function Base.eachindex(c::Graphs.Coloring)
    return Base.OneTo(numcolors(c))
end

function Base.getindex(c::Graphs.Coloring, color)
    return findall(isequal(color), colors(c))
end

end # module GraphsColoringGraphs
