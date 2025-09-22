# Conflicts

A conflict representation is a data structure that captures the conflicts between elements in a graph.
In the context of parallel computing, for example, conflicts occur when two elements share a common resource, such as a memory location.

Two elements are in conflict if they share a common conflict index.
For example, in a parallel computation, two elements may conflict if they both attempt to access the same index of a vector.

A conflict representation must implement the following functions:

1. [`_neighbors`](@ref): Returns a list of elements that are in conflict with the given element.

2. [`_numelements`](@ref): Returns the total number of elements in the conflict representation.

3. [`noconflicts`](@ref): Returns a boolean indicating whether there occurs any conflict in the whole representation.

It is possible to have a [`SparseMatrixCSC`](https://docs.julialang.org/en/v1/stdlib/SparseArrays/#man-csc) from [`SparseArrays`](https://github.com/JuliaSparse/SparseArrays.jl) or a [`SimpleGraph`](https://juliagraphs.org/Graphs.jl/stable/core_functions/simplegraphs/#Graphs.SimpleGraphs.SimpleGraph) from [`Graphs.jl`](https://github.com/JuliaGraphs/Graphs.jl) as a conflict representation.
The graph conflict representation is tied to `GraphsColoring` as an extension depending on  [`Graphs.jl`](https://github.com/JuliaGraphs/Graphs.jl).

The respective representation needs to support the [`conflicts`](@ref) function that returns

- `elements`: The elements.
- `conflicts`: A function that takes an element and returns its conflict indices. The [`ConflictFunctor`](@ref) can be used for this.
- `conflictids`: The conflict IDs.

```@example conflicts
using CompScienceMeshes
using BEAST
using GraphsColoring

m = meshsphere(1.0, 0.1)
X = raviartthomas(m)

conflicts = GraphsColoring.conflicts(X)
```

## Sparse matrix as conflict representation

```@example conflictmatrix
using CompScienceMeshes
using BEAST
using GraphsColoring

m = meshsphere(1.0, 0.1)
X = raviartthomas(m)

conflicts = GraphsColoring.conflictmatrix(X)
```

## Graph as conflict representation

```@example conflictgraph
using CompScienceMeshes
using BEAST
using Graphs
using GraphsColoring

m = meshsphere(1.0, 0.1)
X = raviartthomas(m)

conflicts = GraphsColoring.conflictgraph(X)
println(typeof(conflicts))
```
