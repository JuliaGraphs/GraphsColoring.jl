# Workstream

The [`Workstream`](@ref) coloring algorithm is presented in [1].

The [`Workstream`](@ref) coloring algorithm does not have the goal to create the minimal
amount of colors, but is very good at creating balanced colors.
Balanced colors are important for load balancing in parallel computing.
The algorithm consists of the following steps:

1. [`partition`](@ref)

    The elements are partitioned into two sets of zones: even and odd zones.
    The partitioning is done such that there are no conflicts between elements of an odd zone
    and elements of another odd zone (and similarly for even zones).
    However, there may be conflicts between elements within the same zone.

2. [`color`](@ref)

    The [`colorzones`](@ref) colors the elements within each zone using a specified algorithm.

3. [`gather`](@ref)

    For the even and odd zones, respectively, the [`gather`](@ref) step selects the zone with the most colors (the "master zone") and uses its colors as the initial set.
    It then iterates over the remaining zones, appending their colors to the corresponding
    colors in the master zone to create larger colors.
    Finally, the colors are sorted in decreasing order by the number of their members.

See [1] for more information on the [`Workstream`](@ref) design pattern.

[1] B. Turcksin, M. Kronbichler, and W. Bangerth, **WorkStream – A Design Pattern for Multicore-Enabled Finite Element Computations**, 2017

## Usage example I

```@example color_ball_workstreamdsatur
using PlotlyJS
using CompScienceMeshes
using BEAST
using GraphsColoring

m = meshsphere(1.0, 0.1)
X = raviartthomas(m)

conflicts = GraphsColoring.conflictmatrix(X)

colors = GraphsColoring.color(conflicts; algorithm=WorkstreamDSATUR)

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

savefig(p, "color_workstreamdsatur_ball.html"); # hide
nothing #hide
```

```@raw html
<object data="../color_workstreamdsatur_ball.html" type="text/html"  style="width:100%; height:50vh;"> </object>
```

## Usage example II

Instead of the [`DSATUR`](@ref) algorithm we can also use the [`Greedy`](@ref) algorithm in the [`color`](@ref) step.

```@example color_ball_workstreamgreedy
using PlotlyJS#hide
using CompScienceMeshes#hide
using BEAST#hide
using GraphsColoring#hide

m = meshsphere(1.0, 0.1)#hide
X = raviartthomas(m)#hide

conflicts = GraphsColoring.conflictmatrix(X)#hide

colors = GraphsColoring.color(conflicts; algorithm=WorkstreamGreedy)

for (i, color) in enumerate(colors)#hide
    println("Color $i has $(length(color)) elements")#hide
end#hide

facecolors = zeros(size(conflicts, 1))#hide

for (i, color) in enumerate(colors)#hide
    for element in color#hide
        facecolors[element] = i#hide
    end#hide
end #hide

p = PlotlyJS.plot(#hide
    patch(m, facecolors; showscale=false),#hide
    Layout(;#hide
        scene=attr(;#hide
            xaxis=attr(; visible=false),#hide
            yaxis=attr(; visible=false),#hide
            zaxis=attr(; visible=false),#hide
        ),#hide
    );#hide
)#hide

savefig(p, "color_workstreamgreedy_ball.html"); # hide
nothing #hide
```

```@raw html
<object data="../color_workstreamgreedy_ball.html" type="text/html"  style="width:100%; height:50vh;"> </object>
```
