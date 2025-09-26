"""
    struct Workstream{T}
        algorithm::T

Represents the workstream coloring algorithm presented in [1].

# Type Parameters

  - `T`: The type of the coloring algorithm.

# Fields

  - `algorithm::T`: The coloring algorithm used by the workstream.

This struct represents the workstream coloring algorithm, which does not create the minimal
amount of colors, but is very good at creating balanced colors.
Balanced colors are important for load balancing in parallel computing.
It uses the `partition`, `color`, and `gather` steps to perform coloring.
In the `color` step, the `algorithm` is used for internal coloring.
Only coloring all elements is supported.

See [1] for more information on the workstream design pattern.

[1] B. Turcksin, M. Kronbichler, and W. Bangerth, **WorkStream – A Design Pattern for Multicore-Enabled Finite Element Computations**, 2017
"""
struct Workstream{T}
    algorithm::T
end

"""
    const WorkstreamDSATUR = Workstream(DSATUR())

A workstream that uses the [DSATUR](https://www.geeksforgeeks.org/dsa/dsatur-algorithm-for-graph-coloring/) coloring algorithm.
"""
const WorkstreamDSATUR = Workstream(DSATUR())

"""
    const WorkstreamGreedy = Workstream(Greedy())

A workstream that uses the [Greedy](https://www.geeksforgeeks.org/graph-coloring-set-2-greedy-algorithm/) coloring algorithm.
"""
const WorkstreamGreedy = Workstream(Greedy())

# divides elements into even and odd zones
# no conflict between elements of an odd zone and elements of another odd zone (same for even)
# there may be conflicts between elements of same zone

"""
    function partition(conflicts)

Partitions the elements into two sets of zones: even and odd zones.

# Arguments

  - `conflicts`: The conflict representation.

# Returns

A tuple of two vectors of sets, where each set represents a zone.
The first vector contains the odd zones, and the second vector contains the even zones.

The partitioning is done such that there are no conflicts between elements of an odd zone
and elements of another odd zone (and similarly for even zones).
However, there may be conflicts between elements within the same zone.
"""
function partition(conflicts)
    _issorted = zeros(Bool, _numelements(conflicts))
    zones = Vector{Set{Int}}()
    push!(zones, Set(1))
    numsorted = 1
    _issorted[begin] = true

    while numsorted < _numelements(conflicts)
        newzone = Set{Int}()

        for element in zones[end]
            for conflictingelement in _neighbors(conflicts, element)
                _issorted[conflictingelement] && continue

                push!(newzone, conflictingelement)
                _issorted[conflictingelement] = true
                numsorted += 1
            end
        end

        if isempty(newzone)
            for (i, sorted) in enumerate(_issorted)
                sorted && continue

                push!(newzone, i)
                _issorted[i] = true
                numsorted += 1
                break
            end
        end

        push!(zones, newzone)
    end

    return zones[1:2:length(zones)], zones[2:2:length(zones)]
end

"""
    function colorzones(conflicts, zones, algorithm)

Colors the elements within each zone using the specified algorithm.

# Arguments

  - `conflicts`: The conflict representation.
  - `zones`: A vector of sets, where each set represents a zone.
  - `algorithm`: The coloring algorithm to use (e.g., DSATUR, Greedy).

# Returns

A vector of vectors of vectors, where each innermost vector represents a color class within
a zone.

This function applies the `color` function to each zone independently, using the specified
algorithm to color the elements within that zone.
"""
function colorzones(conflicts, zones, algorithm)
    zonecolors = Vector{Vector{Vector{Int}}}(undef, length(zones))
    for i in eachindex(zones)
        zonecolors[i] = colors(
            color(conflicts, algorithm, GroupedColorConst, collect(zones[i]))
        )
    end
    return zonecolors
end

"""
    function gather(oddcoloredzones, evencoloredzones)

Gathers and combines the colors of the odd and even zones.

# Arguments

  - `oddcoloredzones`: A vector of vectors, where each inner vector represents a color class
    within an odd zone.
  - `evencoloredzones`: A vector of vectors, where each inner vector represents a color
    class within an even zone.

# Returns

A vector of vectors, where each inner vector represents a combined color with elements from
both odd and even zones.
The colors are sorted in decreasing order by the number of their members.

This function works by first gathering the colors within each set of zones (odd and even)
using the `gather` function, and then combining the results.
The combined colors are then sorted in decreasing order by the number of their members.
"""
function gather(oddcoloredzones, evencoloredzones)
    colors = vcat(gather(oddcoloredzones), gather(evencoloredzones))
    sort!(colors; by=length, rev=true)
    return colors
end

# gathers elements in zones to create larger colors
# returns colors with elements from all zones
# colors are sorted decreasingly with number of members
"""
    function gather(coloredzones)

Gathers elements from all zones to create larger colors.

# Arguments

  - `coloredzones`: A vector of vectors, where each inner vector represents a color class
    within a zone.

# Returns

A vector of vectors, where each inner vector represents a color class with elements from all
zones. The colors are sorted in decreasing order by the number of their members.

This function works by first selecting the zone with the most colors (the "master zone") and
using its colors as the initial set.
It then iterates over the remaining zones, appending their colors to the corresponding
colors in the master zone.
Finally, the colors are sorted in decreasing order by the number of their members.
"""
function gather(coloredzones)
    _, masterzoneid = findmax(length, coloredzones)
    colors = deepcopy(reverse(coloredzones[masterzoneid]))

    for (i, zone) in enumerate(coloredzones)
        i == masterzoneid && continue
        for (j, color) in enumerate(zone)
            append!(colors[j], color)
        end
        sort!(colors; by=length, rev=false)
    end
    colors = sort!(colors; by=length, rev=true)
    return colors
end

"""
    function color(conflicts, algorithm::Workstream, elements=1:_numelements(conflicts))

Performs workstream coloring on the given conflicts. It was presented in [1].
Workstream coloring does not create the minimal amount of colors, but is very good at
creating balanced colors.
Balanced colors are important for load balancing in parallel computing.
It uses the `partition`, `color`, and `gather` steps to perform coloring.

# Arguments

  - `conflicts`: The conflict representation.
  - `algorithm::Workstream`: The workstream coloring algorithm.
  - `elements=1:_numelements(conflicts)`: The elements to consider during coloring (default: all elements).

# Returns

A vector of vectors, where each inner vector represents a color.

Note that workstream coloring only supports coloring all elements, so the `elements` argument
must be equal to `1:_numelements(conflicts)`.

See [1] for more information on the workstream design pattern.

[1] B. Turcksin, M. Kronbichler, and W. Bangerth, **WorkStream – A Design Pattern for Multicore-Enabled Finite Element Computations**, 2017
"""
function color(
    conflicts,
    algorithm::Workstream,
    storage=GroupedColorConst,
    elements=1:_numelements(conflicts),
)
    !(elements == 1:_numelements(conflicts)) &&
        return error("Workstream coloring only supports coloring all elements.")

    noconflicts(conflicts) && return storage([collect(elements)])

    oddzones, evenzones = partition(conflicts)

    oddcoloredzones = colorzones(conflicts, oddzones, algorithm.algorithm)
    evencoloredzones = colorzones(conflicts, evenzones, algorithm.algorithm)

    return storage(gather(oddcoloredzones, evencoloredzones))
end
