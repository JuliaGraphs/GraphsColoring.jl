"""
    struct DSATUR

Represents the [DSATUR (Degree SATURated) coloring algorithm](https://www.geeksforgeeks.org/dsa/dsatur-algorithm-for-graph-coloring/),
which makes use of two key concepts:

  - **Degree of a node**: The number of neighbors a node has.
  - **Saturation of a node**: The number of colors already assigned to its neighbors.

The next node to be colored is chosen based on the following criteria:

 1. **Highest saturation degree**: The node with the highest saturation degree is chosen first.
 2. **Largest degree**: In case of a tie, the node with the largest degree is chosen.
 3. **Largest element ID**: If there is still a tie, the node with the largest element ID is chosen.
"""
struct DSATUR end

"""
    struct DSATURNode
        elementid::Int
        degree::Int
        saturation::Int

Represents a node in the context of the DSATUR coloring algorithm.

# Fields

  - `elementid::Int`: The unique identifier of the element.
  - `degree::Int`: The number of neighbors the element has.
  - `saturation::Int`: The number of colors already assigned to the neighboring elements.

This node is used in a [RBTree](https://juliacollections.github.io/DataStructures.jl/stable/red_black_tree/)
from DataStructures.jl to efficiently manage and prioritize nodes during the coloring process.
"""
struct DSATURNode
    elementid::Int
    degree::Int # number of neighbors
    saturation::Int # number of colors assigned to neighboring elements
end

function Base.isless(n1::DSATURNode, n2::DSATURNode)
    !(n1.saturation == n2.saturation) && return Base.isless(n1.saturation, n2.saturation)
    !(n1.degree == n2.degree) && return Base.isless(n1.degree, n2.degree)
    return Base.isless(n1.elementid, n2.elementid)
end

"""
    function initializealgorithminfo(conflicts, elements, ::DSATUR)

Initializes the algorithm-specific information for the DSATUR coloring algorithm.

# Arguments

  - `conflicts`: The conflict representation.
  - `elements`: The list of elements to be colored.
  - `::DSATUR`: The DSATUR algorithm specifier.

# Returns

A named tuple containing the following fields:

  - `degrees`: A vector of integers representing the degree of each element (i.e., the number of neighbors).
  - `saturations`: A vector of integers representing the saturation of each element (i.e., the number of colors already assigned to its neighbors), initialized to zero.

This function is used to set up the initial state of the DSATUR algorithm, which relies on the degrees and saturations of the elements to make coloring decisions.
"""
function initializealgorithminfo(conflicts, elements, ::DSATUR)
    degrees = Int[length(_neighbors(conflicts, cell)) for cell in elements]
    saturations = zeros(Int, length(elements))

    return (degrees=degrees, saturations=saturations)
end

"""
    function node(element, elementid, algorithminfo, ::DSATUR)

Creates a new node for the DSATUR coloring algorithm.

# Arguments

  - `element`: The element to be represented by the node.
  - `elementid`: The local ID of the element.
  - `algorithminfo`: The named tuple containing the algorithm-specific information (degrees and saturations).
  - `::DSATUR`: The DSATUR algorithm specifier.

# Returns

A new `DSATURNode` instance with the following fields:

  - `elementid`: The global ID of the element (note: this field is actually set to the `element` itself, not the `elementid`).
  - `degree`: The current degree of the element.
  - `saturation`: The current saturation of the element.
"""
function node(element, elementid, algorithminfo, ::DSATUR)
    return DSATURNode(
        element, algorithminfo.degrees[elementid], algorithminfo.saturations[elementid]
    )
end

"""
    function updateinfo!(::Any, elementid, algorithminfo, ::DSATUR)

Updates the algorithm-specific information for the DSATUR coloring algorithm after an element has been colored.

# Arguments

  - `::Any`: Unused argument (a placeholder for other algorithms, that need the global elementid).
  - `elementid`: The local ID of the element that has been colored.
  - `algorithminfo`: The named tuple containing the algorithm-specific information (degrees and saturations).
  - `::DSATUR`: The DSATUR algorithm specifier.

# Returns

The updated `algorithminfo` named tuple.

This function updates the degree and saturation of the colored element by:

  - Decrementing its degree by 1, since once of its neighbors is no longer available for coloring.
  - Incrementing its saturation by 1, since a color has been assigned to one of its neighbors.
"""
function updateinfo!(::Any, elementid, algorithminfo, ::DSATUR)
    algorithminfo.degrees[elementid] -= 1
    algorithminfo.saturations[elementid] += 1
    return algorithminfo
end

"""
    function nodetype(::DSATUR)

Returns the node type used by the DSATUR coloring algorithm.

# Arguments

  - `::DSATUR`: The DSATUR algorithm specifier.

# Returns

The `DSATURNode` type, which represents a node with an element ID, degree, and saturation.
"""
function nodetype(::DSATUR)
    return DSATURNode
end
