# Storing and Accessing Coloring Results

Coloring results in `GraphsColoring` can be stored in two primary formats:

## `GroupedColoring` (Default)

- **Storage**: Colors are stored as a vector of vectors, where each inner vector contains the indices of elements assigned to a specific color.
- **Optimization**: Efficient retrieval of all elements belonging to a specific color group.
- **Best for**: Operations that frequently access elements by color (e.g., processing color groups in parallel, analyzing group sizes, or visualizing color distributions).
- **Default behavior**: This is the default storage format when no `storage` parameter is specified.

## `Graphs.Coloring`

- **Storage**: Colors are stored as a flat vector where `colors[i]` gives the color assigned to element `i`.
- **Optimization**: Efficient access to the color of a specific element.
- **Best for**: Operations that frequently query the color of individual elements.

---

## Usage Examples

### Using `GroupedColoring` (Default)

```@example
using PlotlyJS#hide
using CompScienceMeshes#hide
using BEAST#hide
using GraphsColoring#hide

m = meshsphere(1.0, 0.1)#hide
X = raviartthomas(m)#hide

conflicts = GraphsColoring.conflictmatrix(X)#hide

colors = GraphsColoring.color(conflicts; storage=GraphsColoring.GroupedColors())
```

### Using `Graphs.Coloring`

```@example
using PlotlyJS#hide
using CompScienceMeshes#hide
using BEAST#hide
using GraphsColoring#hide

m = meshsphere(1.0, 0.1)#hide
X = raviartthomas(m)#hide

conflicts = GraphsColoring.conflictmatrix(X)#hide

colors = GraphsColoring.color(conflicts; storage=GraphsColoring.GraphsColors())
```

---

## Accessing Coloring Results

Both storage formats support standard Julia interfaces:

| Operation | Description |
|---------|-------------|
| `numcolors(c)` | Returns the total number of distinct colors |
| `eachindex(c)` | Iterates over color group indices (1-based) |
| `c[i]` | Retrieves the i-th color group (as a vector of element indices) |
| `length(c[i])` | Gets the number of elements in the i-th color group |

### Example: Accessing Colors

```@example
using PlotlyJS#hide
using CompScienceMeshes#hide
using BEAST#hide
using GraphsColoring#hide

m = meshsphere(1.0, 0.1)#hide
X = raviartthomas(m)#hide

conflicts = GraphsColoring.conflictmatrix(X)#hide

colors = GraphsColoring.color(conflicts; algorithm=WorkstreamGreedy, storage=GraphsColoring.GraphsColors()) # hide

println("We have $(numcolors(colors))")
for color in eachindex(colors)
    println("Color $color has $(length(colors[color])) elements. The members of color $color are $(colors[color])")
end
```

---

## Notes

- The default storage is `GroupedColoring` because it enables efficient group-based operations.
- The `Graphs.Coloring` format is more efficient for very large problems when only individual element colors are needed.
