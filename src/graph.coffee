###

This module provides a layer of indirection between implementations of
(directed) graphs and client code.

At the minimum, a graph instance needs to implement three methods,
each returning an array of vertices:

    vertices    : ()  -> ... # The vertices of the graph
    predecessors: (v) -> ... # The direct predecessors of vertex v
    successors  : (v) -> ... # The direct successors of vertex v

Further methods will be used where present. For example, the function call
`equals(G, H)` will defer to `G.equals(H)` if the graph `G` has an attribute
`"equals"`.
###


vertices = (G) ->
  ### The vertices of the given graph as an array. ###
  G.vertices()

predecessors = (G, v) ->
  ### The immediate predecessors of vertex `v` in graph `G` as an array. ###
  G.predecessors(v)

successors = (G, v) ->
  ### The immediate successors of vertex `v` in graph `G` as an array. ###
  G.successors(v)


isVertex = (G, v) ->
  ### Tests whether `v` is a vertex of the graph `G`. ###
  if G.isVertex? then G.isVertex(v) else vertices(G).indexOf(v) >= 0

isEdge = (G, v, w) ->
  ### Tests whether `[v, w]` is a directed edge of the graph `G`. ###
  if G.isEdge? then G.isEdge(v, w) else successors(G, v).indexOf(w) >= 0

isSource = (G, v) ->
  ### Tests whether `v` is a vertex in `G` with no predecessors. ###
  if G.isSource? then G.isSource(v) else predecessors(G, v).length == 0

isSink = (G, v) ->
  ### Tests whether `v` is a vertex in `G` with no successors. ###
  if G.isSink? then G.isSink(v) else successors(G, v).length == 0

isInternal = (G, v) ->
  ###
  Tests whether `v` is a vertex in `G` with both predecessors and successors.
  ###
  if G.isInternal?
    G.isInternal(v)
  else
    isVertex(G, v) and not (isSource(G, v) or isSink(G, v))

isIsolated = (G, v) ->
  ###
  Tests whether `v` is a vertex in `G` neither predecessors nor successors.
  ###
  if G.isIsolated?
    G.isIsolated(v)
  else
    isVertex(G, v) and isSource(G, v) and isSink(G, v)

edges = (G) ->
  ### The directed edges of the graph `G` as an array of pairs. ###
  if G.edges?
    G.edges()
  else
    a = []
    for v in vertices(G)
      for w in successors(G, v)
        a.push [v, w]
    a

adjacent = (G, v) ->
  ### All the vertices adjacent to `v` in the graph `G` as an array. ###
  if G.adjacent?
    G.adjacent(v)
  else
    a = predecessors(G, v)
    for w in successors(G, v)
      a.push(w) unless a.indexOf(w) >= 0
    a

equals = (G, H) ->
  ###
  Tests whether the graphs `G` and `H` are equal in the sense that they have
  the same sets of vertices and directed edges.
  ###
  if G.equals?
    G.equals(H)
  else
    eq = (a, b) ->
      a = a[..].sort()
      b = b[..].sort()
      if a.length != b.length
        false
      else
        for i in [0...a.length]
          if a[i] != b[i]
            return false
        true

    if not eq(vertices(G), vertices(H))
      false
    else
      for v in vertices(G)
        if not eq(successors(G, v), successors(H, v))
          return false
      true


module.exports =
  vertices    : vertices
  predecessors: predecessors
  successors  : successors
  isVertex    : isVertex
  isSource    : isSource
  isSink      : isSink
  isInternal  : isInternal
  isIsolated  : isIsolated
  isEdge      : isEdge
  edges       : edges
  adjacent    : adjacent
  equals      : equals
