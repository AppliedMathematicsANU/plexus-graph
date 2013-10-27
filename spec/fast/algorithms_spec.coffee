_ = require 'mori'
graph = require '../../src/PersistentGraph'
g = require '../../src/graph'
a = require '../../src/algorithms'


articulationPoints = (G) ->
  a.articulationPoints(_.partial(g.adjacent, G), g.vertices(G))

bottlenecks = (G) ->
  a.bottlenecks(
    _.partial(g.successors, G),
    _.filter(_.partial(g.isSource, G), g.vertices(G)))


describe "An empty graph", ->
  G = graph()

  it "should have no articulation points", ->
    expectSet(articulationPoints(G), [])

  it "should have no bottlenecks", ->
    expectSet(bottlenecks(G), [])


describe "An graph with a single vertex and no edges", ->
  G = graph([], [1])

  it "should have no articulation points", ->
    expectSet(articulationPoints(G), [])

  it "should have a single bottleneck", ->
    expectSet(bottlenecks(G), [1])


describe "The graph 1->2, 2->3, 3->1, 1->4, 4->5, 5->1", ->
  G = graph([ [1,2], [2,3], [3,1], [1,4], [4,5], [5,1] ])

  it "should have a single articulation point at 1", ->
    expectSet(articulationPoints(G), [1])

  it "should have no bottlenecks", ->
    expectSet(bottlenecks(G), [])

  it "should still have no bottlenecks when seeded with a non-source", ->
    for v in [1,2,3]
      expectSet(a.bottlenecks(_.partial(g.successors, G), [v]), [])


describe "The graph 1->2, 2->3, 3->4, 4->2", ->
  G = graph([ [1,2], [2,3], [3,4], [4,2] ])

  it "should have a single articulation point at 2", ->
    expectSet(articulationPoints(G), [2])

  it "should have bottlenecks at 1 and 2", ->
    expectSet(bottlenecks(G), [1, 2])

  it "should have no bottlenecks when seeded with a vertex in the cycle", ->
    for v in [2,3,4]
      expectSet(a.bottlenecks(_.partial(g.successors, G), [v]), [])


describe "The graph 1->2, 3->4, 2->4, 2->5, 4->6, 6->7, 6->8, 7->9, 8->9", ->
  G = graph([ [1,2], [3,4], [2,4], [2,5], [4,6], [6,7], [6,8], [7,9], [8,9] ])

  it "should have the correct list of articulation points", ->
    expectSet(articulationPoints(G), [2, 4, 6])

  it "should have the correct list of bottlenecks", ->
    expectSet(bottlenecks(G), [4, 5, 6, 9])


describe "The graph 1->2, 3->4, 3->2, 2->5, 4->5, 4->6", ->
  G = graph([ [1,2], [3,4], [3,2], [2,5], [4,5], [4,6] ])

  it "should have the correct list of articulation point", ->
    expectSet(articulationPoints(G), [2, 4])

  it "should have the correct list of bottlenecks", ->
    expectSet(bottlenecks(G), [5, 6])


describe "The graph 0->1, 0->3, 1->2, 3->4, 3->2, 2->5, 4->5, 4->6", ->
  G = graph([ [0,1], [0,3], [1,2], [3,4], [3,2], [2,5], [4,5], [4,6] ])

  it "should have the correct list of articulation point", ->
    expectSet(articulationPoints(G), [4])

  it "should have the correct list of bottlenecks", ->
    expectSet(bottlenecks(G), [0, 5, 6])


describe "The graph 1->2, 1->3, 1->5, 2->5, 3->5, 4->5", ->
  G = graph([ [1, 2], [1, 3], [1, 5], [2, 5], [3, 5], [4, 5] ])

  it "should have the correct list of articulation point", ->
    expectSet(articulationPoints(G), [5])

  it "should have the correct list of bottlenecks", ->
    expectSet(bottlenecks(G), [5])
