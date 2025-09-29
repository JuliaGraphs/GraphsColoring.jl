# GraphsColoring

<p align="center">
<picture>
  <source media="(prefers-color-scheme)" srcset="docs/src/assets/logo.svg" height="100">
  <img alt="" src="" height="100">
</picture>
</p>

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://juliagraphs.org/GraphsColoring.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://juliagraphs.org/GraphsColoring.jl/dev/)
[![Build Status](https://github.com/JuliaGraphs/GraphsColoring.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/JuliaGraphs/GraphsColoring.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/djukic14/GraphsColoring.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/djukic14/GraphsColoring.jl)
[![Aqua QA](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)


## Introduction

Graph coloring is a technique used to avoid conflicts between elements in a graph. The goal is to assign colors to the elements such that no two neighboring elements have the same color.
Currently, the following aspects are implemented (✓) and planned (⌛):

- ✓ [Greedy](https://www.geeksforgeeks.org/dsa/graph-coloring-set-2-greedy-algorithm/)
- ✓ [DSATUR (Degree SATURated)](https://www.geeksforgeeks.org/dsa/dsatur-algorithm-for-graph-coloring/)
- ✓ [Workstream](https://dl.acm.org/doi/10.1145/2851488)
- ⌛ Random (and iterative random coloring)
- ⌛ First-Fit Coloring

## Documentation

- Documentation for the [latest stable version](https://juliagraphs.org/GraphsColoring.jl/stable/).
- Documentation for the [development version](https://juliagraphs.org/GraphsColoring.jl/dev/)
