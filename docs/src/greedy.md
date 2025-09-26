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
using GraphsColoring

m = meshsphere(1.0, 0.1)
X = raviartthomas(m)

conflicts = GraphsColoring.conflictmatrix(X)

colors = GraphsColoring.color(conflicts; algorithm=Greedy())

facecolors = zeros(size(conflicts, 1))

for color in eachindex(colors)
    println("Color $color has $(length(colors[color])) elements")
    for element in colors[color]
        facecolors[element] = color
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
