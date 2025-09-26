"""
    GroupedColors

A trait that indicates that a coloring operation should return results as a `GroupedColoring`.
"""
struct GroupedColors end
const GroupedColorConst = GroupedColors()
function (::GroupedColors)(maxcolor, colors, elements)
    colors = Vector{Int}[elements[findall(isequal(color), colors)] for color in 1:maxcolor]
    return GroupedColoring(colors)
end
function (::GroupedColors)(colors)
    return GroupedColoring(colors)
end

"""
    GroupedColors

A trait that indicates that a coloring operation should return results as a `Graphs.Coloring`.
"""
struct GraphsColors end
const GraphColorsConst = GraphsColors()

"""
    GroupedColoring{I}

A data structure that represents a coloring of elements as a vector of vectors, where each
inner vector contains the indices of elements assigned to a particular color.

This representation is optimized for efficiently retrieving all elements belonging to a
specific color group, making it ideal for operations that frequently access elements by color.

# Type Parameters

  - `I`: The integer type used to represent element indices (e.g., `Int`, `Int64`, `UInt32`).

# Fields

  - `colors`: A vector of vectors, where `colors[i]` contains the indices of all elements assigned
    to color `i`. The vector is sorted by group size in descending order (largest groups first)
    for consistency.

# Notes

    The constructor automatically sorts the color groups by size in descending order using `sort!`
    with `by=length, rev=true`.
"""
struct GroupedColoring{I}
    colors::Vector{Vector{I}}
    function GroupedColoring(colors)
        return new{eltype(eltype(colors))}(sort!(colors; by=length, rev=true))
    end
end

"""
    numcolors(c)

Return the number of distinct colors used in the coloring.

# Arguments

  - `c`: A coloring object representing a coloring of a graph or similar structure,
    where elements are grouped by color.

# Returns

  - An integer representing the number of distinct colors used in the coloring.
"""
function numcolors(c::GroupedColoring)
    return length(colors(c))
end

function colors(c::GroupedColoring)
    return c.colors
end

"""
    Base.eachindex(c::Union{GroupedColoring,Graphs.Coloring})

Return an iterator over the indices of the color groups in `c`.

# Arguments

  - `c`: An object representing a coloring.

# Returns

  - An iterator over the indices of the color groups (typically `1:numcolors(c))`).

# Notes

This method implements the `eachindex` interface for `GroupedColoring` and `Graphs.Coloring`, making it compatible
with Julia's standard iteration patterns.
"""
function Base.eachindex(c::GroupedColoring)
    return Base.eachindex(colors(c))
end

"""
    Base.getindex(c::Union{GroupedColoring,Graphs.Coloring}, color)

Return the i-th color group from the coloring object `c`.

# Arguments

  - `c`: An object representing a coloring.
  - `color`: An integer index specifying which color group to retrieve (must be within valid bounds).

# Returns

  - The i-th color group (typically a vector of elements assigned to that color).
"""
function Base.getindex(c::GroupedColoring, i)
    return Base.getindex(colors(c), i)
end
