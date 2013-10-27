_ = require 'mori'
x = require '../../src/mori-utils'
g = require '../../src/graph'
t = require '../../src/traversal'
a = require '../../src/algorithms'


correctTopOrder = (G) ->
  order = a.topsort(_.partial(g.successors, G), g.vertices(G))
  index = _.into(_.hash_map(), _.map(_.vector, order, _.range()))

  order and x.all(
    ([v, w]) -> _.get(index, v) < _.get(index, w),
    g.edges(G))


correctArticulationPoints = (G) ->
  adj = (G) -> _.partial(g.adjacent, G)

  as = _.into(_.set(), a.articulationPoints(adj(G), g.vertices(G)))

  for v in g.vertices(G)
    if g.isIsolated(G, v)
      continue

    n = _.count(t.dfs(adj(G), [v]))
    Gv = G.withoutVertices([v])
    w = _.first(adj(G)(v))
    isA = _.count(t.dfs(adj(Gv), [w])) < n - 1

    if _.has_key(as, v) and not isA
      return "vertex " + v + " is false positive"
    else if not _.has_key(as, v) and isA
      return "vertex " + v + " is false negative"
  true


correctBottlenecks = (G) ->
  pred = (G) -> _.partial(g.predecessors, G)
  succ = (G) -> _.partial(g.successors, G)
  sources = (G) -> _.filter(_.partial(g.isSource, G), g.vertices(G))

  bs = _.into(_.set(), a.bottlenecks(succ(G), sources(G)))

  for v in g.vertices(G)
    descendants = t.dfs(succ(G), succ(G)(v))
    reachable = t.dfs(succ(G.withoutVertices([v])), sources(G))
    common = _.intersection(_.set(descendants), _.set(reachable))

    if _.has_key(bs, v) and _.count(common) > 0
      return "vertex " + v + " is false positive, common = " + common
    else if not _.has_key(bs, v) and _.count(common) == 0
      return "vertex " + v + " is false negative"
  true


describe 'A random DAG', ->
  it 'should have a correct topological order', ->
    expectProperty(forAll(DAG(0.2)).satisfy(correctTopOrder))

  it 'should have the correct articulation points', ->
    expectProperty(forAll(DAG(0.2)).satisfy(correctArticulationPoints))

  it 'should have the correct bottlenecks', ->
    expectProperty(forAll(DAG(0.2)).satisfy(correctBottlenecks))
