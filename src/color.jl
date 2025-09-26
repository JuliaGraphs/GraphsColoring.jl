"""
    function color(conflicts, algorithm, elements=1:_numelements(conflicts))

Performs graph coloring using the specified algorithm.

# Arguments

  - `conflicts`: The conflict representation.
  - `algorithm`: The coloring algorithm to use (e.g., DSATUR, Greedy).
  - `elements`: The elements to consider during coloring (default: all elements).

# Returns

A vector of vectors, where each inner vector represents a color (i.e., a set of elements with the same color).
Elements in the same color do not have any conflict.
The colors are sorted such that the number of their members decrease.

This function implements a generic coloring workflow that can be used with different algorithms, such as DSATUR and Greedy.
"""
function color(
    conflicts, algorithm, storage=GroupedColorConst, elements=1:_numelements(conflicts)
)
    elementtoelementid = Dict{Int,Int}(zip(elements, eachindex(elements)))

    maxcolor = 1
    colors = zeros(Int, length(elements))

    algorithminfo = initializealgorithminfo(conflicts, elements, algorithm)

    tree = RBTree{nodetype(algorithm)}()
    for (i, element) in enumerate(elements)
        push!(tree, node(element, i, algorithminfo, algorithm))
    end

    while length(tree) > 0
        maxelement = DataStructures.minimum_node(tree, tree.root).data
        element = maxelement.elementid

        delete!(tree, maxelement)
        elementcolor = 0

        # find lowest color that you can give to element
        for color in 1:maxcolor
            neighborhascolor = false
            for neighbor in _neighbors(conflicts, element)
                neighbor == element && continue
                !haskey(elementtoelementid, neighbor) && continue

                if color == colors[elementtoelementid[neighbor]]
                    neighborhascolor = true
                end
            end
            if !neighborhascolor
                (elementcolor = color)
                break
            end
        end

        # need to add new color
        if elementcolor == 0
            maxcolor += 1
            elementcolor = maxcolor
        end
        colors[elementtoelementid[element]] = elementcolor

        for neighbor in _neighbors(conflicts, element)
            neighbor == element && continue
            !haskey(elementtoelementid, neighbor) && continue
            localneighbor = elementtoelementid[neighbor]

            !iszero(colors[localneighbor]) && continue

            delete!(tree, node(neighbor, localneighbor, algorithminfo, algorithm))

            updateinfo!(neighbor, localneighbor, algorithminfo, algorithm)
            push!(tree, node(neighbor, localneighbor, algorithminfo, algorithm))
        end
    end

    return storage(maxcolor, colors, elements)
end
