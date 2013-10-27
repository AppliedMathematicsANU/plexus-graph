_ = require 'mori'
graph = require '../../src/PersistentGraph'
g = require '../../src/graph'


edges = (G) -> _.sort(_.map(((e) -> _.vector(e...)), g.edges(G)))

outEdges = (G) ->
  outgoing = (v) -> _.map(_.vector, _.repeat(v), g.successors(G, v))
  _.sort(_.mapcat(outgoing, g.vertices(G)))

inEdges = (G) ->
  incoming = (v) -> _.map(_.vector, g.predecessors(G, v), _.repeat(v))
  _.sort(_.mapcat(incoming, g.vertices(G)))


describe 'A graph', ->
  it 'should be equal to the graph defined by its edges and vertices', ->
    expectProperty(forAll(Graph(0.2)).satisfy((G) ->
      g.equals(G, graph(g.edges(G), g.vertices(G)))))

  it 'should have the same set of incoming and outgoing edges', ->
    expectProperty(forAll(Graph(0.2)).satisfy((G) ->
      _.equals(inEdges(G), outEdges(G)) and
      _.equals(edges(G), outEdges(G))))

  it 'should stay the same if some edges are removed and added back', ->
    expectProperty(forAll(Graph(0.2)).satisfy((G) ->
      es = g.edges(G)[0...g.edges(G).length/2]
      g.equals(G, G.withoutEdges(es).withEdges(es))))
