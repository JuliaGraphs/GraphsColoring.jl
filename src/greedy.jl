"""
    struct Greedy

Represents the [Greedy coloring algorithm](https://www.geeksforgeeks.org/dsa/graph-coloring-set-2-greedy-algorithm/),
where the next node to be colored is chosen as the node with the largest element ID.
"""
struct Greedy end

"""
    struct GreedyNode

Represents a node in the context of the Greedy coloring algorithm.

# Fields

  - `elementid::Int`: The unique identifier of the element.

This node type is used by the Greedy algorithm to make coloring decisions, where the next node to be colored is chosen based on its element ID.
"""
struct GreedyNode
    elementid::Int
end

function Base.isless(n1::GreedyNode, n2::GreedyNode)
    return Base.isless(n1.elementid, n2.elementid)
end

"""
    function initializealgorithminfo(::Any, ::Any, ::Greedy)

Initializes the algorithm-specific information for the Greedy coloring algorithm.

# Arguments

  - `::Any`: Unused arguments (placeholders for other algorithms).
  - `::Any`: Unused arguments (placeholders for other algorithms).
  - `::Greedy`: The Greedy algorithm specifier.

# Returns

`nothing`, indicating that no additional information is needed for the Greedy algorithm to make coloring decisions.
"""
function initializealgorithminfo(::Any, ::Any, ::Greedy)
    return nothing
end

"""
    function node(element, ::Any, ::Any, ::Greedy)

Creates a new node for the Greedy coloring algorithm.

# Arguments

  - `element`: The element to be represented by the node.
  - `::Any`: Unused arguments (placeholders for other algorithms).
  - `::Any`: Unused arguments (placeholders for other algorithms).
  - `::Greedy`: The Greedy algorithm specifier.

# Returns

A new node instance representing the element, which is used by the Greedy algorithm to make coloring decisions.

Note: The Greedy algorithm does not require any additional information beyond the element itself, so the node is created with only the element.
"""
function node(element, ::Any, ::Any, ::Greedy)
    return GreedyNode(element)
end

"""
    function updateinfo!(::Any, ::Any, ::Any, ::Greedy)

Updates the algorithm-specific information for the Greedy coloring algorithm.

# Arguments

  - `::Any`: Unused arguments (placeholders for other algorithms).
  - `::Any`: Unused arguments (placeholders for other algorithms).
  - `::Any`: Unused arguments (placeholders for other algorithms).
  - `::Greedy`: The Greedy algorithm specifier.

# Returns

`nothing`, indicating that no update is needed for the Greedy algorithm, as it does not maintain any internal state.
"""
function updateinfo!(::Any, ::Any, ::Any, ::Greedy)
    return nothing
end

"""
    function nodetype(::Greedy)

Returns the node type used by the Greedy coloring algorithm.

# Arguments

  - `::Greedy`: The Greedy algorithm specifier.

# Returns

The `GreedyNode` type, which represents a node used by the Greedy algorithm to make coloring decisions.
"""
function nodetype(::Greedy)
    return GreedyNode
end
