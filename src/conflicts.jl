"""
    function reverseconflicts(elements, conflicts, conflictids)

Reverses the conflict indices and elements.

# Arguments

  - `elements`: The elements.
  - `conflicts`: A function that takes an element and returns its conflict indices.
  - `conflictids`: The conflict IDs.

# Returns

A vector of vectors, where each inner vector represents the elements which have a certain
conflict index.
"""
function reverseconflicts(elements, conflicts, conflictids)
    reverseconflicts = [Int[] for _ in conflictids]

    for element in elements
        for conflict in conflicts(element)
            push!(reverseconflicts[conflict], element)
        end
    end
    return reverseconflicts
end

"""
    struct ConflictFunctor{T}
        conflictindices::T

A functor that can be used to return conflict indices.

# Type Parameters

  - `T`: The type of the conflict indices.

# Fields

  - `conflictindices::T`: The conflict indices.

This functor represents a mapping from element indices to conflict indices.
Two elements that have the same conflict index are considered to be in conflict.
An element can have multiple conflict indices, indicating that it is in conflict with
multiple other elements.
"""
struct ConflictFunctor{T}
    conflictindices::T
end

"""
    function (f::ConflictFunctor)(i::Int)

Returns the conflict indices for the given element index.

# Arguments

  - `f::ConflictFunctor`: The conflict functor.
  - `i::Int`: The element index.

# Returns

The conflict indices for the given element index.
"""
function (f::ConflictFunctor)(i::Int)
    return f.conflictindices[i]
end

# SparseArrays #############################################################################

"""
    function conflictmatrix(X; kwargs...)

Computes a sparse matrix as a conflict representation.

# Arguments

  - `X`: An object that supports the `conflicts` function.
  - `kwargs...`: Additional keyword arguments that are passed to the `conflicts` function.

# Returns

A sparse matrix representing the conflicts between elements, where each entry `(i, j)`
represents a conflict between elements `i` and `j`.
Note that this matrix is symmetric.
"""
function conflictmatrix(X; kwargs...)
    elements, conflicts, conflictids = GraphColoring.conflicts(X; kwargs...)
    reverseconflicts = GraphColoring.reverseconflicts(elements, conflicts, conflictids)

    I = Int[]
    J = Int[]
    for elements in reverseconflicts
        for element in elements
            for element2 in elements
                element == element2 && continue
                push!(I, element)
                push!(J, element2)
            end
        end
    end

    return sparse(I, J, ones(Bool, length(I)), length(elements), length(elements))
end

"""
    function _neighbors(s::SparseMatrixCSC, element::Int)

Returns the neighbors of a given element, i.e. the elements that have a conflict with the
element, in the sparse matrix, which is used as a conflict representation.

# Arguments

  - `s::SparseMatrixCSC`: The sparse matrix representing the graph.
  - `element::Int`: The element for which to retrieve the neighbors.

# Returns

A view of the row values in the sparse matrix that correspond to the neighbors of the given element.
"""
function _neighbors(s::SparseMatrixCSC, element::Int)
    return view(rowvals(s), nzrange(s, element))
end

"""
    function _numelements(s::SparseMatrixCSC)

Returns the number of elements in the given sparse matrix, which is used as a conflict
representation.

# Arguments

  - `s::SparseMatrixCSC`: The sparse matrix.

# Returns

The number of rows in the matrix, which represents the number of elements.
"""
function _numelements(s::SparseMatrixCSC)
    return Base.size(s, 1)
end

"""
    function noconflicts(s::SparseMatrixCSC)

Checks if there are no conflicts in the given sparse matrix, which is used as a conflict
representation.

# Arguments

  - `s::SparseMatrixCSC`: The sparse matrix to check.

# Returns

`true` if there are no conflicts (i.e., the matrix has no non-zero entries), and `false` otherwise.
"""
function noconflicts(s::SparseMatrixCSC)
    return iszero(nnz(s))
end
