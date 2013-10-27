_ = require 'mori'
graph = require '../../src/PersistentGraph'
g = require '../../src/graph'


sources = (graph) ->
  _.filter(_.partial(g.isSource, graph), g.vertices(graph))

sinks = (graph) ->
  _.filter(_.partial(g.isSink  , graph), g.vertices(graph))

internal = (graph) ->
  _.filter(_.partial(g.isInternal , graph), g.vertices(graph))

isolated = (graph) ->
  _.filter(_.partial(g.isIsolated , graph), g.vertices(graph))


describe "An empty graph", ->
  G = graph()

  it "should have no vertices", ->
    expectSet(g.vertices(G), [])

  it "should have no edges", ->
    expectSet(g.edges(G), [])


describe "A graph with a single vertex and no edges", ->
  v = 1
  G = graph([], [v])

  it "should have just that vertex", ->
    expectSet(g.vertices(G), [v])

  it "should have no edges", ->
    expectSet(g.edges(G), [])

  it "should list no predecessors for the vertex", ->
    expectSet(g.predecessors(G, v), [])

  it "should list no successors for the vertex", ->
    expectSet(g.successors(G, v), [])

  it "should list no adjacent vertices for the vertex", ->
    expectSet(g.adjacent(G, v), [])

  it "should have just that vertex as a source", ->
    expectSet(sources(G), [v])

  it "should have just that vertex as a sink", ->
    expectSet(sinks(G), [v])

  it "should have that and no other isolated vertices", ->
    expectSet(isolated(G), [v])

  it "should have no internal vertices", ->
    expectSet(internal(G), [])


describe "A graph specified as a single loop", ->
  v = 1
  G = graph([[v, v]])

  it "should be empty", ->
    expectSet(g.vertices(G), [])
    expectSet(g.edges(G), [])


describe "A graph with two vertices and a single connecting edge", ->
  [v, w, x] = [1, 2, 3]
  G = graph([[v, w]])

  it "should have the ends of that edge as its only vertices", ->
    expectSet(g.vertices(G), [v, w])

  it "should have just that one edge", ->
    expectSet(g.edges(G), [[v, w]])

  it "should identify vertices correctly", ->
    expect(g.isVertex(G, v)).toBe(true)
    expect(g.isVertex(G, w)).toBe(true)
    expect(g.isVertex(G, x)).toBe(false)

  it "should identify edges correctly", ->
    expect(g.isEdge(G, v, w)).toBe(true)
    expect(g.isEdge(G, w, v)).toBe(false)
    expect(g.isEdge(G, v, v)).toBe(false)
    expect(g.isEdge(G, w, w)).toBe(false)
    expect(g.isEdge(G, v, x)).toBe(false)

  it "should list the correct predecessors", ->
    expectSet(g.predecessors(G, v), [])
    expectSet(g.predecessors(G, w), [v])

  it "should list the correct successors", ->
    expectSet(g.successors(G, v), [w])
    expectSet(g.successors(G, w), [])

  it "should list the correct adjacencies", ->
    expectSet(g.adjacent(G, v), [w])
    expectSet(g.adjacent(G, w), [v])

  it "should have the origin of that edge as its only source", ->
    expectSet(sources(G), [v])

  it "should have the target of that edge as its only sink", ->
    expectSet(sinks(G), [w])

  it "should have no isolated vertices", ->
    expectSet(isolated(G), [])

  it "should have no internal vertices", ->
    expectSet(internal(G), [])


describe "A graph with a single edge and an isolated vertex", ->
  [u, v, w, x] = [1, 2, 3, 4]
  G = graph([[v, w]], [u])

  it "should have the appropriate three vertices", ->
    expectSet(g.vertices(G), [u, v, w])

  it "should have just that one edge", ->
    expectSet(g.edges(G), [[v, w]])

  it "should identify vertices correctly", ->
    expect(g.isVertex(G, u)).toBe(true)
    expect(g.isVertex(G, v)).toBe(true)
    expect(g.isVertex(G, w)).toBe(true)
    expect(g.isVertex(G, x)).toBe(false)

  it "should identify edges correctly", ->
    expect(g.isEdge(G, v, w)).toBe(true)
    expect(g.isEdge(G, w, v)).toBe(false)
    expect(g.isEdge(G, v, v)).toBe(false)
    expect(g.isEdge(G, w, w)).toBe(false)
    expect(g.isEdge(G, u, u)).toBe(false)
    expect(g.isEdge(G, v, u)).toBe(false)
    expect(g.isEdge(G, u, v)).toBe(false)

  it "should list the correct predecessors", ->
    expectSet(g.predecessors(G, u), [])
    expectSet(g.predecessors(G, v), [])
    expectSet(g.predecessors(G, w), [v])

  it "should list the correct successors", ->
    expectSet(g.successors(G, u), [])
    expectSet(g.successors(G, v), [w])
    expectSet(g.successors(G, w), [])

  it "should list the correct adjacencies", ->
    expectSet(g.adjacent(G, u), [])
    expectSet(g.adjacent(G, v), [w])
    expectSet(g.adjacent(G, w), [v])

  it "should identify the correct sources", ->
    expectSet(sources(G), [u, v])

  it "should identify the correct sinks", ->
    expectSet(sinks(G), [u, w])

  it "should have just the one isolated vertex", ->
    expectSet(isolated(G), [u])

  it "should have no internal vertices", ->
    expectSet(internal(G), [])


describe "A graph with a single, directed, triangular cycle", ->
  [u, v, w, x] = [1, 2, 3, 4]
  G = graph([[u, v], [v, w], [w, u]])

  it "should have the appropriate three vertices", ->
    expectSet(g.vertices(G), [u, v, w])

  it "should have the appropriate three edges", ->
    expectSet(g.edges(G), [[u, v], [v, w], [w, u]])

  it "should identify vertices correctly", ->
    expect(g.isVertex(G, u)).toBe(true)
    expect(g.isVertex(G, v)).toBe(true)
    expect(g.isVertex(G, w)).toBe(true)
    expect(g.isVertex(G, x)).toBe(false)

  it "should identify edges correctly", ->
    expect(g.isEdge(G, u, v)).toBe(true)
    expect(g.isEdge(G, v, w)).toBe(true)
    expect(g.isEdge(G, w, u)).toBe(true)
    expect(g.isEdge(G, w, v)).toBe(false)
    expect(g.isEdge(G, v, v)).toBe(false)
    expect(g.isEdge(G, w, w)).toBe(false)
    expect(g.isEdge(G, u, u)).toBe(false)
    expect(g.isEdge(G, v, u)).toBe(false)
    expect(g.isEdge(G, u, w)).toBe(false)

  it "should list the correct predecessors", ->
    expectSet(g.predecessors(G, u), [w])
    expectSet(g.predecessors(G, v), [u])
    expectSet(g.predecessors(G, w), [v])

  it "should list the correct successors", ->
    expectSet(g.successors(G, u), [v])
    expectSet(g.successors(G, v), [w])
    expectSet(g.successors(G, w), [u])

  it "should list the correct adjacencies", ->
    expectSet(g.adjacent(G, u), [v, w])
    expectSet(g.adjacent(G, v), [u, w])
    expectSet(g.adjacent(G, w), [u, v])

  it "should have no sources", ->
    expectSet(sources(G), [])

  it "should have no sinks", ->
    expectSet(sinks(G), [])

  it "should have no isolated vertices", ->
    expectSet(isolated(G), [])

  it "should identify all three vertices as internal", ->
    expectSet(internal(G), [u, v, w])
