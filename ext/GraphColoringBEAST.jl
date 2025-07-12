module GraphColoringBEAST
using GraphColoring
using BEAST

import GraphColoring: ConflictFunctor, conflicts

"""
    function conflicts(
        space::BEAST.Space;
        addata=assemblydata(space),
        refspace=BEAST.refspace(space),
        kwargs...,
    )

Computes conflict indices for a BEAST.Space. Two elements are in conflict if they are both
part of the support of the same basis function.

# Arguments

  - `space::BEAST.Space`: The BEAST space.
  - `addata=assemblydata(space)`: The assembly data for the space (default: computed using `assemblydata`).
  - `refspace=BEAST.refspace(space)`: The reference space for the space (default: computed using `BEAST.refspace`).
  - `kwargs...`: Additional keyword arguments.

# Returns

A tuple containing:

  - `eachindex(elements)`: The indices of the elements.
  - `ConflictFunctor(conflictindices)`: A functor that maps element indices to conflict indices.
  - `Base.OneTo(numfunctions(space))`: The indices of the conflicts.
"""
function conflicts(
    space::BEAST.Space;
    addata=assemblydata(space),
    refspace=BEAST.refspace(space),
    kwargs...,
)
    elements, ad, _ = addata

    conflictindices = Vector{Int}[Int[] for _ in eachindex(elements)]

    reference = BEAST.domain(BEAST.chart(geometry(space), first(geometry(space))))

    for elementid in eachindex(elements)
        for i in 1:numfunctions(refspace, reference)
            for (functionid, _) in ad[elementid, i]
                push!(conflictindices[elementid], functionid)
            end
        end
    end
    return eachindex(elements),
    ConflictFunctor(conflictindices),
    Base.OneTo(numfunctions(space))
end

end # module GraphColoringBEAST
