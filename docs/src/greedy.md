# Greedy

Represents the [Greedy coloring algorithm](https://www.geeksforgeeks.org/dsa/graph-coloring-set-2-greedy-algorithm/),
where each node is colred subsequentently.
The next node to be colored is chosen as the node with the largest element ID.

The colors are not guaranteed to be balanced.

## Usage example

```@example color_ball_greedy
using PlotlyJS
using CompScienceMeshes
using BEAST
using GraphColoring

m = meshsphere(1.0, 0.1)
X = raviartthomas(m)

conflicts = GraphColoring.conflictmatrix(X)

colors = GraphColoring.color(conflicts; algorithm=Greedy())

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

savefig(p, "color_greedy_ball.html"); # hide
nothing #hide
```

```@raw html
<object data="../color_greedy_ball.html" type="text/html"  style="width:100%; height:50vh;"> </object>
```
