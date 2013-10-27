###
This module implements some selected graph algorithms.

Like in the `traversal` module, a graph is specified by a function returning
the list of relevant neighbors for a given vertex and a list of seed
vertices. Details on how arguments are interpreted vary slightly between
functions.

All functions return an array of vertices.
###

_ = require 'mori'
x = require './mori-utils'
t = require './traversal'


topsort = (succ, sources) ->
  ###
  This function computes a topological vertex order for a finite *DAG*
  (directed acyclic graph). Arguments are the successor function `succ` for
  the graph and a list `sources` of source vertices.

  The topological order found is returned as an array if the graph is indeed
  acyclic. Otherwise, `undefined` is returned. Results may not be as expected
  if vertices listed in `sources` are descendants of each other.
  ###
  visit = ([order, marked], v) ->
    if _.has_key(marked, v)
      [(order if _.get(marked, v) == 1), marked]
    else
      [order, marked] = _.reduce(visit, [order, _.assoc(marked, v, 0)], succ(v))
      [(_.conj(order, v) if order?), _.assoc(marked, v, 1)]

  order = _.reduce(visit, [_.list(), _.hash_map()], sources)[0]
  _.into_array(order) if order?


bottlenecks = (succ, sources) ->
  ###
  Computes the bottlenecks of a finite directed graph. A bottleneck is a
  vertex `v` such that no descendant of `v` can be reached from any source
  vertex by a directed path that does not pass through `v`.

  Arguments are the successor function `succ` for the graph and the list
  `sources` of source vertices. Results may not be as expected if vertices
  listed in `sources` are descendants of each other.
  ###
  edges    = t.forest(t.dfs, succ, sources)
  vertices = _.map(x.second, edges)

  succx = (v) ->
    (w) -> if _.equals(v, w) then _.set() else _.disj(_.set(succ(w)), v)

  good = (v) ->
    descendants = t.dfs(succ, succ(v))
    reachable = t.dfs(succx(v), sources)
    x.isEmpty(_.intersection(_.set(descendants), _.set(reachable)))

  _.into_array(_.filter(good, vertices))


articulationPoints = (adj, seeds) ->
  ###
  Computes the vertices at which the given finite graph can be 'cut'
  apart. More precisely, a vertex `v` is an articulation point if there are
  vertices `u` and `w` distinct from `v` such that every path between `u` and
  `w` passes through `v`.

  Arguments are the adjacency function `adj` for the graph and a list `seeds`
  of seed vertices.
  ###
  edges    = t.forest(t.dfs, adj, seeds)
  vertices = _.map(x.second, edges)
  parent   = _.zipmap(vertices, _.map(_.first, edges))
  index    = _.zipmap(vertices, _.range())

  trav = t.byEdges(t.dfs, adj, seeds)

  step = (low, [u, v]) ->
    if u? and _.get(index, v) >= _.get(index, u)
      _.assoc(low, u, Math.min(_.get(low, u), _.get(low, v)))
    else if u? and not _.equals(v, _.get(parent, u))
      _.assoc(low, u, Math.min(_.get(low, u), _.get(index, v)))
    else
      low

  lowPoint = _.reduce(step, index, _.reverse(_.map(_.into_array, trav)))

  good = (v) ->
    if _.get(parent, v) is null
      x.countAtLeast(2, _.filter(((w) -> _.equals(_.get(parent, w), v)), adj(v)))
    else
      test = (w) ->
        _.equals(_.get(parent, w), v) and _.get(lowPoint, w) >= _.get(index, v)
      x.any(test, adj(v))

  _.into_array(_.filter(good, vertices))


module.exports =
  topsort           : topsort
  articulationPoints: articulationPoints
  bottlenecks       : bottlenecks
