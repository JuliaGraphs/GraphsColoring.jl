# DSatur

Represents the [DSATUR (Degree SATURated) coloring algorithm](https://www.geeksforgeeks.org/dsa/dsatur-algorithm-for-graph-coloring/),
which makes use of two key concepts:

- **Degree of a node**: The number of neighbors a node has.
- **Saturation of a node**: The number of colors already assigned to its neighbors.

The next node to be colored is chosen based on the following criteria:

 1. **Highest saturation degree**: The node with the highest saturation degree is chosen first.
 2. **Largest degree**: In case of a tie, the node with the largest degree is chosen.
 3. **Largest element ID**: If there is still a tie, the node with the largest element ID is chosen.

This algorithm often creates less colors than the [`Greedy`](@ref) algorithm.
The colors are not guaranteed to be balanced.

## Usage example

```@example color_ball_dsatur
using PlotlyJS
using CompScienceMeshes
using BEAST
using GraphColoring

m = meshsphere(1.0, 0.1)
X = raviartthomas(m)

conflicts = GraphColoring.conflictmatrix(X)

colors = GraphColoring.color(conflicts; algorithm=DSATUR())

for (i, color) in enumerate(colors)
    println("Color $i has $(length(color)) elements")
end

facecolors = zeros(size(conflicts, 1))

for (i, color) in enumerate(colors)
    for element in color
        facecolors[element] = i
    end
end

p = PlotlyJS.plot(
    patch(m, facecolors; showscale=false),
    Layout(;
        scene=attr(;
            xaxis=attr(; visible=false),
            yaxis=attr(; visible=false),
            zaxis=attr(; visible=false),
        ),
    );
)

savefig(p, "color_dsatur_ball.html"); # hide
nothing #hide
```

```@raw html
<object data="../color_dsatur_ball.html" type="text/html"  style="width:100%; height:50vh;"> </object>
```
