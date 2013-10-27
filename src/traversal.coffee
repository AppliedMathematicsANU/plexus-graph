###
This module provides a small collection of functions that can be used to
construct a variety of graph traversal strategies. All functions return a lazy
sequence, as defined by the [Mori](https://github.com/swannodette/mori)
library.

Graphs to be traversed over are defined by two pieces of information: first,
an adjacency function `adj`, which for every vertex returns the list of
relevant neighbors of that vertex - successors for directed traversals, all
neighbors for undirected ones - and second, a list `seeds` of seed
vertices to start traversing from. Some functions take additional arguments
that further detail the traversal method to be used.

It is possible to traverse infinite graphs, in which case the traversal
sequence would also be infinite. Thus when applying any functions that need to
realise a sequence completely, it is crucial to first extract a finite
subsequence with a function such as `take` or `take_while`.

Example:

    mori = require 'mori'
    trav = require './traversal'

    adj = (i) -> [i - 1, i + 2]

    console.log mori.take(20, trav.bfs(adj, [0]))
    console.log mori.take(20, trav.dfs(adj, [0]))
###

_ = require 'mori'
x = require './mori-utils'


traversal = (adj, seeds, empty, push, head, tail) ->
  ###
  The generic traversal algorithm that forms the basis for everything else in
  this module.

  In addition to the graph adjacency function `adj` and the list of seed
  vertices `seeds`, four arguments must to be supplied which together
  determine in which order neighbors of visited vertices are stored and
  processed. See the code for the functions `bfs` and `dfs` as examples.

  - `empty` - an empty "to-do list" of vertices
  - `push`  - function returning the result of adding an item to the given
    to-do list
  - `head`  - function returning an element of the given to-do list or null
    if empty
  - `todo`  - function returning the given to-do list without the results of
    `head`
  ###
  step = ([node, seen, todo, seedsLeft]) ->
    if head(todo)?
      node = head(todo)
      todo = tail(todo)
    else
      seedsLeft = _.drop_while(((v) -> _.has_key(seen, v)), seedsLeft)
      node = _.first(seedsLeft)
      seedsLeft = _.rest(seedsLeft)

    if node?
      neighbors = adj(node)
      remaining = _.remove(_.partial(_.has_key, seen), neighbors)
      todo = _.reduce(push, todo, remaining)
      seen = _.union(seen, _.conj(_.set(), node), _.set(neighbors))
      [node, seen, todo, seedsLeft]

  _.map(_.first, _.rest(x.iterateAndTrim(step, [null, _.set(), empty, seeds])))


bfs = (adj, seeds) ->
  ###
  Performs a breadth-first search on the graph given by the adjacency function
  `adj` and the seed vertices listed in `seeds`.
  ###
  traversal(adj, seeds, _.vector(), _.conj, _.first, _.curry(_.subvec, 1))


dfs = (adj, seeds) ->
  ###
  Performs a depth-first search on the graph given by the adjacency function
  `adj` and the seed vertices listed in `seeds`.
  ###
  traversal(adj, seeds, _.list(), _.conj, _.first, _.rest)


byEdges = (method, adj, seeds) ->
  ###
  Performs the traversal implemented by the function `method`, but instead of
  producing a sequences of vertices, computes the sequence of all edges
  visited by the traversal.

  Whenever the traversal restarts at a new seed vertex, say `v`, a
  pseudo-edge of the form `[null, v]` is inserted into the output sequence.
  ###
  eadj = (e) ->
    v = x.second(e)
    _.map(_.vector, _.repeat(v), adj(v))

  method(eadj, _.into_array(_.map(_.vector, _.repeat(null), seeds)))


forest = (method, adj, seeds) ->
  ###
  Performs the traversal implemented by the function `method`, but instead of
  producing a sequences of vertices, computes the sequence of all edges taken
  by the traversal that ended in new vertices.

  Whenever the traversal restarts at a new seed vertex, say `v`, a
  pseudo-edge of the form `[null, v]` is inserted into the output sequence.
  ###
  step = ([e, seen, es]) ->
    es = _.drop_while(((e) -> _.has_key(seen, x.second(e))), es)
    e = _.first(es)
    if e?
      [e, _.conj(seen, x.second(e)), _.rest(es)]

  edges = byEdges(method, adj, seeds)
  _.map(_.first, _.rest(x.iterateAndTrim(step, [null, _.set(), edges])))


module.exports =
  traversal : traversal
  bfs       : bfs
  dfs       : dfs
  byEdges   : byEdges
  forest    : forest
