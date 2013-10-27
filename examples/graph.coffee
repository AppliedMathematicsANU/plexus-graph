graph = require '../src/PersistentGraph'
g = require '../src/graph'

print = (G) ->
  console.log "Graph as object:", G
  console.log "Vertices:", g.vertices(G)
  console.log "Edges:", g.edges(G)
  console.log "Neighbors of 4:", g.adjacent(G, 4)
  console.log "is 4 a vertex? - ", g.isVertex(G, 4)
  console.log "is [3,4] an edge? - ", g.isEdge(G, 3, 4)
  console.log ""

G = graph [[1, 2], [1, 3], [2, 4], [3, 4], [4, 5]]
print G

console.log "Without vertex 4..."
print G.withoutVertices [4]

console.log "Without edge (3,4)..."
print G.withoutEdges [[3, 4]]
