m = require 'mori'
graph = require '../src/PersistentGraph'
g = require '../src/graph'
t = require '../src/traversal'
a = require '../src/algorithms'

showGraph = (es...) ->
  G = graph(es)

  pred = (v) -> g.predecessors(G, v)
  succ = (v) -> g.successors(G, v)
  adj =  (v) -> g.adjacent(G, v)
  verts = g.vertices(G)
  sources = m.filter(m.partial(g.isSource, G), verts)
  edges = g.edges(G)

  console.log ""
  console.log "Vertices:", verts
  console.log "Edges:", edges
  console.log "Breadth-first traversal:", t.bfs(succ, verts)
  console.log "Depth-first traversal:", t.dfs(succ, verts)
  console.log "Topological order:", a.topsort(succ, verts)
  console.log "Articulation points:", a.articulationPoints(adj, verts)
  console.log "Bottlenecks:", a.bottlenecks(succ, sources)

showGraph [1, 2], [1, 3], [2, 4], [3, 4], [4, 5]
showGraph [1, 2], [1, 3], [2, 4], [4, 3], [4, 5]
showGraph [1, 2], [3, 1], [2, 4], [4, 3], [4, 5]
showGraph [1, 2], [3, 4], [2, 4], [2, 5], [4, 6],
  [6, 7], [6, 8], [7, 9], [8, 9]
showGraph [1, 2], [3, 4], [3, 2], [2, 5], [4, 5], [4, 6]
showGraph [0, 1], [0, 3], [1, 2], [3, 4], [3, 2], [2, 5], [4, 5], [4, 6]
showGraph [1, 2], [1, 3], [1, 5], [2, 5], [3, 5], [4, 5]
showGraph [1, 2], [1, 6], [1, 10], [1, 12], [2, 11], [2, 12],
  [3, 4], [3, 5], [3, 6], [4, 10], [4, 13], [6, 7],
  [6, 12], [6, 13], [7, 9], [9, 10], [11, 12], [8, 8]
